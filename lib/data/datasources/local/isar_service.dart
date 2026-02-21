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

  Stream<List<PeerEntity>> watchPeers() async* {
    final isar = await db;
    yield* isar.peerEntitys.where().watch(fireImmediately: true);
  }
}
