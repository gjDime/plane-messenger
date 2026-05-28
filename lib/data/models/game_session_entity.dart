import 'package:isar/isar.dart';

part 'game_session_entity.g.dart';

/// Status lifecycle for a game session.
enum GameStatus { pending, active, completed, declined, abandoned }

@collection
class GameSessionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String gameId; // UUID v4

  late String gameType; // "tictactoe" or "color_memory"
  late String playerXKey; // Ed25519 pubkey — inviter, plays X, goes first
  late String playerOKey; // Ed25519 pubkey — acceptor, plays O

  String? playerXNickname;
  String? playerONickname;

  int status = 0; // GameStatus enum ordinal

  late String currentTurnKey; // pubkey of player whose turn it is
  String? winnerKey; // null if ongoing or draw
  String result = 'none'; // 'none', 'win', 'draw', 'abandoned'

  late List<int> board; // 9 ints: 0=empty, 1=X, 2=O (unused for color_memory)
  int moveCount = 0;

  String colorGameData = ''; // JSON-serialized ColorMemoryState for color_memory games

  late int createdAt;
  int lastMoveAt = 0;

  @ignore
  GameStatus get gameStatus =>
      (status >= 0 && status < GameStatus.values.length)
          ? GameStatus.values[status]
          : GameStatus.pending;
  set gameStatus(GameStatus s) => status = s.index;
}
