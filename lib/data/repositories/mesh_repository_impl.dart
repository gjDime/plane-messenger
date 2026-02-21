
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:uuid/uuid.dart';

// Maximum number of seen message IDs kept in memory to prevent loops.
// Oldest entries are evicted once this limit is reached.
const _kMaxSeenIds = 500;

// Default TTL (hops) for newly broadcast messages.
const _kDefaultTtl = 3;

class MeshRepositoryImpl {
  final ConnectionManager connectionManager;
  final IsarService isarService;
  final KeyManager keyManager;

  // In-memory set of seen message IDs for flood-control deduplication
  final Set<String> _seenMessageIds = {};

  // Tracks which Nearby Connections endpoints are currently connected
  final Set<String> _connectedEndpoints = {};

  MeshRepositoryImpl({
    required this.connectionManager,
    required this.isarService,
    required this.keyManager,
  });

  Future<void> initialize() async {
    await connectionManager.startAdvertising();
    await connectionManager.startDiscovery();
  }

  Future<void> onConnectionEstablished(String endpointId) async {
    debugPrint('[MESH] Connection established with $endpointId');
    _connectedEndpoints.add(endpointId);

    final existing = await isarService.getPeer(endpointId);
    if (existing != null) {
      existing.isConnected = true;
      existing.lastSeen = DateTime.now().millisecondsSinceEpoch;
      await isarService.savePeer(existing);
    } else {
      final peer = PeerEntity()
        ..deviceId = endpointId
        ..publicKey = '' // Updated when handshake is received
        ..lastSeen = DateTime.now().millisecondsSinceEpoch
        ..isConnected = true;
      await isarService.savePeer(peer);
    }

    await _sendHandshake(endpointId);
  }

  Future<void> onPeerDisconnected(String endpointId) async {
    debugPrint('[MESH] Peer disconnected: $endpointId');
    _connectedEndpoints.remove(endpointId);

    final peer = await isarService.getPeer(endpointId);
    if (peer != null) {
      peer.isConnected = false;
      await isarService.savePeer(peer);
    }
  }

  Future<void> _sendHandshake(String endpointId) async {
    final myPublicKey = await keyManager.publicKeyBase64;
    final handshake = jsonEncode({'type': 'handshake', 'pubKey': myPublicKey});
    await connectionManager.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(handshake)),
    );
  }

  // ---------------------------------------------------------------------------
  // Packet format (JSON, MVP — human-readable for easier debugging)
  //
  // {
  //   "t": { "ttl": 3, "target": "BROADCAST" },   // mutable transport header
  //   "d": { "id": "<uuid>", "sender": "<base64-pubkey>",
  //           "ts": <epoch-ms>, "payload": "<text>" },  // signed data
  //   "s": "<base64-signature>"                    // Ed25519 sig of "d"
  // }
  // ---------------------------------------------------------------------------

  Future<void> broadcastMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final senderKey = await keyManager.publicKeyBase64;
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final dataMap = {
      'id': messageId,
      'sender': senderKey,
      'ts': timestamp,
      'payload': trimmed,
    };

    final dataJson = jsonEncode(dataMap);
    final dataBytes = utf8.encode(dataJson);
    final signatureBytes = await keyManager.sign(dataBytes);
    final signature = base64Encode(signatureBytes);

    final packetMap = {
      't': {'ttl': _kDefaultTtl, 'target': 'BROADCAST'},
      'd': dataMap,
      's': signature,
    };

    final packetBytes = Uint8List.fromList(utf8.encode(jsonEncode(packetMap)));

    // Persist locally before sending
    final msgEntity = MessageEntity()
      ..messageId = messageId
      ..senderId = senderKey
      ..targetId = 'BROADCAST'
      ..payload = trimmed
      ..timestamp = timestamp
      ..signature = signature
      ..ttl = _kDefaultTtl
      ..isMine = true;

    await isarService.saveMessage(msgEntity);
    _trackSeenId(messageId);

    // Broadcast to all currently connected peers
    for (final endpointId in _connectedEndpoints) {
      try {
        await connectionManager.sendPayload(endpointId, packetBytes);
      } catch (e) {
        debugPrint('[MESH] Failed to send to $endpointId: $e');
      }
    }
    debugPrint('[MESH] Broadcast message $messageId to ${_connectedEndpoints.length} peer(s)');
  }

  Future<void> onPayloadReceived(String endpointId, Uint8List payload) async {
    try {
      final jsonString = utf8.decode(payload);
      final packet = jsonDecode(jsonString);

      if (packet is! Map<String, dynamic>) {
        debugPrint('[MESH] Ignoring non-object packet from $endpointId');
        return;
      }

      if (packet.containsKey('d')) {
        await _handleMessagePacket(packet, endpointId);
      } else if (packet['type'] == 'handshake') {
        await _handleHandshake(packet, endpointId);
      } else {
        debugPrint('[MESH] Unknown packet type from $endpointId');
      }
    } catch (e) {
      debugPrint('[MESH] Error parsing payload from $endpointId: $e');
    }
  }

  Future<void> _handleMessagePacket(
    Map<String, dynamic> packet,
    String fromEndpointId,
  ) async {
    // Validate top-level structure before casting
    final rawData = packet['d'];
    final rawTransport = packet['t'];
    final rawSignature = packet['s'];

    if (rawData is! Map<String, dynamic> ||
        rawTransport is! Map<String, dynamic> ||
        rawSignature is! String) {
      debugPrint('[MESH] Dropping malformed packet from $fromEndpointId');
      return;
    }

    final data = rawData;
    final transport = rawTransport;
    final signature = rawSignature;

    // Validate data fields
    final messageId = data['id'];
    final senderKey = data['sender'];
    final payloadContent = data['payload'];
    final timestamp = data['ts'];
    final targetKey = transport['target'];
    final ttl = transport['ttl'];

    if (messageId is! String ||
        senderKey is! String ||
        payloadContent is! String ||
        timestamp is! int ||
        targetKey is! String ||
        ttl is! int) {
      debugPrint('[MESH] Dropping packet with invalid field types from $fromEndpointId');
      return;
    }

    // Deduplicate
    if (_seenMessageIds.contains(messageId)) return;

    // Verify signature before accepting the message
    final dataJson = jsonEncode(data);
    final dataBytes = utf8.encode(dataJson);

    late List<int> signatureBytes;
    late List<int> senderKeyBytes;
    try {
      signatureBytes = base64Decode(signature);
      senderKeyBytes = base64Decode(senderKey);
    } catch (e) {
      debugPrint('[MESH] Dropping packet $messageId — invalid base64: $e');
      return;
    }

    final isValid = await keyManager.verify(dataBytes, signatureBytes, senderKeyBytes);
    if (!isValid) {
      debugPrint('[MESH] Dropping packet $messageId — invalid signature');
      return;
    }

    // Only track after verification passes
    _trackSeenId(messageId);

    // Save to local DB
    final msgEntity = MessageEntity()
      ..messageId = messageId
      ..senderId = senderKey
      ..targetId = targetKey
      ..payload = payloadContent
      ..timestamp = timestamp
      ..signature = signature
      ..ttl = ttl
      ..isMine = false;

    await isarService.saveMessage(msgEntity);

    // Relay to other connected peers if TTL allows
    if (ttl > 0 && targetKey == 'BROADCAST') {
      final newTransport = Map<String, dynamic>.from(transport);
      newTransport['ttl'] = ttl - 1;

      final relayPacket = {'t': newTransport, 'd': data, 's': signature};
      final relayBytes = Uint8List.fromList(utf8.encode(jsonEncode(relayPacket)));

      for (final endpointId in _connectedEndpoints) {
        if (endpointId == fromEndpointId) continue; // Don't relay back to sender
        try {
          await connectionManager.sendPayload(endpointId, relayBytes);
        } catch (e) {
          debugPrint('[MESH] Relay to $endpointId failed: $e');
        }
      }
      debugPrint('[MESH] Relayed message $messageId (TTL ${ttl - 1})');
    }
  }

  Future<void> _handleHandshake(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final publicKey = packet['pubKey'];
    if (publicKey is! String || publicKey.isEmpty) {
      debugPrint('[MESH] Dropping invalid handshake from $endpointId');
      return;
    }

    final existing = await isarService.getPeer(endpointId);
    if (existing != null) {
      existing.publicKey = publicKey;
      existing.lastSeen = DateTime.now().millisecondsSinceEpoch;
      await isarService.savePeer(existing);
    } else {
      final peer = PeerEntity()
        ..deviceId = endpointId
        ..publicKey = publicKey
        ..lastSeen = DateTime.now().millisecondsSinceEpoch
        ..isConnected = true;
      await isarService.savePeer(peer);
    }
    debugPrint('[MESH] Handshake complete with $endpointId');
  }

  // Adds [id] to the seen-IDs set, evicting the oldest entry if at capacity.
  void _trackSeenId(String id) {
    if (_seenMessageIds.length >= _kMaxSeenIds) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
    _seenMessageIds.add(id);
  }
}
