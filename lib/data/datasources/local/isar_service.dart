import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return Isar.open(
        [MessageEntitySchema, PeerEntitySchema],
        directory: dir.path,
        inspector: kDebugMode,
      );
    }

    final existing = Isar.getInstance();
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [MessageEntitySchema, PeerEntitySchema],
      directory: dir.path,
      inspector: kDebugMode,
    );
  }

  Future<void> saveMessage(MessageEntity message) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.messageEntitys.put(message);
    });
  }

  Stream<List<MessageEntity>> watchMessages() async* {
    final isar = await db;
    yield* isar.messageEntitys
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  /// Watches messages exchanged in a direct conversation between two peers.
  /// Returns messages where the sender/target pair matches either direction.
  Stream<List<MessageEntity>> watchMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async* {
    final isar = await db;
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

  /// Updates the delivery status of a message identified by [messageId].
  Future<void> updateMessageStatus(String messageId, int status) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final msg = await isar.messageEntitys
          .filter()
          .messageIdEqualTo(messageId)
          .findFirst();
      if (msg != null) {
        msg.deliveryStatus = status;
        await isar.messageEntitys.put(msg);
      }
    });
  }

  /// Returns all failed outgoing messages for a specific peer, sorted by
  /// timestamp ascending. Used for auto-resend on reconnection.
  Future<List<MessageEntity>> getFailedMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async {
    final isar = await db;
    return isar.messageEntitys
        .filter()
        .isMineEqualTo(true)
        .targetIdEqualTo(peerPublicKey)
        .deliveryStatusEqualTo(DeliveryStatus.failed.index)
        .sortByTimestamp()
        .findAll();
  }

  Future<void> savePeer(PeerEntity peer) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.peerEntitys.put(peer);
    });
  }

  Future<PeerEntity?> getPeer(String deviceId) async {
    final isar = await db;
    return isar.peerEntitys.filter().deviceIdEqualTo(deviceId).findFirst();
  }

  /// Finds a peer whose Ed25519 public key matches [publicKey], regardless of
  /// endpoint ID. Used to detect the same physical device connecting twice.
  Future<PeerEntity?> getPeerByPublicKey(String publicKey) async {
    final isar = await db;
    return isar.peerEntitys.filter().publicKeyEqualTo(publicKey).findFirst();
  }

  Future<void> deletePeer(String deviceId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.peerEntitys.filter().deviceIdEqualTo(deviceId).deleteAll();
    });
  }

  /// Deletes all messages exchanged between this device and a specific peer.
  Future<void> deleteMessagesForPeer(
    String peerPublicKey,
    String myPublicKey,
  ) async {
    final isar = await db;
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

  /// Watches the number of unread messages from a specific peer.
  Stream<int> watchUnreadCountForPeer(
    String peerPublicKey,
    String myPublicKey,
    int afterTimestamp,
  ) async* {
    final isar = await db;
    yield* isar.messageEntitys
        .filter()
        .senderIdEqualTo(peerPublicKey)
        .targetIdEqualTo(myPublicKey)
        .timestampGreaterThan(afterTimestamp)
        .watch(fireImmediately: true)
        .map((messages) => messages.length);
  }

  /// Marks all messages from a peer as read by updating the peer's
  /// [PeerEntity.lastReadTimestamp] to now.
  Future<void> markPeerAsRead(String deviceId) async {
    final isar = await db;
    final peer =
        await isar.peerEntitys.filter().deviceIdEqualTo(deviceId).findFirst();
    if (peer == null) return;
    peer.lastReadTimestamp = DateTime.now().millisecondsSinceEpoch;
    await isar.writeTxn(() async {
      await isar.peerEntitys.put(peer);
    });
  }

  Stream<List<PeerEntity>> watchPeers() async* {
    final isar = await db;
    yield* isar.peerEntitys.where().watch(fireImmediately: true);
  }

  /// Marks every stored peer as disconnected without deleting records.
  /// Called on startup to clear stale [isConnected] flags while preserving
  /// historical data (public key, nickname) for returning devices.
  Future<void> resetConnectionStatus() async {
    final isar = await db;
    await isar.writeTxn(() async {
      final peers = await isar.peerEntitys.where().findAll();
      for (final peer in peers) {
        peer.isConnected = false;
      }
      await isar.peerEntitys.putAll(peers);
    });
  }
}
