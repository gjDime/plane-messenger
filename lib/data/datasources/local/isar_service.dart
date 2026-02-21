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
        // Only enable the Isar Inspector in debug builds
        inspector: kDebugMode,
      );
    }

    // Return the existing instance; re-open if it was somehow closed
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

  /// Deletes the peer record identified by [deviceId].
  Future<void> deletePeer(String deviceId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.peerEntitys.filter().deviceIdEqualTo(deviceId).deleteAll();
    });
  }

  Stream<List<PeerEntity>> watchPeers() async* {
    final isar = await db;
    yield* isar.peerEntitys.where().watch(fireImmediately: true);
  }

  /// Marks every stored peer as disconnected without deleting the records.
  /// Called on startup so stale [isConnected] flags from the previous session
  /// are cleared while historical data (public key, nickname) is preserved.
  /// When a known device reconnects, [_handleHandshake] matches it by public
  /// key and reuses the existing record in-place.
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
