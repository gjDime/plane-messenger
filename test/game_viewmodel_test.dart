import 'package:flutter_test/flutter_test.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/services/tictactoe_logic.dart';

void main() {
  group('GameViewModel helpers (pure logic)', () {
    // These test the same logic as GameViewModel.isMyTurn / amIPlayerX
    // without needing to mock all dependencies.

    const myKey = 'myPublicKeyBase64';
    const opponentKey = 'opponentPublicKeyBase64';

    GameSessionEntity makeSession({
      String currentTurnKey = myKey,
      String playerXKey = myKey,
      String playerOKey = opponentKey,
      String gameType = 'tictactoe',
      List<int>? board,
    }) {
      return GameSessionEntity()
        ..gameId = 'test-game-id'
        ..gameType = gameType
        ..playerXKey = playerXKey
        ..playerOKey = playerOKey
        ..status = GameStatus.active.index
        ..currentTurnKey = currentTurnKey
        ..board = board ?? TicTacToeLogic.emptyBoard()
        ..createdAt = 1000;
    }

    group('isMyTurn', () {
      test('returns true when currentTurnKey matches my key', () {
        final game = makeSession(currentTurnKey: myKey);
        expect(game.currentTurnKey == myKey, isTrue);
      });

      test('returns false when currentTurnKey is opponent', () {
        final game = makeSession(currentTurnKey: opponentKey);
        expect(game.currentTurnKey == myKey, isFalse);
      });
    });

    group('amIPlayerX', () {
      test('returns true when I am player X', () {
        final game = makeSession(playerXKey: myKey);
        expect(game.playerXKey == myKey, isTrue);
      });

      test('returns false when I am player O', () {
        final game = makeSession(playerXKey: opponentKey, playerOKey: myKey);
        expect(game.playerXKey == myKey, isFalse);
      });
    });

    group('GameSessionEntity status helper', () {
      test('gameStatus returns correct enum value', () {
        final session = GameSessionEntity()
          ..gameId = 'id'
          ..gameType = 'tictactoe'
          ..playerXKey = myKey
          ..playerOKey = opponentKey
          ..currentTurnKey = myKey
          ..board = TicTacToeLogic.emptyBoard()
          ..createdAt = 1000;

        session.gameStatus = GameStatus.pending;
        expect(session.status, GameStatus.pending.index);
        expect(session.gameStatus, GameStatus.pending);

        session.gameStatus = GameStatus.active;
        expect(session.gameStatus, GameStatus.active);

        session.gameStatus = GameStatus.completed;
        expect(session.gameStatus, GameStatus.completed);

        session.gameStatus = GameStatus.declined;
        expect(session.gameStatus, GameStatus.declined);

        session.gameStatus = GameStatus.abandoned;
        expect(session.gameStatus, GameStatus.abandoned);
      });
    });

    group('Game flow simulation', () {
      test('full game X wins with diagonal', () {
        var board = TicTacToeLogic.emptyBoard();

        // Move 1: X at center (4)
        expect(TicTacToeLogic.isValidMove(board, 4, 1), isTrue);
        board = TicTacToeLogic.applyMove(board, 4, 1);
        expect(TicTacToeLogic.checkWinner(board), 0);

        // Move 2: O at top-right (2)
        expect(TicTacToeLogic.isValidMove(board, 2, 2), isTrue);
        board = TicTacToeLogic.applyMove(board, 2, 2);
        expect(TicTacToeLogic.checkWinner(board), 0);

        // Move 3: X at top-left (0)
        board = TicTacToeLogic.applyMove(board, 0, 1);
        expect(TicTacToeLogic.checkWinner(board), 0);

        // Move 4: O at middle-right (5)
        board = TicTacToeLogic.applyMove(board, 5, 2);
        expect(TicTacToeLogic.checkWinner(board), 0);

        // Move 5: X at bottom-right (8) — completes diagonal
        board = TicTacToeLogic.applyMove(board, 8, 1);
        expect(TicTacToeLogic.checkWinner(board), 1); // X wins!
      });
    });

    group('Color Memory session helpers', () {
      test('color_memory session uses minimal board', () {
        final session = makeSession(gameType: 'color_memory', board: [0]);
        expect(session.gameType, 'color_memory');
        expect(session.board, [0]);
      });

      test('amIPlayerX works for color_memory sessions', () {
        final session = makeSession(
          gameType: 'color_memory',
          board: [0],
          playerXKey: myKey,
        );
        expect(session.playerXKey == myKey, isTrue);
      });
    });
  });
}
