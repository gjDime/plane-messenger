import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/services/game_handler.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/data/services/handshake_handler.dart';
import 'package:plane_messenger/data/services/message_router.dart';
import 'package:plane_messenger/data/services/packet_codec.dart';
import 'package:plane_messenger/domain/repositories/game_repository.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/mesh_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'package:uuid/uuid.dart';

const _kDefaultTtl = 3;

class MeshRepositoryImpl implements MeshRepository {
  final P2PConnectionService _connectionService;
  final MessageRepository _messageRepository;
  final PeerRepository _peerRepository;
  final SigningService _signingService;
  final EncryptionService _encryptionService;

  late final PacketCodec _packetCodec;
  late final MessageRouter _messageRouter;
  late final HandshakeHandler _handshakeHandler;
  late final GameHandler _gameHandler;
  late final GroupManagementHandler _groupMgmtHandler;

  final Set<String> _seenGroupMgmtIds = {};
  static const _kMaxSeenGroupMgmt = 200;

  MeshRepositoryImpl({
    required P2PConnectionService connectionService,
    required MessageRepository messageRepository,
    required PeerRepository peerRepository,
    required SigningService signingService,
    required EncryptionService encryptionService,
    required UserPrefs userPrefs,
    required GameRepository gameRepository,
    required GroupRepository groupRepository,
  })  : _connectionService = connectionService,
        _messageRepository = messageRepository,
        _peerRepository = peerRepository,
        _signingService = signingService,
        _encryptionService = encryptionService {
    _packetCodec = PacketCodec(signingService);

    _messageRouter = MessageRouter(
      messageRepository: messageRepository,
      peerRepository: peerRepository,
      encryptionService: encryptionService,
      signingService: signingService,
      connectionService: connectionService,
      packetCodec: _packetCodec,
      groupRepository: groupRepository,
    );

    _handshakeHandler = HandshakeHandler(
      peerRepository: peerRepository,
      messageRepository: messageRepository,
      encryptionService: encryptionService,
      signingService: signingService,
      connectionService: connectionService,
      userPrefs: userPrefs,
      onResend: resendFailedMessage,
    );

    _gameHandler = GameHandler(
      gameRepository: gameRepository,
      peerRepository: peerRepository,
      signingService: signingService,
      encryptionService: encryptionService,
      connectionService: connectionService,
      packetCodec: _packetCodec,
    );

    _groupMgmtHandler = GroupManagementHandler(
      groupRepository: groupRepository,
      peerRepository: peerRepository,
      signingService: signingService,
      connectionService: connectionService,
    );
  }

  MessageRouter get messageRouter => _messageRouter;
  GameHandler get gameHandler => _gameHandler;
  GroupManagementHandler get groupManagementHandler => _groupMgmtHandler;

  @override
  Future<void> initialize() async {
    await _connectionService.startAdvertising();
    await _connectionService.startDiscovery();
  }

  @override
  Future<void> restartDiscovery() async {
    await _connectionService.stopDiscovery();
    await _connectionService.stopAdvertising();
    await _connectionService.startAdvertising();
    await _connectionService.startDiscovery();
  }

  @override
  void onConnectionEstablished(String endpointId) async {
    final existing = await _peerRepository.getPeer(endpointId);
    if (existing != null) {
      existing.isConnected = true;
      existing.lastSeen = DateTime.now().millisecondsSinceEpoch;
      await _peerRepository.savePeer(existing);
    } else {
      final peer = PeerEntity()
        ..deviceId = endpointId
        ..publicKey = ''
        ..lastSeen = DateTime.now().millisecondsSinceEpoch
        ..isConnected = true;
      await _peerRepository.savePeer(peer);
    }

    await _handshakeHandler.sendHandshake(endpointId);

    final peer = await _peerRepository.getPeer(endpointId);
    if (peer != null && peer.publicKey.isNotEmpty) {
      _gameHandler.resendPendingMoves(peer.publicKey);
    }
  }

  @override
  void onPeerDisconnected(String endpointId) async {
    final peer = await _peerRepository.getPeer(endpointId);
    if (peer != null) {
      if (peer.publicKey.isNotEmpty) {
        _gameHandler.onPeerDisconnected(peer.publicKey);
      }
      peer.isConnected = false;
      await _peerRepository.savePeer(peer);
    }
  }

  @override
  Future<void> onPayloadReceived(String endpointId, Uint8List payload) async {
    try {
      final jsonString = utf8.decode(payload);
      final packet = jsonDecode(jsonString);

      if (packet is! Map<String, dynamic>) return;

      if (packet.containsKey('d')) {
        final data = packet['d'];
        if (data is Map<String, dynamic> && data.containsKey('gameId')) {
          await _gameHandler.handleGameMovePacket(packet, endpointId);
        } else {
          await _messageRouter.handleMessagePacket(packet, endpointId);
        }
      } else {
        switch (packet['type']) {
          case 'handshake':
            await _handshakeHandler.handleHandshake(packet, endpointId);
          case 'nickname_update':
            await _handshakeHandler.handleNicknameUpdate(packet, endpointId);
          case 'group_management':
            if (_trackGroupMgmt(packet)) {
              await _groupMgmtHandler.handlePacket(packet, endpointId);
              _relayGroupMgmt(packet, endpointId);
            }
          case 'game_invite':
          case 'game_accept':
          case 'game_decline':
          case 'game_move_ack':
          case 'game_abandon':
            await _gameHandler.handleGamePacket(packet, endpointId);
          default:
            debugPrint('[MESH] Unknown packet type from $endpointId');
        }
      }
    } catch (e) {
      debugPrint('[MESH] Error parsing payload from $endpointId: $e');
    }
  }

  @override
  Future<void> broadcastMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final senderKey = await _signingService.publicKeyBase64;
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final dataMap = {
      'id': messageId,
      'sender': senderKey,
      'ts': timestamp,
      'payload': trimmed,
    };

    final packetBytes = await _packetCodec.signAndEncode(
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

    await _messageRepository.saveMessage(msgEntity);
    _messageRouter.trackSeenId(messageId);
    final success = await _messageRouter.floodToEndpoints(packetBytes);
    await _messageRepository.updateMessageStatus(
      messageId,
      success ? DeliveryStatus.sent : DeliveryStatus.failed,
    );
  }

  @override
  Future<void> sendDirectMessage(
    String recipientEd25519PubKey,
    String content,
  ) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    if (!_encryptionService.hasSharedSecret(recipientEd25519PubKey)) {
      final peer = await _peerRepository.getPeerByPublicKey(recipientEd25519PubKey);
      if (peer != null && peer.x25519PublicKey.isNotEmpty) {
        await _encryptionService.establishSharedSecret(
          recipientEd25519PubKey,
          peer.x25519PublicKey,
        );
      } else {
        debugPrint(
          '[MESH] Cannot send DM: no X25519 key for peer '
          '${recipientEd25519PubKey.substring(0, 8)}...',
        );
        return;
      }
    }

    final encrypted = await _encryptionService.encryptForPeer(
      recipientEd25519PubKey,
      trimmed,
    );

    final senderKey = await _signingService.publicKeyBase64;
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

    final packetBytes = await _packetCodec.signAndEncode(
      dataMap,
      transport: {'ttl': _kDefaultTtl, 'target': recipientEd25519PubKey},
    );

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

    await _messageRepository.saveMessage(msgEntity);
    _messageRouter.trackSeenId(messageId);
    final success = await _messageRouter.floodToEndpoints(packetBytes);
    await _messageRepository.updateMessageStatus(
      messageId,
      success ? DeliveryStatus.sent : DeliveryStatus.failed,
    );
  }

  @override
  Future<void> broadcastNicknameUpdate(String nickname) =>
      _handshakeHandler.broadcastNicknameUpdate(nickname);

  @override
  Future<void> createGroup(String name, List<String> memberPubKeys) =>
      _groupMgmtHandler.createGroup(name, memberPubKeys);

  @override
  Future<void> sendGroupMessage(String groupId, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final senderKey = await _signingService.publicKeyBase64;
    final messageId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetId = 'group:$groupId';

    final dataMap = {
      'id': messageId,
      'sender': senderKey,
      'ts': timestamp,
      'payload': trimmed,
    };

    final packetBytes = await _packetCodec.signAndEncode(
      dataMap,
      transport: {'ttl': _kDefaultTtl, 'target': targetId},
    );

    final msgEntity = MessageEntity()
      ..messageId = messageId
      ..senderId = senderKey
      ..targetId = targetId
      ..payload = trimmed
      ..timestamp = timestamp
      ..signature = ''
      ..ttl = _kDefaultTtl
      ..isMine = true
      ..deliveryStatus = DeliveryStatus.sending.index;

    await _messageRepository.saveMessage(msgEntity);
    _messageRouter.trackSeenId(messageId);
    final success = await _messageRouter.floodToEndpoints(packetBytes);
    await _messageRepository.updateMessageStatus(
      messageId,
      success ? DeliveryStatus.sent : DeliveryStatus.failed,
    );
  }

  @override
  Future<void> resendFailedMessage(MessageEntity msg) async {
    await _messageRepository.updateMessageStatus(
      msg.messageId,
      DeliveryStatus.sending,
    );

    try {
      final senderKey = await _signingService.publicKeyBase64;
      final isBroadcast = msg.targetId == 'BROADCAST';
      final isGroupMessage = msg.targetId.startsWith('group:');

      Map<String, dynamic> dataMap;
      Map<String, dynamic> transport;

      if (isBroadcast || isGroupMessage) {
        dataMap = {
          'id': msg.messageId,
          'sender': senderKey,
          'ts': msg.timestamp,
          'payload': msg.payload,
        };
        transport = {'ttl': _kDefaultTtl, 'target': msg.targetId};
      } else {
        if (!_encryptionService.hasSharedSecret(msg.targetId)) {
          final peer = await _peerRepository.getPeerByPublicKey(msg.targetId);
          if (peer != null && peer.x25519PublicKey.isNotEmpty) {
            await _encryptionService.establishSharedSecret(
              msg.targetId,
              peer.x25519PublicKey,
            );
          } else {
            debugPrint('[MESH] Resend failed: no X25519 key for ${msg.targetId.substring(0, 8)}...');
            await _messageRepository.updateMessageStatus(
              msg.messageId,
              DeliveryStatus.failed,
            );
            return;
          }
        }

        final encrypted = await _encryptionService.encryptForPeer(
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

      final packetBytes = await _packetCodec.signAndEncode(dataMap, transport: transport);
      final success = await _messageRouter.floodToEndpoints(packetBytes);
      await _messageRepository.updateMessageStatus(
        msg.messageId,
        success ? DeliveryStatus.sent : DeliveryStatus.failed,
      );
    } catch (e) {
      debugPrint('[MESH] Resend error for ${msg.messageId}: $e');
      await _messageRepository.updateMessageStatus(
        msg.messageId,
        DeliveryStatus.failed,
      );
    }
  }

  bool _trackGroupMgmt(Map<String, dynamic> packet) {
    final action = packet['action'];
    final groupId = packet['groupId'];
    final ts = packet['ts'];
    final key = '$action:$groupId:$ts';

    if (_seenGroupMgmtIds.contains(key)) return false;

    if (_seenGroupMgmtIds.length >= _kMaxSeenGroupMgmt) {
      _seenGroupMgmtIds.remove(_seenGroupMgmtIds.first);
    }
    _seenGroupMgmtIds.add(key);
    return true;
  }

  void _relayGroupMgmt(Map<String, dynamic> packet, String fromEndpointId) {
    final ttl = packet['ttl'];
    if (ttl is! int || ttl <= 0) return;

    final relayPacket = Map<String, dynamic>.from(packet);
    relayPacket['ttl'] = ttl - 1;
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(relayPacket)));

    for (final endpointId in _connectionService.connectedEndpoints) {
      if (endpointId == fromEndpointId) continue;
      try {
        _connectionService.sendPayload(endpointId, bytes);
      } catch (e) {
        debugPrint('[MESH] Group mgmt relay to $endpointId failed: $e');
      }
    }
  }
}
