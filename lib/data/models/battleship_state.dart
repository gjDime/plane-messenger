import 'dart:convert';

/// Represents a single ship placed on the Battleship grid.
class ShipPlacement {
  final String type;
  final int length;
  final int startRow;
  final int startCol;
  final bool horizontal;

  const ShipPlacement({
    required this.type,
    required this.length,
    required this.startRow,
    required this.startCol,
    required this.horizontal,
  });

  /// Returns the list of cell indices (0-99) this ship occupies.
  List<int> get cellIndices {
    return List.generate(length, (i) {
      if (horizontal) {
        return startRow * 10 + startCol + i;
      } else {
        return (startRow + i) * 10 + startCol;
      }
    });
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'length': length,
        'startRow': startRow,
        'startCol': startCol,
        'horizontal': horizontal,
      };

  factory ShipPlacement.fromJson(Map<String, dynamic> json) {
    return ShipPlacement(
      type: json['type'] as String,
      length: json['length'] as int,
      startRow: json['startRow'] as int,
      startCol: json['startCol'] as int,
      horizontal: json['horizontal'] as bool,
    );
  }
}

/// Full state for a Battleship game, serialized to colorGameData.
class BattleshipState {
  final String phase; // 'placing' | 'gameplay' | 'completed'
  final bool xReady;
  final bool oReady;
  final List<ShipPlacement> xShips;
  final List<ShipPlacement> oShips;
  final List<int> xShots; // shots fired by X (at O's board)
  final List<int> oShots; // shots fired by O (at X's board)

  const BattleshipState({
    required this.phase,
    required this.xReady,
    required this.oReady,
    required this.xShips,
    required this.oShips,
    required this.xShots,
    required this.oShots,
  });

  /// Whether [cellIndex] is a hit on the given [ships].
  static bool isHit(List<ShipPlacement> ships, int cellIndex) {
    for (final ship in ships) {
      if (ship.cellIndices.contains(cellIndex)) return true;
    }
    return false;
  }

  /// Whether [ship] is fully sunk given the [shots] fired at it.
  static bool isSunk(ShipPlacement ship, List<int> shots) {
    return ship.cellIndices.every(shots.contains);
  }

  /// Whether all [ships] are sunk by [shots].
  static bool allSunk(List<ShipPlacement> ships, List<int> shots) {
    return ships.every((ship) => isSunk(ship, shots));
  }

  BattleshipState copyWith({
    String? phase,
    bool? xReady,
    bool? oReady,
    List<ShipPlacement>? xShips,
    List<ShipPlacement>? oShips,
    List<int>? xShots,
    List<int>? oShots,
  }) {
    return BattleshipState(
      phase: phase ?? this.phase,
      xReady: xReady ?? this.xReady,
      oReady: oReady ?? this.oReady,
      xShips: xShips ?? this.xShips,
      oShips: oShips ?? this.oShips,
      xShots: xShots ?? this.xShots,
      oShots: oShots ?? this.oShots,
    );
  }

  Map<String, dynamic> toJson() => {
        'phase': phase,
        'xReady': xReady,
        'oReady': oReady,
        'xShips': xShips.map((s) => s.toJson()).toList(),
        'oShips': oShips.map((s) => s.toJson()).toList(),
        'xShots': xShots,
        'oShots': oShots,
      };

  factory BattleshipState.fromJson(Map<String, dynamic> json) {
    return BattleshipState(
      phase: json['phase'] as String,
      xReady: json['xReady'] as bool,
      oReady: json['oReady'] as bool,
      xShips: (json['xShips'] as List)
          .map((s) => ShipPlacement.fromJson(s as Map<String, dynamic>))
          .toList(),
      oShips: (json['oShips'] as List)
          .map((s) => ShipPlacement.fromJson(s as Map<String, dynamic>))
          .toList(),
      xShots: (json['xShots'] as List).cast<int>(),
      oShots: (json['oShots'] as List).cast<int>(),
    );
  }

  String serialize() => jsonEncode(toJson());

  static BattleshipState? deserialize(String data) {
    if (data.isEmpty) return null;
    try {
      return BattleshipState.fromJson(
          jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
