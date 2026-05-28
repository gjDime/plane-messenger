import 'package:plane_messenger/data/models/battleship_state.dart';

class BattleshipLogic {
  static List<Map<String, dynamic>> standardFleet() => [
        {'type': 'Carrier', 'length': 5},
        {'type': 'Battleship', 'length': 4},
        {'type': 'Destroyer', 'length': 3},
        {'type': 'Submarine', 'length': 3},
        {'type': 'Patrol', 'length': 2},
      ];

  static BattleshipState initialState() {
    return const BattleshipState(
      phase: 'placing',
      xReady: false,
      oReady: false,
      xShips: [],
      oShips: [],
      xShots: [],
      oShots: [],
    );
  }

  static bool validatePlacement(List<ShipPlacement> ships) {
    final fleet = standardFleet();
    if (ships.length != fleet.length) return false;

    final remaining = List<Map<String, dynamic>>.from(fleet);
    for (final ship in ships) {
      final idx = remaining.indexWhere(
          (f) => f['type'] == ship.type && f['length'] == ship.length);
      if (idx == -1) return false;
      remaining.removeAt(idx);
    }

    for (final ship in ships) {
      if (ship.startRow < 0 || ship.startCol < 0) return false;
      if (ship.horizontal) {
        if (ship.startCol + ship.length > 10) return false;
        if (ship.startRow >= 10) return false;
      } else {
        if (ship.startRow + ship.length > 10) return false;
        if (ship.startCol >= 10) return false;
      }
    }

    final occupied = <int>{};
    for (final ship in ships) {
      for (final cell in ship.cellIndices) {
        if (!occupied.add(cell)) return false;
      }
    }

    return true;
  }

  static bool isValidShot(List<int> shots, int cellIndex) {
    if (cellIndex < 0 || cellIndex > 99) return false;
    return !shots.contains(cellIndex);
  }

  static String processShot(List<ShipPlacement> opponentShips, int cellIndex) {
    return BattleshipState.isHit(opponentShips, cellIndex) ? 'hit' : 'miss';
  }

  static bool isShipSunk(ShipPlacement ship, List<int> shots) {
    return BattleshipState.isSunk(ship, shots);
  }

  static bool allShipsSunk(List<ShipPlacement> ships, List<int> shots) {
    return BattleshipState.allSunk(ships, shots);
  }

  static ShipPlacement? shipAt(List<ShipPlacement> ships, int cellIndex) {
    for (final ship in ships) {
      if (ship.cellIndices.contains(cellIndex)) return ship;
    }
    return null;
  }
}
