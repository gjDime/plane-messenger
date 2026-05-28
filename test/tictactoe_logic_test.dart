import 'package:flutter_test/flutter_test.dart';
import 'package:plane_messenger/data/services/tictactoe_logic.dart';

void main() {
  group('TicTacToeLogic', () {
    group('emptyBoard', () {
      test('returns 9 zeros', () {
        final board = TicTacToeLogic.emptyBoard();
        expect(board, hasLength(9));
        expect(board.every((c) => c == 0), isTrue);
      });
    });

    group('markForMoveNumber', () {
      test('odd moves are X (1)', () {
        expect(TicTacToeLogic.markForMoveNumber(1), 1);
        expect(TicTacToeLogic.markForMoveNumber(3), 1);
        expect(TicTacToeLogic.markForMoveNumber(5), 1);
      });

      test('even moves are O (2)', () {
        expect(TicTacToeLogic.markForMoveNumber(2), 2);
        expect(TicTacToeLogic.markForMoveNumber(4), 2);
        expect(TicTacToeLogic.markForMoveNumber(6), 2);
      });
    });

    group('isValidMove', () {
      test('valid move on empty cell', () {
        final board = TicTacToeLogic.emptyBoard();
        expect(TicTacToeLogic.isValidMove(board, 0, 1), isTrue);
        expect(TicTacToeLogic.isValidMove(board, 8, 2), isTrue);
      });

      test('invalid move on occupied cell', () {
        final board = TicTacToeLogic.emptyBoard();
        board[4] = 1;
        expect(TicTacToeLogic.isValidMove(board, 4, 2), isFalse);
      });

      test('invalid move out of range', () {
        final board = TicTacToeLogic.emptyBoard();
        expect(TicTacToeLogic.isValidMove(board, -1, 1), isFalse);
        expect(TicTacToeLogic.isValidMove(board, 9, 1), isFalse);
      });

      test('invalid player mark', () {
        final board = TicTacToeLogic.emptyBoard();
        expect(TicTacToeLogic.isValidMove(board, 0, 0), isFalse);
        expect(TicTacToeLogic.isValidMove(board, 0, 3), isFalse);
      });
    });

    group('applyMove', () {
      test('places mark on board', () {
        final board = TicTacToeLogic.emptyBoard();
        final newBoard = TicTacToeLogic.applyMove(board, 4, 1);
        expect(newBoard[4], 1);
        // Original board unchanged
        expect(board[4], 0);
      });
    });

    group('checkWinner', () {
      test('no winner on empty board', () {
        expect(TicTacToeLogic.checkWinner(TicTacToeLogic.emptyBoard()), 0);
      });

      // Rows
      test('X wins top row', () {
        final board = [1, 1, 1, 0, 0, 0, 0, 0, 0];
        expect(TicTacToeLogic.checkWinner(board), 1);
      });

      test('X wins middle row', () {
        final board = [0, 0, 0, 1, 1, 1, 0, 0, 0];
        expect(TicTacToeLogic.checkWinner(board), 1);
      });

      test('X wins bottom row', () {
        final board = [0, 0, 0, 0, 0, 0, 1, 1, 1];
        expect(TicTacToeLogic.checkWinner(board), 1);
      });

      // Columns
      test('O wins left column', () {
        final board = [2, 0, 0, 2, 0, 0, 2, 0, 0];
        expect(TicTacToeLogic.checkWinner(board), 2);
      });

      test('O wins middle column', () {
        final board = [0, 2, 0, 0, 2, 0, 0, 2, 0];
        expect(TicTacToeLogic.checkWinner(board), 2);
      });

      test('O wins right column', () {
        final board = [0, 0, 2, 0, 0, 2, 0, 0, 2];
        expect(TicTacToeLogic.checkWinner(board), 2);
      });

      // Diagonals
      test('X wins main diagonal', () {
        final board = [1, 0, 0, 0, 1, 0, 0, 0, 1];
        expect(TicTacToeLogic.checkWinner(board), 1);
      });

      test('O wins anti-diagonal', () {
        final board = [0, 0, 2, 0, 2, 0, 2, 0, 0];
        expect(TicTacToeLogic.checkWinner(board), 2);
      });

      test('no winner with mixed board', () {
        // X O X
        // X X O
        // O X O
        final board = [1, 2, 1, 1, 1, 2, 2, 1, 2];
        expect(TicTacToeLogic.checkWinner(board), 0);
      });
    });

    group('isBoardFull', () {
      test('empty board is not full', () {
        expect(TicTacToeLogic.isBoardFull(TicTacToeLogic.emptyBoard()), isFalse);
      });

      test('full board is full', () {
        final board = [1, 2, 1, 1, 1, 2, 2, 1, 2];
        expect(TicTacToeLogic.isBoardFull(board), isTrue);
      });

      test('partially filled board is not full', () {
        final board = [1, 0, 1, 0, 1, 0, 0, 0, 0];
        expect(TicTacToeLogic.isBoardFull(board), isFalse);
      });
    });

    group('draw detection', () {
      test('full board with no winner is a draw', () {
        // X O X
        // X X O
        // O X O
        final board = [1, 2, 1, 1, 1, 2, 2, 1, 2];
        expect(TicTacToeLogic.checkWinner(board), 0);
        expect(TicTacToeLogic.isBoardFull(board), isTrue);
      });
    });
  });
}
