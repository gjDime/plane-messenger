import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plane_messenger/domain/services/notification_service.dart';

const _kMaxPreviewLength = 100;

// Deterministic hashing per category so re-issued notifications replace the prior one.
const _kDirectMessageBase = 1000000;
const _kGroupMessageBase = 2000000;
const _kGameInviteBase = 3000000;
const _kGroupInviteBase = 4000000;
const _kHashMod = 100000;

const _kMessagesChannelId = 'skymesh_messages';
const _kGamesChannelId = 'skymesh_games';
const _kGroupInvitesChannelId = 'skymesh_group_invites';

class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Payload from the most recent notification tap, consumed by the
  /// presentation layer for deferred navigation.
  static String? pendingNotificationPayload;

  @override
  Future<bool> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final settings = InitializationSettings(android: androidSettings);

    final result = await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final launchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse?.payload != null) {
      pendingNotificationPayload =
          launchDetails.notificationResponse!.payload;
    }

    return result ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<void> showDirectMessageNotification({
    required String senderPublicKey,
    required String senderNickname,
    required String messagePreview,
  }) async {
    final id = _directMessageId(senderPublicKey);
    final body = _truncate(messagePreview);
    final payload = 'dm:$senderPublicKey';

    await _plugin.show(
      id,
      senderNickname,
      body,
      _messagesDetails(),
      payload: payload,
    );
  }

  @override
  Future<void> showGroupMessageNotification({
    required String groupId,
    required String groupName,
    required String senderNickname,
    required String messagePreview,
  }) async {
    final id = _groupMessageId(groupId);
    final body = _truncate(messagePreview);
    final payload = 'group:$groupId';

    await _plugin.show(
      id,
      '$groupName - $senderNickname',
      body,
      _messagesDetails(),
      payload: payload,
    );
  }

  @override
  Future<void> showGameInviteNotification({
    required String inviterPublicKey,
    required String inviterNickname,
    required String gameType,
    required String gameId,
  }) async {
    final id = _gameInviteId(inviterPublicKey);
    final payload = 'game_invite:$inviterPublicKey:$gameId';

    final label = switch (gameType) {
      'color_memory' => 'Color Memory',
      'battleship' => 'Battleship',
      _ => 'Tic Tac Toe',
    };

    await _plugin.show(
      id,
      'Game Invite',
      '$inviterNickname wants to play $label!',
      _gamesDetails(),
      payload: payload,
    );
  }

  @override
  Future<void> showGroupInviteNotification({
    required String groupId,
    required String groupName,
    required String inviterNickname,
  }) async {
    final id = _groupInviteId(groupId);
    final payload = 'group_invite:$groupId';

    await _plugin.show(
      id,
      'Group Invite',
      '$inviterNickname invited you to "$groupName"',
      _groupInvitesDetails(),
      payload: payload,
    );
  }

  @override
  Future<void> cancelDirectChatNotifications(String peerPublicKey) =>
      _plugin.cancel(_directMessageId(peerPublicKey));

  @override
  Future<void> cancelGroupChatNotifications(String groupId) =>
      _plugin.cancel(_groupMessageId(groupId));

  static NotificationDetails _messagesDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _kMessagesChannelId,
          'Messages',
          channelDescription: 'Direct and group messages',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  static NotificationDetails _gamesDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _kGamesChannelId,
          'Game Invites',
          channelDescription: 'Game invite notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  static NotificationDetails _groupInvitesDetails() =>
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kGroupInvitesChannelId,
          'Group Invites',
          channelDescription: 'Group invite notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
      );

  static void _onNotificationTap(NotificationResponse response) {
    pendingNotificationPayload = response.payload;
    debugPrint('[NOTIF] Tap payload: ${response.payload}');
  }

  static int _directMessageId(String key) =>
      _kDirectMessageBase + key.hashCode.abs() % _kHashMod;

  static int _groupMessageId(String groupId) =>
      _kGroupMessageBase + groupId.hashCode.abs() % _kHashMod;

  static int _gameInviteId(String key) =>
      _kGameInviteBase + key.hashCode.abs() % _kHashMod;

  static int _groupInviteId(String groupId) =>
      _kGroupInviteBase + groupId.hashCode.abs() % _kHashMod;

  static String _truncate(String text) =>
      text.length > _kMaxPreviewLength
          ? '${text.substring(0, _kMaxPreviewLength)}...'
          : text;
}
