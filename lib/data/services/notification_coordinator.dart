import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/core/active_screen_tracker.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/services/game_handler.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/data/services/message_router.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

class NotificationCoordinator {
  final NotificationService _notificationService;
  final ActiveScreenTracker _screenTracker;
  final MessageRouter _messageRouter;
  final GameHandler _gameHandler;
  final GroupManagementHandler _groupMgmtHandler;
  final PeerRepository _peerRepository;
  final GroupRepository _groupRepository;
  final SigningService _signingService;

  final List<StreamSubscription> _subscriptions = [];

  NotificationCoordinator({
    required NotificationService notificationService,
    required ActiveScreenTracker screenTracker,
    required MessageRouter messageRouter,
    required GameHandler gameHandler,
    required GroupManagementHandler groupMgmtHandler,
    required PeerRepository peerRepository,
    required GroupRepository groupRepository,
    required SigningService signingService,
  })  : _notificationService = notificationService,
        _screenTracker = screenTracker,
        _messageRouter = messageRouter,
        _gameHandler = gameHandler,
        _groupMgmtHandler = groupMgmtHandler,
        _peerRepository = peerRepository,
        _groupRepository = groupRepository,
        _signingService = signingService;

  Future<void> initialize() async {
    _subscriptions.add(
      _messageRouter.inboundMessages.listen(_onInboundMessage),
    );
    _subscriptions.add(
      _gameHandler.pendingInvites.listen(_onGameInvite),
    );
    _subscriptions.add(
      _groupMgmtHandler.pendingInvites.listen(_onGroupInvite),
    );
  }

  Future<void> _onInboundMessage(MessageEntity msg) async {
    try {
      final myKey = await _signingService.publicKeyBase64;
      if (msg.senderId == myKey) return;

      final peer = await _peerRepository.getPeerByPublicKey(msg.senderId);
      final senderNickname = peer?.nickname ?? 'Unknown';

      if (msg.targetId.startsWith('group:')) {
        final groupId = msg.targetId.substring(6);
        if (_screenTracker.isGroupChatActive(groupId)) return;

        final group = await _groupRepository.getGroup(groupId);
        final groupName = group?.name ?? 'Unknown Group';

        await _notificationService.showGroupMessageNotification(
          groupId: groupId,
          groupName: groupName,
          senderNickname: senderNickname,
          messagePreview: msg.payload,
        );
      } else {
        if (_screenTracker.isDirectChatActive(msg.senderId)) return;

        await _notificationService.showDirectMessageNotification(
          senderPublicKey: msg.senderId,
          senderNickname: senderNickname,
          messagePreview: msg.payload,
        );
      }
    } catch (e) {
      debugPrint('[NOTIF] Error handling inbound message: $e');
    }
  }

  Future<void> _onGameInvite(PendingGameInvite invite) async {
    try {
      if (_screenTracker.isDirectChatActive(invite.inviterKey)) return;

      final peer =
          await _peerRepository.getPeerByPublicKey(invite.inviterKey);
      final nickname = peer?.nickname ?? invite.inviterNickname ?? 'Unknown';

      await _notificationService.showGameInviteNotification(
        inviterPublicKey: invite.inviterKey,
        inviterNickname: nickname,
        gameType: invite.gameType,
        gameId: invite.gameId,
      );
    } catch (e) {
      debugPrint('[NOTIF] Error handling game invite: $e');
    }
  }

  Future<void> _onGroupInvite(PendingGroupInvite invite) async {
    try {
      final nickname = invite.inviterNickname ?? 'Unknown';

      await _notificationService.showGroupInviteNotification(
        groupId: invite.groupId,
        groupName: invite.groupName,
        inviterNickname: nickname,
      );
    } catch (e) {
      debugPrint('[NOTIF] Error handling group invite: $e');
    }
  }
}
