import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plane_messenger/data/models/color_memory_state.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/services/color_memory_logic.dart';
import 'package:plane_messenger/presentation/viewmodels/game_viewmodel.dart';
import 'package:plane_messenger/presentation/widgets/hsb_slider_picker.dart';

class ColorMemoryPage extends StatefulWidget {
  final GameViewModel viewModel;
  final String gameId;
  final String opponentName;

  const ColorMemoryPage({
    super.key,
    required this.viewModel,
    required this.gameId,
    required this.opponentName,
  });

  @override
  State<ColorMemoryPage> createState() => _ColorMemoryPageState();
}

class _ColorMemoryPageState extends State<ColorMemoryPage> {
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _showingColor = false;
  bool _guessSubmitted = false;
  bool _readyPressed = false;
  int? _lastDealedRound;
  GameSessionEntity? _currentGame;

  Color _pickerColor = _randomPickerColor();

  GameViewModel get _vm => widget.viewModel;

  static Color _randomPickerColor() {
    final rgb = ColorMemoryLogic.generateRandomColor();
    return Color.fromARGB(
        255, (rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF);
  }

  static Color _contrastTextColor(Color bg) {
    return bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    final game = _currentGame;
    if (game != null &&
        (game.gameStatus == GameStatus.active ||
            game.gameStatus == GameStatus.pending)) {
      _vm.abandonGame(game.gameId);
    }
    super.dispose();
  }

  void _startCountdown(int targetColor) {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 5;
      _showingColor = true;
      _guessSubmitted = false;
      _pickerColor = _randomPickerColor();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _showingColor = false;
          timer.cancel();
        }
      });
    });
  }

  void _submitGuess(String gameId, int round) {
    final r = (_pickerColor.r * 255).round();
    final g = (_pickerColor.g * 255).round();
    final b = (_pickerColor.b * 255).round();
    final guessInt = (r << 16) | (g << 8) | b;

    setState(() => _guessSubmitted = true);
    _vm.sendColorGuess(gameId, guessInt, round);
  }

  Color _intToColor(int rgb) {
    return Color.fromARGB(
        255, (rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameSessionEntity?>(
      stream: _vm.watchGame(widget.gameId),
      builder: (context, snapshot) {
        final game = snapshot.data;
        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Color Memory')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _currentGame = game;
        final state = ColorMemoryState.deserialize(game.colorGameData);

        return Scaffold(
          appBar: AppBar(
            title: Text('Color Memory vs ${widget.opponentName}'),
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
          body: _buildBody(context, game, state),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, GameSessionEntity game, ColorMemoryState? state) {
    if (game.gameStatus == GameStatus.pending) {
      return const Center(child: Text('Waiting for opponent to accept...'));
    }
    if (game.gameStatus == GameStatus.declined) {
      return _buildTerminalState(context, 'Invite declined', Colors.grey);
    }
    if (game.gameStatus == GameStatus.abandoned) {
      return _buildTerminalState(context, 'Game abandoned', Colors.grey);
    }

    if (state == null) {
      return const Center(child: Text('Initializing game...'));
    }

    if (game.gameStatus == GameStatus.completed) {
      return _buildGameOver(context, game, state);
    }

    final round = state.currentRound;
    final isPlayerX = _vm.amIPlayerX(game);
    final isDealer = ColorMemoryLogic.dealerIsPlayerX(round) == isPlayerX;

    final roundData =
        round <= state.rounds.length ? state.rounds[round - 1] : null;

    // Both-ready advanced the round; reset transient UI state.
    if (_readyPressed && (roundData == null || !roundData.isComplete)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showingColor = false;
            _guessSubmitted = false;
            _countdown = 0;
            _lastDealedRound = null;
            _readyPressed = false;
            _pickerColor = _randomPickerColor();
          });
        }
      });
    }

    if (roundData == null && isDealer) {
      if (_lastDealedRound != round) {
        _lastDealedRound = round;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final color = ColorMemoryLogic.generateRandomColor();
          _vm.sendRoundStart(widget.gameId, color, round);
          _startCountdown(color);
        });
      }
      return _buildWaitingPhase(context, state, 'Generating color...');
    }

    if (roundData == null && !isDealer) {
      return _buildWaitingPhase(
          context, state, 'Waiting for opponent to pick a color...');
    }

    final targetColor = roundData!.targetColor;

    if (_showingColor) {
      return _buildShowingPhase(context, state, targetColor);
    }

    final myGuess = isPlayerX ? roundData.xGuess : roundData.oGuess;

    if (!_guessSubmitted && myGuess == null && _countdown == 0) {
      if (!isDealer && _lastDealedRound != round) {
        _lastDealedRound = round;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startCountdown(targetColor);
        });
        return _buildWaitingPhase(context, state, 'Get ready...');
      }
      return _buildGuessingPhase(context, game, state, round);
    }

    if (myGuess != null || _guessSubmitted) {
      if (roundData.isComplete) {
        return _buildRoundResults(context, game, state, roundData, round);
      }
      return _buildWaitingPhase(
          context, state, 'Waiting for opponent\'s guess...');
    }

    return _buildGuessingPhase(context, game, state, round);
  }

  Widget _buildTerminalState(BuildContext context, String text, Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard(BuildContext context, ColorMemoryState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Round ${state.currentRound}/3',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 24),
          _buildScorePill(context, state),
        ],
      ),
    );
  }

  Widget _buildScorePill(BuildContext context, ColorMemoryState state) {
    final game = _currentGame;
    final isPlayerX = game != null && _vm.amIPlayerX(game);
    final myWon = isPlayerX ? state.xRoundsWon : state.oRoundsWon;
    final oppWon = isPlayerX ? state.oRoundsWon : state.xRoundsWon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$myWon - $oppWon',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildWaitingPhase(
      BuildContext context, ColorMemoryState state, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScoreboard(context, state),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildShowingPhase(
      BuildContext context, ColorMemoryState state, int targetColor) {
    return Column(
      children: [
        _buildScoreboard(context, state),
        Expanded(
          child: Container(
            color: _intToColor(targetColor),
            child: Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 20, color: Colors.black54),
                    Shadow(blurRadius: 4, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuessingPhase(BuildContext context, GameSessionEntity game,
      ColorMemoryState state, int round) {
    final opponentHint = _buildOpponentHint(context, game, state, round);
    final textColor = _contrastTextColor(_pickerColor);

    return Column(
      children: [
        _buildScoreboard(context, state),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _pickerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick the color you saw!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (opponentHint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        opponentHint,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HsbSliderPicker(
                color: _pickerColor,
                onColorChanged: (c) => setState(() => _pickerColor = c),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _submitGuess(game.gameId, round),
                  icon: const Icon(Icons.check),
                  label: const Text('Submit Guess'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  String? _buildOpponentHint(BuildContext context, GameSessionEntity game,
      ColorMemoryState state, int round) {
    if (round > state.rounds.length) return null;
    final roundData = state.rounds[round - 1];
    final isPlayerX = _vm.amIPlayerX(game);
    final opponentGuess = isPlayerX ? roundData.oGuess : roundData.xGuess;
    if (opponentGuess != null) return 'Opponent has submitted their guess';
    return null;
  }

  Widget _buildRoundResults(BuildContext context, GameSessionEntity game,
      ColorMemoryState state, ColorMemoryRound roundData, int round) {
    final isPlayerX = _vm.amIPlayerX(game);
    final myGuess = isPlayerX ? roundData.xGuess : roundData.oGuess;
    final oppGuess = isPlayerX ? roundData.oGuess : roundData.xGuess;
    final myDist = isPlayerX ? roundData.xDistance : roundData.oDistance;
    final oppDist = isPlayerX ? roundData.oDistance : roundData.xDistance;

    final roundWinner = roundData.winner;
    String resultText;
    Color resultColor;
    if (roundWinner == 'draw') {
      resultText = 'Draw!';
      resultColor = Colors.orange;
    } else if ((roundWinner == 'x' && isPlayerX) ||
        (roundWinner == 'o' && !isPlayerX)) {
      resultText = 'You won this round!';
      resultColor = Colors.green;
    } else {
      resultText = 'Opponent won this round!';
      resultColor = Colors.red;
    }

    final isMatchOver = state.xRoundsWon >= 2 || state.oRoundsWon >= 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScoreboard(context, state),
          const SizedBox(height: 12),
          Text(resultText,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: resultColor)),
          const SizedBox(height: 20),
          _buildLargeColorSwatch(
            context,
            label: 'Target',
            color: _intToColor(roundData.targetColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLargeColorSwatch(
                  context,
                  label: 'You',
                  color: _intToColor(myGuess ?? 0),
                  score: myDist != null
                      ? ColorMemoryLogic.scoreFromDistance(myDist)
                      : null,
                  height: 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLargeColorSwatch(
                  context,
                  label: 'Opponent',
                  color: _intToColor(oppGuess ?? 0),
                  score: oppDist != null
                      ? ColorMemoryLogic.scoreFromDistance(oppDist)
                      : null,
                  height: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!isMatchOver) ...[
            Builder(builder: (context) {
              final isPlayerX = _vm.amIPlayerX(game);
              final opponentReady =
                  isPlayerX ? roundData.oReady : roundData.xReady;

              return Column(
                children: [
                  if (opponentReady)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Opponent is ready',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _readyPressed
                        ? null
                        : () {
                            _vm.sendRoundReady(game.gameId, round);
                            setState(() => _readyPressed = true);
                          },
                    child: Text(
                        _readyPressed ? 'Waiting for opponent...' : 'Ready'),
                  ),
                ],
              );
            }),
          ] else
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Chat'),
            ),
        ],
      ),
    );
  }

  Widget _buildLargeColorSwatch(
    BuildContext context, {
    required String label,
    required Color color,
    double? score,
    double height = 120,
  }) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: score != null
              ? Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Score: ${score.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildGameOver(
      BuildContext context, GameSessionEntity game, ColorMemoryState state) {
    final isPlayerX = _vm.amIPlayerX(game);
    final matchWinner = state.matchWinner;
    final iWon = (matchWinner == 'x' && isPlayerX) ||
        (matchWinner == 'o' && !isPlayerX);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            iWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 64,
            color: iWon ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            iWon ? 'You Win!' : 'You Lose!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: iWon ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildScorePill(context, state),
          const SizedBox(height: 8),
          Text(
            'Best of 3',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ...state.rounds.asMap().entries.map(
                (e) => _buildRoundSummaryRow(
                    context, e.key + 1, e.value, isPlayerX),
              ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSummaryRow(BuildContext context, int roundNum,
      ColorMemoryRound round, bool isPlayerX) {
    final myGuess = isPlayerX ? round.xGuess : round.oGuess;
    final myDist = isPlayerX ? round.xDistance : round.oDistance;
    final oppDist = isPlayerX ? round.oDistance : round.xDistance;
    final myScore =
        myDist != null ? ColorMemoryLogic.scoreFromDistance(myDist) : null;
    final oppScore =
        oppDist != null ? ColorMemoryLogic.scoreFromDistance(oppDist) : null;
    final winner = round.winner;
    final iWon =
        (winner == 'x' && isPlayerX) || (winner == 'o' && !isPlayerX);
    final isDraw = winner == 'draw';

    final borderColor = isDraw
        ? Colors.orange
        : iWon
            ? Colors.green
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text('Round $roundNum',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _intToColor(round.targetColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          if (myGuess != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _intToColor(myGuess),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 3),
              ),
            )
          else
            const SizedBox(width: 48, height: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDraw
                  ? 'Draw'
                  : iWon
                      ? 'Won (${myScore?.toStringAsFixed(1)} vs ${oppScore?.toStringAsFixed(1)})'
                      : 'Lost (${myScore?.toStringAsFixed(1)} vs ${oppScore?.toStringAsFixed(1)})',
              style: TextStyle(color: borderColor),
            ),
          ),
        ],
      ),
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
