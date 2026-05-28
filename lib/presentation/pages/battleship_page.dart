import 'package:flutter/material.dart';
import 'package:plane_messenger/data/models/battleship_state.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/services/battleship_logic.dart';
import 'package:plane_messenger/presentation/viewmodels/game_viewmodel.dart';

class BattleshipPage extends StatefulWidget {
  final GameViewModel viewModel;
  final String gameId;
  final String opponentName;

  const BattleshipPage({
    super.key,
    required this.viewModel,
    required this.gameId,
    required this.opponentName,
  });

  @override
  State<BattleshipPage> createState() => _BattleshipPageState();
}

class _BattleshipPageState extends State<BattleshipPage> {
  GameSessionEntity? _currentGame;
  GameViewModel get _vm => widget.viewModel;

  // Placement state
  bool _horizontalPlacement = true;
  final List<ShipPlacement> _placedShips = [];
  bool _readySent = false;

  // Gameplay state — true while the "Attack" button is held
  bool _showAttackBoard = false;

  /// The fleet templates not yet placed on the board.
  List<Map<String, dynamic>> get _unplacedShips {
    final fleet = BattleshipLogic.standardFleet();
    final placedTypes = _placedShips.map((s) => s.type).toList();
    return fleet.where((f) {
      final idx = placedTypes.indexOf(f['type'] as String);
      if (idx != -1) {
        placedTypes.removeAt(idx);
        return false;
      }
      return true;
    }).toList();
  }

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
            appBar: AppBar(title: const Text('Battleship')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _currentGame = game;
        final state = BattleshipState.deserialize(game.colorGameData);

        return Scaffold(
          appBar: AppBar(
            title: Text('Battleship vs ${widget.opponentName}'),
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
      BuildContext context, GameSessionEntity game, BattleshipState? state) {
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

    // Active game
    if (state.phase == 'placing') {
      return _buildPlacingPhase(context, game, state);
    }
    return _buildGameplayPhase(context, game, state);
  }

  // ---------------------------------------------------------------------------
  // Placing phase
  // ---------------------------------------------------------------------------

  Widget _buildPlacingPhase(
      BuildContext context, GameSessionEntity game, BattleshipState state) {
    final isPlayerX = _vm.amIPlayerX(game);
    final myReady = isPlayerX ? state.xReady : state.oReady;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            myReady ? 'Waiting for opponent...' : 'Place your ships',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildPlacementGrid(context),
          ),
        ),
        if (!myReady) ...[
          _buildShipDock(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Horizontal')),
                      ButtonSegment(value: false, label: Text('Vertical')),
                    ],
                    selected: {_horizontalPlacement},
                    onSelectionChanged: (v) =>
                        setState(() => _horizontalPlacement = v.first),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _placedShips.length == 5 && !_readySent
                    ? () {
                        setState(() => _readySent = true);
                        _vm.sendShipPlacement(
                            game.gameId, List.from(_placedShips));
                      }
                    : null,
                child: const Text('Ready'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlacementGrid(BuildContext context) {
    final shipCells = <int, ShipPlacement>{};
    for (final ship in _placedShips) {
      for (final cell in ship.cellIndices) {
        shipCells[cell] = ship;
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final ship = shipCells[index];
          final hasShip = ship != null;

          return DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              return _canPlaceAt(details.data, index);
            },
            onAcceptWithDetails: (details) {
              _placeShip(details.data, index);
            },
            builder: (context, candidateData, rejectedData) {
              final isHighlighted = candidateData.isNotEmpty;
              return GestureDetector(
                onTap: hasShip
                    ? () {
                        setState(() {
                          _placedShips
                              .removeWhere((s) => s.type == ship.type);
                        });
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: hasShip
                        ? Colors.blueGrey.shade700
                        : isHighlighted
                            ? Colors.blue.shade100
                            : Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: hasShip
                      ? Center(
                          child: Text(
                            ship.type[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShipDock(BuildContext context) {
    final unplaced = _unplacedShips;
    if (unplaced.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'All ships placed! Tap a ship on the grid to remove it.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: unplaced.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final ship = unplaced[i];
          return Draggable<Map<String, dynamic>>(
            data: ship,
            feedback: Material(
              color: Colors.transparent,
              child: _buildShipChip(ship, dragging: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildShipChip(ship),
            ),
            child: _buildShipChip(ship),
          );
        },
      ),
    );
  }

  Widget _buildShipChip(Map<String, dynamic> ship, {bool dragging = false}) {
    final name = ship['type'] as String;
    final length = ship['length'] as int;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dragging ? Colors.blueGrey.shade400 : Colors.blueGrey.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$name ($length)',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  bool _canPlaceAt(Map<String, dynamic> shipData, int anchorIndex) {
    final length = shipData['length'] as int;
    final row = anchorIndex ~/ 10;
    final col = anchorIndex % 10;

    if (_horizontalPlacement) {
      if (col + length > 10) return false;
    } else {
      if (row + length > 10) return false;
    }

    final newShip = ShipPlacement(
      type: shipData['type'] as String,
      length: length,
      startRow: row,
      startCol: col,
      horizontal: _horizontalPlacement,
    );

    final occupiedByOthers = <int>{};
    for (final ship in _placedShips) {
      if (ship.type == newShip.type) continue;
      occupiedByOthers.addAll(ship.cellIndices);
    }

    for (final cell in newShip.cellIndices) {
      if (occupiedByOthers.contains(cell)) return false;
    }

    return true;
  }

  void _placeShip(Map<String, dynamic> shipData, int anchorIndex) {
    final row = anchorIndex ~/ 10;
    final col = anchorIndex % 10;
    final type = shipData['type'] as String;

    setState(() {
      _placedShips.removeWhere((s) => s.type == type);
      _placedShips.add(ShipPlacement(
        type: type,
        length: shipData['length'] as int,
        startRow: row,
        startCol: col,
        horizontal: _horizontalPlacement,
      ));
    });
  }

  // ---------------------------------------------------------------------------
  // Gameplay phase
  // ---------------------------------------------------------------------------

  Widget _buildGameplayPhase(
      BuildContext context, GameSessionEntity game, BattleshipState state) {
    final isPlayerX = _vm.amIPlayerX(game);
    final isMyTurn = _vm.isMyTurn(game);

    final myShips = isPlayerX ? state.xShips : state.oShips;
    final opponentShips = isPlayerX ? state.oShips : state.xShips;
    final myShots = isPlayerX ? state.xShots : state.oShots; // shots I fired
    final opponentShots = isPlayerX ? state.oShots : state.xShots; // shots fired at me

    final myShipsRemaining =
        myShips.where((s) => !BattleshipState.isSunk(s, opponentShots)).length;
    final oppShipsRemaining =
        opponentShips.where((s) => !BattleshipState.isSunk(s, myShots)).length;

    return Column(
      children: [
        _buildStatusBar(context, isMyTurn, myShipsRemaining, oppShipsRemaining),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _showAttackBoard
                ? _buildAttackGrid(context, opponentShips, myShots, isMyTurn,
                    game.gameId)
                : _buildMyFleetGrid(context, myShips, opponentShots),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onLongPressStart: (_) => setState(() => _showAttackBoard = true),
              onLongPressEnd: (_) => setState(() => _showAttackBoard = false),
              child: ElevatedButton.icon(
                onPressed: null, // tap does nothing; long-press toggles
                icon: Icon(_showAttackBoard ? Icons.shield : Icons.gps_fixed),
                label: Text(_showAttackBoard
                    ? 'Viewing Attack Board'
                    : 'Hold to view Attack Board'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: _showAttackBoard
                      ? Colors.red.shade100
                      : Colors.blueGrey.shade100,
                  disabledForegroundColor:
                      _showAttackBoard ? Colors.red.shade800 : Colors.blueGrey.shade800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, bool isMyTurn,
      int myShipsRemaining, int oppShipsRemaining) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isMyTurn ? 'Your turn' : "Opponent's turn",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isMyTurn ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              _buildShipCount(context, 'You', myShipsRemaining, Colors.blue),
              const SizedBox(width: 12),
              _buildShipCount(
                  context, 'Opp', oppShipsRemaining, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipCount(
      BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMyFleetGrid(BuildContext context, List<ShipPlacement> myShips,
      List<int> opponentShots) {
    final shipCells = <int, ShipPlacement>{};
    for (final ship in myShips) {
      for (final cell in ship.cellIndices) {
        shipCells[cell] = ship;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('My Fleet',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                final ship = shipCells[index];
                final wasShot = opponentShots.contains(index);
                final isHit = wasShot && ship != null;
                final isMiss = wasShot && ship == null;
                final isSunk =
                    ship != null && BattleshipState.isSunk(ship, opponentShots);

                Color cellColor;
                Widget? child;

                if (isSunk) {
                  cellColor = Colors.red.shade900;
                  child = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isHit) {
                  cellColor = Colors.red.shade600;
                  child = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isMiss) {
                  cellColor = Colors.blueGrey.shade50;
                  child = Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  );
                } else if (ship != null) {
                  cellColor = Colors.blueGrey.shade700;
                } else {
                  cellColor = Colors.blueGrey.shade100;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(child: child),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttackGrid(
    BuildContext context,
    List<ShipPlacement> opponentShips,
    List<int> myShots,
    bool isMyTurn,
    String gameId,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('Attack Board',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.red)),
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                final wasShot = myShots.contains(index);
                final isHit = wasShot &&
                    BattleshipState.isHit(opponentShips, index);
                final isMiss = wasShot && !isHit;
                final ship = BattleshipLogic.shipAt(opponentShips, index);
                final isSunk = ship != null &&
                    BattleshipState.isSunk(ship, myShots);
                final canFire = isMyTurn && !wasShot;

                Color cellColor;
                Widget? child;

                if (isSunk) {
                  cellColor = Colors.red.shade900;
                  child = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isHit) {
                  cellColor = Colors.red.shade600;
                  child = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isMiss) {
                  cellColor = Colors.blueGrey.shade50;
                  child = Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  );
                } else {
                  cellColor = canFire
                      ? Colors.blue.shade50
                      : Colors.blueGrey.shade100;
                }

                return GestureDetector(
                  onTap: canFire
                      ? () => _vm.sendBattleshipShot(gameId, index)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(2),
                      border: canFire
                          ? Border.all(
                              color: Colors.blue.shade300,
                              width: 0.5,
                            )
                          : null,
                    ),
                    child: Center(child: child),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Game over phase
  // ---------------------------------------------------------------------------

  Widget _buildGameOver(
      BuildContext context, GameSessionEntity game, BattleshipState state) {
    final iWon = game.winnerKey == _vm.myPublicKey;
    final isPlayerX = _vm.amIPlayerX(game);
    final myShips = isPlayerX ? state.xShips : state.oShips;
    final opponentShips = isPlayerX ? state.oShips : state.xShips;
    final myShots = isPlayerX ? state.xShots : state.oShots;
    final opponentShots = isPlayerX ? state.oShots : state.xShots;

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
          const SizedBox(height: 24),
          Text('Your Fleet',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          _buildRevealGrid(context, myShips, opponentShots),
          const SizedBox(height: 16),
          Text('Opponent\'s Fleet',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          _buildRevealGrid(context, opponentShips, myShots),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealGrid(BuildContext context, List<ShipPlacement> ships,
      List<int> shotsAgainst) {
    final shipCells = <int, ShipPlacement>{};
    for (final ship in ships) {
      for (final cell in ship.cellIndices) {
        shipCells[cell] = ship;
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final ship = shipCells[index];
          final wasShot = shotsAgainst.contains(index);
          final isHit = wasShot && ship != null;
          final isMiss = wasShot && ship == null;
          final isSunk =
              ship != null && BattleshipState.isSunk(ship, shotsAgainst);

          Color cellColor;
          Widget? child;

          if (isSunk) {
            cellColor = Colors.red.shade900;
            child = const Icon(Icons.close, color: Colors.white, size: 12);
          } else if (isHit) {
            cellColor = Colors.red.shade600;
            child = const Icon(Icons.close, color: Colors.white, size: 12);
          } else if (ship != null) {
            cellColor = Colors.blueGrey.shade600;
          } else if (isMiss) {
            cellColor = Colors.blueGrey.shade50;
            child = Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            );
          } else {
            cellColor = Colors.blueGrey.shade100;
          }

          return Container(
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(child: child),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared
  // ---------------------------------------------------------------------------

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
