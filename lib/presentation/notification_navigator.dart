import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:plane_messenger/data/services/local_notification_service.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/main.dart';
import 'package:plane_messenger/presentation/pages/chat_page.dart';
import 'package:plane_messenger/presentation/pages/group_chat_page.dart';
import 'package:plane_messenger/presentation/viewmodels/chat_viewmodel.dart';
import 'package:plane_messenger/presentation/viewmodels/group_chat_viewmodel.dart';

class NotificationNavigator {
  NotificationNavigator._();

  static Future<void> handlePendingNavigation() async {
    final payload = LocalNotificationService.pendingNotificationPayload;
    if (payload == null) return;
    LocalNotificationService.pendingNotificationPayload = null;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final getIt = GetIt.instance;

    if (payload.startsWith('dm:')) {
      final pubKey = payload.substring(3);
      final peer = await getIt<PeerRepository>().getPeerByPublicKey(pubKey);
      if (peer == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            viewModel: getIt<ChatViewModel>(),
            peer: peer,
          ),
        ),
      );
    } else if (payload.startsWith('group:')) {
      final groupId = payload.substring(6);
      final group = await getIt<GroupRepository>().getGroup(groupId);
      if (group == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => GroupChatPage(
            viewModel: getIt<GroupChatViewModel>(),
            group: group,
          ),
        ),
      );
    } else if (payload.startsWith('game_invite:')) {
      final parts = payload.substring(12).split(':');
      if (parts.isEmpty) return;
      final pubKey = parts[0];
      final gameId = parts.length > 1 ? parts[1] : null;
      final peer = await getIt<PeerRepository>().getPeerByPublicKey(pubKey);
      if (peer == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            viewModel: getIt<ChatViewModel>(),
            peer: peer,
            pendingGameId: gameId,
          ),
        ),
      );
    }
    // group_invite: no-op — RadarPage handles via pending invite stream
  }
}
