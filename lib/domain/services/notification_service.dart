/// Abstracts local notification display and permission handling.
abstract interface class NotificationService {
  Future<bool> initialize();
  Future<bool> requestPermission();

  Future<void> showDirectMessageNotification({
    required String senderPublicKey,
    required String senderNickname,
    required String messagePreview,
  });

  Future<void> showGroupMessageNotification({
    required String groupId,
    required String groupName,
    required String senderNickname,
    required String messagePreview,
  });

  Future<void> showGameInviteNotification({
    required String inviterPublicKey,
    required String inviterNickname,
    required String gameType,
    required String gameId,
  });

  Future<void> showGroupInviteNotification({
    required String groupId,
    required String groupName,
    required String inviterNickname,
  });

  Future<void> cancelDirectChatNotifications(String peerPublicKey);
  Future<void> cancelGroupChatNotifications(String groupId);
}
