import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

typedef ResendCallback = Future<void> Function(MessageEntity msg);

class HandshakeHandler {
  final PeerRepository _peerRepository;
  final MessageRepository _messageRepository;
  final EncryptionService _encryptionService;
  final SigningService _signingService;
  final P2PConnectionService _connectionService;
  final UserPrefs _userPrefs;
  final ResendCallback _onResend;

  HandshakeHandler({
    required PeerRepository peerRepository,
    required MessageRepository messageRepository,
    required EncryptionService encryptionService,
    required SigningService signingService,
    required P2PConnectionService connectionService,
    required UserPrefs userPrefs,
    required ResendCallback onResend,
  })  : _peerRepository = peerRepository,
        _messageRepository = messageRepository,
        _encryptionService = encryptionService,
        _signingService = signingService,
        _connectionService = connectionService,
        _userPrefs = userPrefs,
        _onResend = onResend;

  Future<void> sendHandshake(String endpointId) async {
    final myPublicKey = await _signingService.publicKeyBase64;
    final myX25519PublicKey = await _signingService.x25519PublicKeyBase64;
    final nickname = await _userPrefs.getNickname();
    final handshake = jsonEncode({
      'type': 'handshake',
      'pubKey': myPublicKey,
      'x25519PubKey': myX25519PublicKey,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    await _connectionService.sendPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(handshake)),
    );
  }

  Future<void> handleHandshake(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final publicKey = packet['pubKey'];
    if (publicKey is! String || publicKey.isEmpty) {
      debugPrint('[MESH] Dropping invalid handshake from $endpointId');
      return;
    }

    final myPublicKey = await _signingService.publicKeyBase64;
    if (publicKey == myPublicKey) {
      debugPrint('[MESH] Ignoring self-connection from $endpointId');
      await _connectionService.disconnectFromEndpoint(endpointId);
      await _peerRepository.deletePeer(endpointId);
      return;
    }

    final rawNickname = packet['nickname'];
    final nickname = rawNickname is String && rawNickname.trim().isNotEmpty
        ? rawNickname.trim()
        : null;

    final rawX25519 = packet['x25519PubKey'];
    final x25519Key = (rawX25519 is String && rawX25519.isNotEmpty)
        ? rawX25519
        : '';

    final knownPeer = await _peerRepository.getPeerByPublicKey(publicKey);

    if (knownPeer != null && knownPeer.deviceId != endpointId) {
      await _peerRepository.deletePeer(endpointId);

      if (_connectionService.connectedEndpoints.contains(knownPeer.deviceId)) {
        try {
          await _connectionService.disconnectFromEndpoint(knownPeer.deviceId);
        } catch (_) {}
      }

      knownPeer.deviceId = endpointId;
      knownPeer.isConnected = true;
      knownPeer.lastSeen = DateTime.now().millisecondsSinceEpoch;
      knownPeer.x25519PublicKey = x25519Key;
      if (nickname != null) knownPeer.nickname = nickname;
      await _peerRepository.savePeer(knownPeer);
    } else {
      final stub = await _peerRepository.getPeer(endpointId);
      if (stub != null) {
        stub.publicKey = publicKey;
        stub.x25519PublicKey = x25519Key;
        stub.lastSeen = DateTime.now().millisecondsSinceEpoch;
        if (nickname != null) stub.nickname = nickname;
        await _peerRepository.savePeer(stub);
      } else {
        final peer = PeerEntity()
          ..deviceId = endpointId
          ..publicKey = publicKey
          ..x25519PublicKey = x25519Key
          ..nickname = nickname
          ..lastSeen = DateTime.now().millisecondsSinceEpoch
          ..isConnected = true;
        await _peerRepository.savePeer(peer);
      }
    }

    if (x25519Key.isNotEmpty) {
      try {
        await _encryptionService.establishSharedSecret(publicKey, x25519Key);
      } catch (e) {
        debugPrint('[MESH] Failed to derive shared secret with $endpointId: $e');
      }
    }

    final myPubKey = await _signingService.publicKeyBase64;
    final failedMessages = await _messageRepository.getFailedMessagesForPeer(
      publicKey,
      myPubKey,
    );
    for (final msg in failedMessages) {
      try {
        await _onResend(msg);
      } catch (e) {
        debugPrint('[MESH] Auto-resend failed for ${msg.messageId}: $e');
      }
    }
  }

  Future<void> handleNicknameUpdate(
    Map<String, dynamic> packet,
    String fromEndpointId,
  ) async {
    final rawNickname = packet['nickname'];
    if (rawNickname is! String) {
      debugPrint('[MESH] Dropping invalid nickname_update from $fromEndpointId');
      return;
    }

    final peer = await _peerRepository.getPeer(fromEndpointId);
    if (peer == null) return;

    final nickname = rawNickname.trim();
    peer.nickname = nickname.isNotEmpty ? nickname : null;
    await _peerRepository.savePeer(peer);
  }

  Future<void> broadcastNicknameUpdate(String nickname) async {
    final trimmed = nickname.trim();
    final packet = jsonEncode({
      'type': 'nickname_update',
      'nickname': trimmed,
    });
    final bytes = Uint8List.fromList(utf8.encode(packet));

    for (final endpointId in _connectionService.connectedEndpoints) {
      try {
        await _connectionService.sendPayload(endpointId, bytes);
      } catch (e) {
        debugPrint('[MESH] Failed to send nickname_update to $endpointId: $e');
      }
    }
  }
}
