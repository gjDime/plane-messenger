import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/security/crypto_service.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/services/packet_codec.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

const _kMaxSeenIds = 500;

class MessageRouter {
  final MessageRepository _messageRepository;
  final PeerRepository _peerRepository;
  final EncryptionService _encryptionService;
  final SigningService _signingService;
  final P2PConnectionService _connectionService;
  final PacketCodec _packetCodec;
  final GroupRepository _groupRepository;

  final Set<String> _seenMessageIds = {};

  final _inboundMessages = StreamController<MessageEntity>.broadcast();

  Stream<MessageEntity> get inboundMessages => _inboundMessages.stream;

  MessageRouter({
    required MessageRepository messageRepository,
    required PeerRepository peerRepository,
    required EncryptionService encryptionService,
    required SigningService signingService,
    required P2PConnectionService connectionService,
    required PacketCodec packetCodec,
    required GroupRepository groupRepository,
  })  : _messageRepository = messageRepository,
        _peerRepository = peerRepository,
        _encryptionService = encryptionService,
        _signingService = signingService,
        _connectionService = connectionService,
        _packetCodec = packetCodec,
        _groupRepository = groupRepository;

  void trackSeenId(String id) {
    if (_seenMessageIds.length >= _kMaxSeenIds) {
      _seenMessageIds.remove(_seenMessageIds.first);
    }
    _seenMessageIds.add(id);
  }

  Future<bool> floodToEndpoints(Uint8List packetBytes) async {
    final endpoints = _connectionService.connectedEndpoints;
    if (endpoints.isEmpty) return false;
    bool anySuccess = false;
    for (final endpointId in endpoints) {
      try {
        await _connectionService.sendPayload(endpointId, packetBytes);
        anySuccess = true;
      } catch (e) {
        debugPrint('[MESH] Failed to send to $endpointId: $e');
      }
    }
    return anySuccess;
  }

  Future<void> handleMessagePacket(
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

    if (!await _packetCodec.verifySignature(data, signature, senderKey)) {
      debugPrint('[MESH] Dropping packet $messageId — invalid signature');
      return;
    }

    trackSeenId(messageId);

    final myPublicKey = await _signingService.publicKeyBase64;
    final isBroadcast = targetKey == 'BROADCAST';
    final isForMe = isBroadcast || targetKey == myPublicKey;

    if (isEncrypted && isForMe && !isBroadcast) {
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
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
    } else if (targetKey.startsWith('group:')) {
      // Membership gate: only save if we joined before the message was sent.
      final groupId = targetKey.substring(6);
      final group = await _groupRepository.getGroup(groupId);
      if (group != null && group.isMember && timestamp >= group.joinedAt) {
        final msgEntity = MessageEntity()
          ..messageId = messageId
          ..senderId = senderKey
          ..targetId = targetKey
          ..payload = payloadContent
          ..timestamp = timestamp
          ..signature = signature
          ..ttl = ttl
          ..isMine = false;
        await _messageRepository.saveMessage(msgEntity);
        _inboundMessages.add(msgEntity);
      }
      // Relay regardless of membership so non-members keep the mesh connected.
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
    } else {
      final msgEntity = MessageEntity()
        ..messageId = messageId
        ..senderId = senderKey
        ..targetId = targetKey
        ..payload = payloadContent
        ..timestamp = timestamp
        ..signature = signature
        ..ttl = ttl
        ..isMine = false;

      await _messageRepository.saveMessage(msgEntity);
      _inboundMessages.add(msgEntity);
      _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
    }
  }

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

    if (!_encryptionService.hasSharedSecret(senderKey)) {
      final peer = await _peerRepository.getPeerByPublicKey(senderKey);
      if (peer != null && peer.x25519PublicKey.isNotEmpty) {
        await _encryptionService.establishSharedSecret(
          senderKey,
          peer.x25519PublicKey,
        );
      } else {
        debugPrint('[MESH] Cannot decrypt DM $messageId — no shared secret for sender');
        _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
        return;
      }
    }

    try {
      final encrypted = EncryptedPayload(
        ciphertextBase64: payloadContent,
        nonceBase64: nonceB64,
        macBase64: macB64,
      );
      final plaintext = await _encryptionService.decryptFromPeer(senderKey, encrypted);

      final msgEntity = MessageEntity()
        ..messageId = messageId
        ..senderId = senderKey
        ..targetId = targetKey
        ..payload = plaintext
        ..timestamp = timestamp
        ..signature = signature
        ..ttl = ttl
        ..isMine = false;

      await _messageRepository.saveMessage(msgEntity);
      _inboundMessages.add(msgEntity);
    } catch (e) {
      debugPrint('[MESH] Decryption failed for $messageId: $e');
    }

    _relayIfNeeded(transport, data, signature, ttl, fromEndpointId);
  }

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

    for (final endpointId in _connectionService.connectedEndpoints) {
      if (endpointId == fromEndpointId) continue;
      try {
        _connectionService.sendPayload(endpointId, relayBytes);
      } catch (e) {
        debugPrint('[MESH] Relay to $endpointId failed: $e');
      }
    }
  }
}
