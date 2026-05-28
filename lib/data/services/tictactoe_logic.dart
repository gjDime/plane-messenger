class TicTacToeLogic {
  static const _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  static bool isValidMove(List<int> board, int position, int playerMark) {
    if (position < 0 || position > 8) return false;
    if (playerMark != 1 && playerMark != 2) return false;
    return board[position] == 0;
  }

  static List<int> applyMove(List<int> board, int position, int playerMark) {
    final newBoard = List<int>.from(board);
    newBoard[position] = playerMark;
    return newBoard;
  }

  /// Returns 0 if no winner, 1 if X wins, 2 if O wins.
  static int checkWinner(List<int> board) {
    for (final line in _winLines) {
      final a = board[line[0]];
      if (a != 0 && a == board[line[1]] && a == board[line[2]]) {
        return a;
      }
    }
    return 0;
  }

  static bool isBoardFull(List<int> board) => !board.contains(0);

  /// Odd move numbers are X (1), even are O (2).
  static int markForMoveNumber(int moveNumber) =>
      moveNumber.isOdd ? 1 : 2;

  static List<int> emptyBoard() => List.filled(9, 0);
}
