import 'package:flutter/material.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/presentation/viewmodels/game_viewmodel.dart';

class GamePage extends StatefulWidget {
  final GameViewModel viewModel;
  final String gameId;
  final String opponentName;

  const GamePage({
    super.key,
    required this.viewModel,
    required this.gameId,
    required this.opponentName,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameSessionEntity? _currentGame;

  GameViewModel get _vm => widget.viewModel;

  @override
  void dispose() {
    final game = _currentGame;
    if (game != null &&
        (game.gameStatus == GameStatus.active ||
            game.gameStatus == GameStatus.pending)) {
      _vm.abandonGame(game.gameId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameSessionEntity?>(
      stream: _vm.watchGame(widget.gameId),
      builder: (context, snapshot) {
        final game = snapshot.data;
        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tic Tac Toe')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _currentGame = game;

        return Scaffold(
          appBar: AppBar(
            title: Text('Tic Tac Toe vs ${widget.opponentName}'),
            actions: [
              if (game.gameStatus == GameStatus.active ||
                  game.gameStatus == GameStatus.pending)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'abandon') _confirmAbandon(context, game);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'abandon',
                      child: Text('Abandon Game'),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, game),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GameSessionEntity game) {
    final isCompleted = game.gameStatus == GameStatus.completed ||
        game.gameStatus == GameStatus.abandoned ||
        game.gameStatus == GameStatus.declined;

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildStatusText(context, game),
        const SizedBox(height: 24),
        _buildBoard(context, game),
        const SizedBox(height: 24),
        if (isCompleted) _buildGameOverSection(context, game),
      ],
    );
  }

  Widget _buildStatusText(BuildContext context, GameSessionEntity game) {
    String text;
    Color color = Theme.of(context).colorScheme.onSurface;

    switch (game.gameStatus) {
      case GameStatus.pending:
        text = 'Waiting for opponent...';
      case GameStatus.active:
        if (_vm.isMyTurn(game)) {
          text = 'Your turn';
          color = Colors.green;
        } else {
          text = 'Waiting for ${widget.opponentName}...';
        }
      case GameStatus.completed:
        if (game.result == 'draw') {
          text = "It's a draw!";
          color = Colors.orange;
        } else if (game.winnerKey == _vm.myPublicKey) {
          text = 'You win!';
          color = Colors.green;
        } else {
          text = 'You lose!';
          color = Colors.red;
        }
      case GameStatus.abandoned:
        text = 'Game abandoned';
        color = Colors.grey;
      case GameStatus.declined:
        text = 'Invite declined';
        color = Colors.grey;
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
    );
  }

  Widget _buildBoard(BuildContext context, GameSessionEntity game) {
    final isMyTurn = _vm.isMyTurn(game);
    final isActive = game.gameStatus == GameStatus.active;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.count(
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: List.generate(9, (index) {
            final cell = game.board[index];
            final canTap = isActive && isMyTurn && cell == 0;

            return GestureDetector(
              onTap: canTap
                  ? () => _vm.makeMove(game.gameId, index)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: canTap
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: _buildCellContent(cell),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCellContent(int cell) {
    if (cell == 0) return const SizedBox.shrink();
    return Text(
      cell == 1 ? 'X' : 'O',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: cell == 1 ? Colors.blue : Colors.red,
      ),
    );
  }

  Widget _buildGameOverSection(BuildContext context, GameSessionEntity game) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Back to Chat'),
    );
  }

  void _confirmAbandon(BuildContext context, GameSessionEntity game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandon Game?'),
        content: const Text('Are you sure you want to abandon this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _vm.abandonGame(game.gameId);
            },
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }
}
