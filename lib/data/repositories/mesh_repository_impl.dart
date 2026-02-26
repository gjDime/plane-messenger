import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/security/crypto_service.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';
import 'package:plane_messenger/data/datasources/p2p/connection_manager.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:uuid/uuid.dart';

/// Maximum number of seen message IDs kept in memory to prevent relay loops.
/// Oldest entries are evicted once this limit is reached.
const _kMaxSeenIds = 500;

/// Default TTL (hops) for newly sent messages.
const _kDefaultTtl = 3;

class MeshRepositoryImpl {
  final ConnectionManager connectionManager;
  final IsarService isarService;
  final KeyManager keyManager;
  final CryptoService cryptoService;

  final Set<String> _seenMessageIds = {};
  final Set<String> _connectedEndpoints = {};

  MeshRepositoryImpl({
    required this.connectionManager,
    required this.isarService,
    required this.keyManager,
    required this.cryptoService,
  });

  Future<void> initialize() async {
    await connectionManager.startAdvertising();
    await connectionManager.startDiscovery();
  }

  /// Stops and restarts both advertising and discovery so the device
  /// re-scans for nearby peers.
  Future<void> restartDiscovery() async {
    await connectionManager.stopDiscovery();
    await connectionManager.stopAdvertising();
    await connectionManager.startAdvertising();
    await connectionManager.startDiscovery();
  }

  // ---------------------------------------------------------------------------
  // Connection lifecycle
  // ---------------------------------------------------------------------------

  Future<void> onConnectionEstablished(String endpointId) async {
    _connectedEndpoints.add(endpointId);
    connectionManager.markConnected(endpointId);

    final existing = await isarService.getPeer(endpointId);
    if (existing != null) {
      existing.isConnected = true;
      existing.lastSeen = DateTime.now().millisecondsSinceEpoch;
      await isarService.savePeer(existing);
    } else {
      final peer = PeerEntity()
        ..deviceId = endpointId
        ..publicKey = ''
        ..lastSeen = DateTime.now().millisecondsSinceEpoch
        ..isConnected = true;
      await isarService.savePeer(peer);
    }

    await _sendHandshake(endpointId);
  }

  Future<void> onPeerDisconnected(String endpointId) async {
    _connectedEndpoints.remove(endpointId);
    connectionManager.markDisconnected(endpointId);

    final peer = await isarService.getPeer(endpointId);
    if (peer != null) {
      peer.isConnected = false;
      await isarService.savePeer(peer);
    }
  }

  // ---------------------------------------------------------------------------
  // Handshake — exchanges Ed25519 identity keys and X25519 encryption keys
  // ---------------------------------------------------------------------------

  Future<void> _sendHandshake(String endpointId) async {
    final myPublicKey = await keyManager.publicKeyBase64;
    final myX25519PublicKey = await keyManager.x25519PublicKeyBase64;
    final nickname = await UserPrefs.getNickname();
    final handshake = jsonEncode({
      'type': 'handshake',
      'pubKey': myPublicKey,
      'x25519PubKey': myX25519PublicKey,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    await connectionManager.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(handshake)),
    );
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

    // Extract X25519 key (absent for peers running older app versions)
    final rawX25519 = packet['x25519PubKey'];
    final x25519Key = (rawX25519 is String && rawX25519.isNotEmpty)
        ? rawX25519
        : '';

    // Look up whether we already have a record for this public key — either
    // from an earlier session or a duplicate connection within the current one.
    final knownPeer = await isarService.getPeerByPublicKey(publicKey);

    if (knownPeer != null && knownPeer.deviceId != endpointId) {
      // Same physical device reconnecting under a new endpoint ID.
      // Delete the stub for the new endpoint and update the existing record
      // in-place so historical data (nickname) is preserved.
      await isarService.deletePeer(endpointId);

      if (_connectedEndpoints.remove(knownPeer.deviceId)) {
        try {
          await connectionManager.disconnectFromEndpoint(knownPeer.deviceId);
        } catch (_) {
          // Endpoint from a previous session — ignore.
        }
      }

      knownPeer.deviceId = endpointId;
      knownPeer.isConnected = true;
      knownPeer.lastSeen = DateTime.now().millisecondsSinceEpoch;
      knownPeer.x25519PublicKey = x25519Key;
      if (nickname != null) knownPeer.nickname = nickname;
      await isarService.savePeer(knownPeer);
    } else {
      final stub = await isarService.getPeer(endpointId);
      if (stub != null) {
        stub.publicKey = publicKey;
        stub.x25519PublicKey = x25519Key;
        stub.lastSeen = DateTime.now().millisecondsSinceEpoch;
        if (nickname != null) stub.nickname = nickname;
        await isarService.savePeer(stub);
      } else {
        final peer = PeerEntity()
          ..deviceId = endpointId
          ..publicKey = publicKey
          ..x25519PublicKey = x25519Key
          ..nickname = nickname
          ..lastSeen = DateTime.now().millisecondsSinceEpoch
          ..isConnected = true;
        await isarService.savePeer(peer);
      }
    }

    // Derive and cache the ECDH shared secret for E2EE
    if (x25519Key.isNotEmpty) {
      try {
        await cryptoService.establishSharedSecret(publicKey, x25519Key);
      } catch (e) {
        debugPrint('[MESH] Failed to derive shared secret with $endpointId: $e');
      }
    }

    // Auto-resend any previously failed messages to this peer
    final myPubKey = await keyManager.publicKeyBase64;
    final failedMessages = await isarService.getFailedMessagesForPeer(
      publicKey,
      myPubKey,
    );
    for (final msg in failedMessages) {
      try {
        await resendFailedMessage(msg);
      } catch (e) {
        debugPrint('[MESH] Auto-resend failed for ${msg.messageId}: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Nickname updates
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

  // ---------------------------------------------------------------------------
  // Wire format (JSON — human-readable for debugging)
  //
  // Broadcast (plaintext):
  // { "t": { "ttl": 3, "target": "BROADCAST" },
  //   "d": { "id", "sender", "ts", "payload" },
  //   "s": "<ed25519-sig-of-d>" }
  //
  // Direct message (encrypted):
  // { "t": { "ttl": 3, "target": "<recipient-ed25519-pubkey>" },
  //   "d": { "id", "sender", "ts", "payload" (ciphertext),
  //          "nonce", "mac", "enc": true },
  //   "s": "<ed25519-sig-of-d>" }
  // ---------------------------------------------------------------------------

  /// Sends a plaintext broadcast visible to all peers in the mesh.
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

    final packetBytes = await _signAndEncode(
      dataMap,
      transport: {'ttl': _kDefaultTtl, 'target': 'BROADCAST'},
    );

    final msgEntity = MessageEntity()
      ..messageId = messageId
      ..senderId = senderKey
      ..targetId = 'BROADCAST'
      ..payload = trimmed
      ..timestamp = timestamp
      ..signature = ''
      ..ttl = _kDefaultTtl
      ..isMine = true
      ..deliveryStatus = DeliveryStatus.sending.index;

    await isarService.saveMessage(msgEntity);
    _trackSeenId(messageId);
    final success = await _floodToEndpoints(packetBytes);
    await isarService.updateMessageStatus(
      messageId,
      success ? DeliveryStatus.sent.index : DeliveryStatus.failed.index,
    );
  }

  /// Sends an E2EE direct message to a specific peer.
  ///
  /// The payload is encrypted with AES-256-GCM using a shared secret derived
  /// via X25519 ECDH. Only the recipient can decrypt it; relay nodes forward
  /// the packet based on the `target` field without reading the content.
  Future<void> sendDirectMessage(
    String recipientEd25519PubKey,
    String content,
  ) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    // Ensure we have a shared secret (derive on-demand from DB if needed)
    final ready = cryptoService.hasSharedSecret(recipientEd25519PubKey) ||
        await cryptoService.tryEstablishSharedSecret(
          recipientEd25519PubKey,
          isarService,
        );
    if (!ready) {
      debugPrint(
        '[MESH] Cannot send DM: no X25519 key for peer '
        '${recipientEd25519PubKey.substring(0, 8)}…',
      );
      return;
    }

    final encrypted = await cryptoService.encryptForPeer(
      recipientEd25519PubKey,
      trimmed,
    );

    final senderKey = await keyManager.publicKeyBase64;
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final dataMap = {
      'id': messageId,
      'sender': senderKey,
      'ts': timestamp,
      'payload': encrypted.ciphertextBase64,
      'nonce': encrypted.nonceBase64,
      'mac': encrypted.macBase64,
      'enc': true,
    };

    final packetBytes = await _signAndEncode(
      dataMap,
      transport: {'ttl': _kDefaultTtl, 'target': recipientEd25519PubKey},
    );

    // Store the plaintext locally for display on this device
    final msgEntity = MessageEntity()
      ..messageId = messageId
      ..senderId = senderKey
      ..targetId = recipientEd25519PubKey
      ..payload = trimmed
      ..timestamp = timestamp
      ..signature = ''
      ..ttl = _kDefaultTtl
      ..isMine = true
      ..deliveryStatus = DeliveryStatus.sending.index;

    await isarService.saveMessage(msgEntity);
    _trackSeenId(messageId);
    final success = await _floodToEndpoints(packetBytes);
    await isarService.updateMessageStatus(
      messageId,
      success ? DeliveryStatus.sent.index : DeliveryStatus.failed.index,
    );
  }

  // ---------------------------------------------------------------------------
  // Receive path
  // ---------------------------------------------------------------------------

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
    final isEncrypted = data['enc'] == true;

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

    // Verify Ed25519 signature over the data section
    if (!await _verifySignature(data, signature, senderKey)) {
      debugPrint('[MESH] Dropping packet $messageId — invalid signature');
      return;
    }

    _trackSeenId(messageId);

    final myPublicKey = await keyManager.publicKeyBase64;
    final isBroadcast = targetKey == 'BROADCAST';
    final isForMe = isBroadcast || targetKey == myPublicKey;

    if (isEncrypted && isForMe && !isBroadcast) {
      // Encrypted DM targeted at us — attempt decryption
      await _handleEncryptedMessage(
        data: data,
        transport: transport,
        signature: signature,
        senderKey: senderKey,
        messageId: messageId,
        timestamp: timestamp,
        targetKey: targetKey,
        ttl: ttl,
        fromEndpointId: fromEndpointId,
      );
    } else if (isEncrypted && !isForMe) {
      // Encrypted DM for someone else — relay without storing
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
    } else {
      // Plaintext broadcast — store and relay
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
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
    }
  }

  /// Decrypts an incoming E2EE message and stores the plaintext locally.
  Future<void> _handleEncryptedMessage({
    required Map<String, dynamic> data,
    required Map<String, dynamic> transport,
    required String signature,
    required String senderKey,
    required String messageId,
    required int timestamp,
    required String targetKey,
    required int ttl,
    required String fromEndpointId,
  }) async {
    final nonceB64 = data['nonce'];
    final macB64 = data['mac'];
    final payloadContent = data['payload'] as String;

    if (nonceB64 is! String || macB64 is! String) {
      debugPrint('[MESH] Dropping encrypted packet $messageId — missing nonce/mac');
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
      return;
    }

    // Ensure we can decrypt (derive shared secret on-demand if needed)
    final ready = cryptoService.hasSharedSecret(senderKey) ||
        await cryptoService.tryEstablishSharedSecret(senderKey, isarService);
    if (!ready) {
      debugPrint('[MESH] Cannot decrypt DM $messageId — no shared secret for sender');
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
      return;
    }

    try {
      final encrypted = EncryptedPayload(
        ciphertextBase64: payloadContent,
        nonceBase64: nonceB64,
        macBase64: macB64,
      );
      final plaintext = await cryptoService.decryptFromPeer(senderKey, encrypted);

      final msgEntity = MessageEntity()
        ..messageId = messageId
        ..senderId = senderKey
        ..targetId = targetKey
        ..payload = plaintext
        ..timestamp = timestamp
        ..signature = signature
        ..ttl = ttl
        ..isMine = false;

      await isarService.saveMessage(msgEntity);
    } catch (e) {
      debugPrint('[MESH] Decryption failed for $messageId: $e');
    }

    // Always relay regardless of decryption outcome — the intended recipient
    // might be further along in the mesh.
    _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
  }

  // ---------------------------------------------------------------------------
  // Resend
  // ---------------------------------------------------------------------------

  /// Re-sends a previously failed message. Re-encrypts, re-signs, and floods.
  Future<void> resendFailedMessage(MessageEntity msg) async {
    await isarService.updateMessageStatus(
      msg.messageId,
      DeliveryStatus.sending.index,
    );

    try {
      final senderKey = await keyManager.publicKeyBase64;
      final isBroadcast = msg.targetId == 'BROADCAST';

      Map<String, dynamic> dataMap;
      Map<String, dynamic> transport;

      if (isBroadcast) {
        dataMap = {
          'id': msg.messageId,
          'sender': senderKey,
          'ts': msg.timestamp,
          'payload': msg.payload,
        };
        transport = {'ttl': _kDefaultTtl, 'target': 'BROADCAST'};
      } else {
        // Re-derive shared secret if needed
        final ready = cryptoService.hasSharedSecret(msg.targetId) ||
            await cryptoService.tryEstablishSharedSecret(
              msg.targetId,
              isarService,
            );
        if (!ready) {
          debugPrint('[MESH] Resend failed: no X25519 key for ${msg.targetId.substring(0, 8)}…');
          await isarService.updateMessageStatus(
            msg.messageId,
            DeliveryStatus.failed.index,
          );
          return;
        }

        final encrypted = await cryptoService.encryptForPeer(
          msg.targetId,
          msg.payload,
        );

        dataMap = {
          'id': msg.messageId,
          'sender': senderKey,
          'ts': msg.timestamp,
          'payload': encrypted.ciphertextBase64,
          'nonce': encrypted.nonceBase64,
          'mac': encrypted.macBase64,
          'enc': true,
        };
        transport = {'ttl': _kDefaultTtl, 'target': msg.targetId};
      }

      final packetBytes = await _signAndEncode(dataMap, transport: transport);
      final success = await _floodToEndpoints(packetBytes);
      await isarService.updateMessageStatus(
        msg.messageId,
        success ? DeliveryStatus.sent.index : DeliveryStatus.failed.index,
      );
    } catch (e) {
      debugPrint('[MESH] Resend error for ${msg.messageId}: $e');
      await isarService.updateMessageStatus(
        msg.messageId,
        DeliveryStatus.failed.index,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Signs a data map with Ed25519, wraps it in a transport envelope, and
  /// returns the encoded packet bytes ready for transmission.
  Future<Uint8List> _signAndEncode(
    Map<String, dynamic> dataMap, {
    required Map<String, dynamic> transport,
  }) async {
    final dataJson = jsonEncode(dataMap);
    final dataBytes = utf8.encode(dataJson);
    final signatureBytes = await keyManager.sign(dataBytes);
    final signature = base64Encode(signatureBytes);

    final packetMap = {'t': transport, 'd': dataMap, 's': signature};
    return Uint8List.fromList(utf8.encode(jsonEncode(packetMap)));
  }

  /// Verifies the Ed25519 signature on a data section.
  Future<bool> _verifySignature(
    Map<String, dynamic> data,
    String signatureBase64,
    String senderKeyBase64,
  ) async {
    final dataJson = jsonEncode(data);
    final dataBytes = utf8.encode(dataJson);

    late List<int> signatureBytes;
    late List<int> senderKeyBytes;
    try {
      signatureBytes = base64Decode(signatureBase64);
      senderKeyBytes = base64Decode(senderKeyBase64);
    } catch (e) {
      debugPrint('[MESH] Invalid base64 in signature or sender key: $e');
      return false;
    }

    return keyManager.verify(dataBytes, signatureBytes, senderKeyBytes);
  }

  /// Relays a packet to all connected endpoints except [fromEndpointId],
  /// decrementing TTL by one. Works for both broadcasts and targeted DMs.
  void _relayIfNeeded(
    Map<String, dynamic> transport,
    Map<String, dynamic> data,
    String signature,
    int ttl,
    String fromEndpointId,
  ) {
    if (ttl <= 0) return;

    final newTransport = Map<String, dynamic>.from(transport);
    newTransport['ttl'] = ttl - 1;

    final relayPacket = {'t': newTransport, 'd': data, 's': signature};
    final relayBytes = Uint8List.fromList(utf8.encode(jsonEncode(relayPacket)));

    for (final endpointId in _connectedEndpoints) {
      if (endpointId == fromEndpointId) continue;
      try {
        connectionManager.sendPayload(endpointId, relayBytes);
      } catch (e) {
        debugPrint('[MESH] Relay to $endpointId failed: $e');
      }
    }
  }

  /// Sends [packetBytes] to every connected endpoint.
  /// Returns `true` if at least one send succeeded, `false` otherwise.
  Future<bool> _floodToEndpoints(Uint8List packetBytes) async {
    if (_connectedEndpoints.isEmpty) return false;
    bool anySuccess = false;
    for (final endpointId in _connectedEndpoints) {
      try {
        await connectionManager.sendPayload(endpointId, packetBytes);
        anySuccess = true;
      } catch (e) {
        debugPrint('[MESH] Failed to send to $endpointId: $e');
      }
    }
    return anySuccess;
  }

  void _trackSeenId(String id) {
    if (_seenMessageIds.length >= _kMaxSeenIds) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
    _seenMessageIds.add(id);
  }
}
