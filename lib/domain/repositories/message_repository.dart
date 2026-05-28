import 'package:plane_messenger/data/models/message_entity.dart';

/// Persistence contract for messages.
abstract interface class MessageRepository {
  Future<void> saveMessage(MessageEntity message);
  Stream<List<MessageEntity>> watchMessages();
  Stream<List<MessageEntity>> watchMessagesForPeer(String peerPublicKey, String myPublicKey);
  Future<void> updateMessageStatus(String messageId, DeliveryStatus status);
  Future<List<MessageEntity>> getFailedMessagesForPeer(String peerPublicKey, String myPublicKey);
  Future<void> deleteMessagesForPeer(String peerPublicKey, String myPublicKey);
  Stream<List<MessageEntity>> watchMessagesForGroup(String groupTargetId, int afterTimestamp);
  Future<void> deleteMessagesForGroup(String groupTargetId);
}
