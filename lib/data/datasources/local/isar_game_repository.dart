import 'package:isar/isar.dart';
import 'package:plane_messenger/data/datasources/local/isar_database.dart';
import 'package:plane_messenger/data/models/game_move_entity.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/domain/repositories/game_repository.dart';

class IsarGameRepository implements GameRepository {
  final IsarDatabase _db;

  IsarGameRepository(this._db);

  @override
  Future<void> saveSession(GameSessionEntity session) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.gameSessionEntitys.put(session);
    });
  }

  @override
  Future<GameSessionEntity?> getSession(String gameId) async {
    final isar = await _db.instance;
    return isar.gameSessionEntitys
        .filter()
        .gameIdEqualTo(gameId)
        .findFirst();
  }

  @override
  Stream<GameSessionEntity?> watchSession(String gameId) async* {
    final isar = await _db.instance;
    yield* isar.gameSessionEntitys
        .filter()
        .gameIdEqualTo(gameId)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }

  @override
  Stream<List<GameSessionEntity>> watchActiveSessions() async* {
    final isar = await _db.instance;
    yield* isar.gameSessionEntitys
        .filter()
        .group((q) => q
            .statusEqualTo(GameStatus.pending.index)
            .or()
            .statusEqualTo(GameStatus.active.index))
        .watch(fireImmediately: true);
  }

  @override
  Future<List<GameSessionEntity>> getActiveSessionsForPeer(
    String peerPubKey,
  ) async {
    final isar = await _db.instance;
    return isar.gameSessionEntitys
        .filter()
        .group((q) => q
            .statusEqualTo(GameStatus.active.index)
            .or()
            .statusEqualTo(GameStatus.pending.index))
        .group((q) => q
            .playerXKeyEqualTo(peerPubKey)
            .or()
            .playerOKeyEqualTo(peerPubKey))
        .findAll();
  }

  @override
  Future<void> deleteSession(String gameId) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.gameSessionEntitys
          .filter()
          .gameIdEqualTo(gameId)
          .deleteAll();
      await isar.gameMoveEntitys
          .filter()
          .gameIdEqualTo(gameId)
          .deleteAll();
    });
  }

  @override
  Future<void> saveMove(GameMoveEntity move) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.gameMoveEntitys.put(move);
    });
  }

  @override
  Future<List<GameMoveEntity>> getMovesForGame(String gameId) async {
    final isar = await _db.instance;
    return isar.gameMoveEntitys
        .filter()
        .gameIdEqualTo(gameId)
        .sortByMoveNumber()
        .findAll();
  }

  @override
  Future<GameMoveEntity?> getUnackedMove(String gameId) async {
    final isar = await _db.instance;
    return isar.gameMoveEntitys
        .filter()
        .gameIdEqualTo(gameId)
        .ackedEqualTo(false)
        .sortByTimestamp()
        .findFirst();
  }

  @override
  Future<void> markMoveAcked(String moveId) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      final move = await isar.gameMoveEntitys
          .filter()
          .moveIdEqualTo(moveId)
          .findFirst();
      if (move != null) {
        move.acked = true;
        await isar.gameMoveEntitys.put(move);
      }
    });
  }
}
