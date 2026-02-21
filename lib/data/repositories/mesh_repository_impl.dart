
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/core/user_prefs.dart';
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

  final Set<String> _seenMessageIds = {};
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
    _connectedEndpoints.remove(endpointId);

    final peer = await isarService.getPeer(endpointId);
    if (peer != null) {
      peer.isConnected = false;
      await isarService.savePeer(peer);
    }
  }

  Future<void> _sendHandshake(String endpointId) async {
    final myPublicKey = await keyManager.publicKeyBase64;
    final nickname = await UserPrefs.getNickname();
    final handshake = jsonEncode({
      'type': 'handshake',
      'pubKey': myPublicKey,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
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

  Future<void> broadcastNicknameUpdate(String nickname) async {
    final trimmed = nickname.trim();
    final packet = jsonEncode({
      'type': 'nickname_update',
      'nickname': trimmed,
    });
    final bytes = Uint8List.fromList(utf8.encode(packet));

    for (final endpointId in _connectedEndpoints) {
      try {
        await connectionManager.sendPayload(endpointId, bytes);
      } catch (e) {
        debugPrint('[MESH] Failed to send nickname_update to $endpointId: $e');
      }
    }
  }

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

    for (final endpointId in _connectedEndpoints) {
      try {
        await connectionManager.sendPayload(endpointId, packetBytes);
      } catch (e) {
        debugPrint('[MESH] Failed to send to $endpointId: $e');
      }
    }
  }

  Future<void> onPayloadReceived(String endpointId, Uint8List payload) async {
    try {
      final jsonString = utf8.decode(payload);
      final packet = jsonDecode(jsonString);

      if (packet is! Map<String, dynamic>) return;

      if (packet.containsKey('d')) {
        await _handleMessagePacket(packet, endpointId);
      } else if (packet['type'] == 'handshake') {
        await _handleHandshake(packet, endpointId);
      } else if (packet['type'] == 'nickname_update') {
        await _handleNicknameUpdate(packet, endpointId);
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

    if (_seenMessageIds.contains(messageId)) return;

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

    // Reject self-connections: P2P_CLUSTER mode can discover the device's own
    // advertisement. Disconnect and clean up the stub peer record.
    final myPublicKey = await keyManager.publicKeyBase64;
    if (publicKey == myPublicKey) {
      debugPrint('[MESH] Ignoring self-connection from $endpointId');
      _connectedEndpoints.remove(endpointId);
      await connectionManager.disconnectFromEndpoint(endpointId);
      await isarService.deletePeer(endpointId);
      return;
    }

    final rawNickname = packet['nickname'];
    final nickname = rawNickname is String && rawNickname.trim().isNotEmpty
        ? rawNickname.trim()
        : null;

    // Look up whether we already have a record for this public key — either
    // from an earlier session or a duplicate connection within the current one.
    final knownPeer = await isarService.getPeerByPublicKey(publicKey);

    if (knownPeer != null && knownPeer.deviceId != endpointId) {
      // Same physical device reconnecting under a new endpoint ID.
      // Delete the stub for the new endpoint and update the existing record
      // in-place so historical data (nickname) is preserved.
      await isarService.deletePeer(endpointId);

      // Close the stale endpoint only if it is still active in this session.
      if (_connectedEndpoints.remove(knownPeer.deviceId)) {
        try {
          await connectionManager.disconnectFromEndpoint(knownPeer.deviceId);
        } catch (_) {
          // Endpoint from a previous session; Nearby Connections no longer
          // knows about it — ignore the error.
        }
      }

      knownPeer.deviceId = endpointId;
      knownPeer.isConnected = true;
      knownPeer.lastSeen = DateTime.now().millisecondsSinceEpoch;
      if (nickname != null) knownPeer.nickname = nickname;
      await isarService.savePeer(knownPeer);
    } else {
      final stub = await isarService.getPeer(endpointId);
      if (stub != null) {
        stub.publicKey = publicKey;
        stub.lastSeen = DateTime.now().millisecondsSinceEpoch;
        if (nickname != null) stub.nickname = nickname;
        await isarService.savePeer(stub);
      } else {
        final peer = PeerEntity()
          ..deviceId = endpointId
          ..publicKey = publicKey
          ..nickname = nickname
          ..lastSeen = DateTime.now().millisecondsSinceEpoch
          ..isConnected = true;
        await isarService.savePeer(peer);
      }
    }
  }

  Future<void> _handleNicknameUpdate(
    Map<String, dynamic> packet,
    String fromEndpointId,
  ) async {
    final rawNickname = packet['nickname'];
    if (rawNickname is! String) {
      debugPrint('[MESH] Dropping invalid nickname_update from $fromEndpointId');
      return;
    }

    final peer = await isarService.getPeer(fromEndpointId);
    if (peer == null) return;

    final nickname = rawNickname.trim();
    peer.nickname = nickname.isNotEmpty ? nickname : null;
    await isarService.savePeer(peer);
  }

  void _trackSeenId(String id) {
    if (_seenMessageIds.length >= _kMaxSeenIds) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
    _seenMessageIds.add(id);
  }
}
