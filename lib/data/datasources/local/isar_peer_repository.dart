import 'package:isar/isar.dart';
import 'package:plane_messenger/data/datasources/local/isar_database.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';

class IsarPeerRepository implements PeerRepository {
  final IsarDatabase _db;

  IsarPeerRepository(this._db);

  @override
  Future<void> savePeer(PeerEntity peer) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.peerEntitys.put(peer);
    });
  }

  @override
  Future<PeerEntity?> getPeer(String deviceId) async {
    final isar = await _db.instance;
    return isar.peerEntitys.filter().deviceIdEqualTo(deviceId).findFirst();
  }

  @override
  Future<PeerEntity?> getPeerByPublicKey(String publicKey) async {
    final isar = await _db.instance;
    return isar.peerEntitys.filter().publicKeyEqualTo(publicKey).findFirst();
  }

  @override
  Future<void> deletePeer(String deviceId) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.peerEntitys.filter().deviceIdEqualTo(deviceId).deleteAll();
    });
  }

  @override
  Stream<List<PeerEntity>> watchPeers() async* {
    final isar = await _db.instance;
    yield* isar.peerEntitys.where().watch(fireImmediately: true);
  }

  @override
  Stream<int> watchUnreadCountForPeer(
    String peerPublicKey,
    String myPublicKey,
    int afterTimestamp,
  ) async* {
    final isar = await _db.instance;
    yield* isar.messageEntitys
        .filter()
        .senderIdEqualTo(peerPublicKey)
        .targetIdEqualTo(myPublicKey)
        .timestampGreaterThan(afterTimestamp)
        .watch(fireImmediately: true)
        .map((messages) => messages.length);
  }

  @override
  Future<void> markPeerAsRead(String deviceId) async {
    final isar = await _db.instance;
    final peer =
        await isar.peerEntitys.filter().deviceIdEqualTo(deviceId).findFirst();
    if (peer == null) return;
    peer.lastReadTimestamp = DateTime.now().millisecondsSinceEpoch;
    await isar.writeTxn(() async {
      await isar.peerEntitys.put(peer);
    });
  }

  @override
  Future<void> resetConnectionStatus() async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      final peers = await isar.peerEntitys.where().findAll();
      for (final peer in peers) {
        peer.isConnected = false;
      }
      await isar.peerEntitys.putAll(peers);
    });
  }
}
