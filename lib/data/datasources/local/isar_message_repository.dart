import 'package:isar/isar.dart';
import 'package:plane_messenger/data/datasources/local/isar_database.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';

class IsarMessageRepository implements MessageRepository {
  final IsarDatabase _db;

  IsarMessageRepository(this._db);

  @override
  Future<void> saveMessage(MessageEntity message) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.messageEntitys.put(message);
    });
  }

  @override
  Stream<List<MessageEntity>> watchMessages() async* {
    final isar = await _db.instance;
    yield* isar.messageEntitys
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<MessageEntity>> watchMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async* {
    final isar = await _db.instance;
    yield* isar.messageEntitys
        .filter()
        .group(
          (q) => q.senderIdEqualTo(peerPublicKey).targetIdEqualTo(myPublicKey),
        )
        .or()
        .group(
          (q) => q.senderIdEqualTo(myPublicKey).targetIdEqualTo(peerPublicKey),
        )
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> updateMessageStatus(String messageId, DeliveryStatus status) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      final msg = await isar.messageEntitys
          .filter()
          .messageIdEqualTo(messageId)
          .findFirst();
      if (msg != null) {
        msg.deliveryStatus = status.index;
        await isar.messageEntitys.put(msg);
      }
    });
  }

  @override
  Future<List<MessageEntity>> getFailedMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async {
    final isar = await _db.instance;
    return isar.messageEntitys
        .filter()
        .isMineEqualTo(true)
        .targetIdEqualTo(peerPublicKey)
        .deliveryStatusEqualTo(DeliveryStatus.failed.index)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<void> deleteMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.messageEntitys
          .filter()
          .group(
            (q) =>
                q.senderIdEqualTo(peerPublicKey).targetIdEqualTo(myPublicKey),
          )
          .or()
          .group(
            (q) =>
                q.senderIdEqualTo(myPublicKey).targetIdEqualTo(peerPublicKey),
          )
          .deleteAll();
    });
  }

  @override
  Stream<List<MessageEntity>> watchMessagesForGroup(
    String groupTargetId,
    int afterTimestamp,
  ) async* {
    final isar = await _db.instance;
    yield* isar.messageEntitys
        .filter()
        .targetIdEqualTo(groupTargetId)
        .timestampGreaterThan(afterTimestamp, include: true)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> deleteMessagesForGroup(String groupTargetId) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.messageEntitys
          .filter()
          .targetIdEqualTo(groupTargetId)
          .deleteAll();
    });
  }
}
