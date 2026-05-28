import 'package:plane_messenger/data/models/game_move_entity.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';

/// Persistence contract for game sessions and moves.
abstract interface class GameRepository {
  Future<void> saveSession(GameSessionEntity session);
  Future<GameSessionEntity?> getSession(String gameId);
  Stream<GameSessionEntity?> watchSession(String gameId);
  Stream<List<GameSessionEntity>> watchActiveSessions();
  Future<List<GameSessionEntity>> getActiveSessionsForPeer(String peerPubKey);
  Future<void> deleteSession(String gameId);

  Future<void> saveMove(GameMoveEntity move);
  Future<List<GameMoveEntity>> getMovesForGame(String gameId);
  Future<GameMoveEntity?> getUnackedMove(String gameId);
  Future<void> markMoveAcked(String moveId);
}
