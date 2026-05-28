import 'package:flutter_test/flutter_test.dart';
import 'package:plane_messenger/data/models/battleship_state.dart';
import 'package:plane_messenger/data/services/battleship_logic.dart';

void main() {
  group('BattleshipLogic', () {
    group('standardFleet', () {
      test('returns 5 ships with correct sizes', () {
        final fleet = BattleshipLogic.standardFleet();
        expect(fleet.length, 5);
        expect(fleet[0], {'type': 'Carrier', 'length': 5});
        expect(fleet[1], {'type': 'Battleship', 'length': 4});
        expect(fleet[2], {'type': 'Destroyer', 'length': 3});
        expect(fleet[3], {'type': 'Submarine', 'length': 3});
        expect(fleet[4], {'type': 'Patrol', 'length': 2});
      });

      test('total cells is 17', () {
        final fleet = BattleshipLogic.standardFleet();
        final total = fleet.fold<int>(0, (sum, s) => sum + (s['length'] as int));
        expect(total, 17);
      });
    });

    group('initialState', () {
      test('starts in placing phase with empty boards', () {
        final state = BattleshipLogic.initialState();
        expect(state.phase, 'placing');
        expect(state.xReady, isFalse);
        expect(state.oReady, isFalse);
        expect(state.xShips, isEmpty);
        expect(state.oShips, isEmpty);
        expect(state.xShots, isEmpty);
        expect(state.oShots, isEmpty);
      });
    });

    group('validatePlacement', () {
      List<ShipPlacement> validFleet() {
        return [
          const ShipPlacement(
              type: 'Carrier', length: 5, startRow: 0, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Battleship', length: 4, startRow: 1, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Destroyer', length: 3, startRow: 2, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Submarine', length: 3, startRow: 3, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Patrol', length: 2, startRow: 4, startCol: 0, horizontal: true),
        ];
      }

      test('valid fleet passes validation', () {
        expect(BattleshipLogic.validatePlacement(validFleet()), isTrue);
      });

      test('vertical placement is valid', () {
        final ships = [
          const ShipPlacement(
              type: 'Carrier', length: 5, startRow: 0, startCol: 0, horizontal: false),
          const ShipPlacement(
              type: 'Battleship', length: 4, startRow: 0, startCol: 1, horizontal: false),
          const ShipPlacement(
              type: 'Destroyer', length: 3, startRow: 0, startCol: 2, horizontal: false),
          const ShipPlacement(
              type: 'Submarine', length: 3, startRow: 0, startCol: 3, horizontal: false),
          const ShipPlacement(
              type: 'Patrol', length: 2, startRow: 0, startCol: 4, horizontal: false),
        ];
        expect(BattleshipLogic.validatePlacement(ships), isTrue);
      });

      test('wrong number of ships fails', () {
        final ships = validFleet().sublist(0, 4);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('wrong ship type fails', () {
        final ships = validFleet();
        ships[0] = const ShipPlacement(
            type: 'Frigate', length: 5, startRow: 0, startCol: 0, horizontal: true);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('wrong ship length fails', () {
        final ships = validFleet();
        ships[0] = const ShipPlacement(
            type: 'Carrier', length: 4, startRow: 0, startCol: 0, horizontal: true);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('horizontal out of bounds fails', () {
        final ships = validFleet();
        ships[0] = const ShipPlacement(
            type: 'Carrier', length: 5, startRow: 0, startCol: 6, horizontal: true);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('vertical out of bounds fails', () {
        final ships = validFleet();
        ships[0] = const ShipPlacement(
            type: 'Carrier', length: 5, startRow: 6, startCol: 0, horizontal: false);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('overlapping ships fail', () {
        final ships = [
          const ShipPlacement(
              type: 'Carrier', length: 5, startRow: 0, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Battleship', length: 4, startRow: 0, startCol: 0, horizontal: false),
          const ShipPlacement(
              type: 'Destroyer', length: 3, startRow: 2, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Submarine', length: 3, startRow: 3, startCol: 0, horizontal: true),
          const ShipPlacement(
              type: 'Patrol', length: 2, startRow: 4, startCol: 0, horizontal: true),
        ];
        // Carrier at (0,0)-(0,4) and Battleship at (0,0)-(3,0) overlap at (0,0)
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('negative row fails', () {
        final ships = validFleet();
        ships[4] = const ShipPlacement(
            type: 'Patrol', length: 2, startRow: -1, startCol: 0, horizontal: true);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });

      test('row 10 fails for horizontal ship', () {
        final ships = validFleet();
        ships[4] = const ShipPlacement(
            type: 'Patrol', length: 2, startRow: 10, startCol: 0, horizontal: true);
        expect(BattleshipLogic.validatePlacement(ships), isFalse);
      });
    });

    group('isValidShot', () {
      test('fresh cell is valid', () {
        expect(BattleshipLogic.isValidShot([], 0), isTrue);
        expect(BattleshipLogic.isValidShot([], 99), isTrue);
      });

      test('already-shot cell is invalid', () {
        expect(BattleshipLogic.isValidShot([42], 42), isFalse);
      });

      test('out of range is invalid', () {
        expect(BattleshipLogic.isValidShot([], -1), isFalse);
        expect(BattleshipLogic.isValidShot([], 100), isFalse);
      });
    });

    group('processShot', () {
      final ships = [
        const ShipPlacement(
            type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true),
      ];

      test('hit on ship cell', () {
        expect(BattleshipLogic.processShot(ships, 0), 'hit');
        expect(BattleshipLogic.processShot(ships, 1), 'hit');
      });

      test('miss on empty cell', () {
        expect(BattleshipLogic.processShot(ships, 2), 'miss');
        expect(BattleshipLogic.processShot(ships, 10), 'miss');
      });
    });

    group('isShipSunk', () {
      const ship = ShipPlacement(
          type: 'Destroyer', length: 3, startRow: 2, startCol: 5, horizontal: true);

      test('fully hit ship is sunk', () {
        expect(BattleshipLogic.isShipSunk(ship, [25, 26, 27]), isTrue);
      });

      test('partially hit ship is not sunk', () {
        expect(BattleshipLogic.isShipSunk(ship, [25, 26]), isFalse);
      });

      test('no hits means not sunk', () {
        expect(BattleshipLogic.isShipSunk(ship, []), isFalse);
      });

      test('extra shots dont matter', () {
        expect(BattleshipLogic.isShipSunk(ship, [25, 26, 27, 0, 99]), isTrue);
      });
    });

    group('allShipsSunk', () {
      final ships = [
        const ShipPlacement(
            type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true),
        const ShipPlacement(
            type: 'Submarine', length: 3, startRow: 1, startCol: 0, horizontal: true),
      ];

      test('all sunk when every cell hit', () {
        expect(BattleshipLogic.allShipsSunk(ships, [0, 1, 10, 11, 12]), isTrue);
      });

      test('not all sunk when some cells remain', () {
        expect(BattleshipLogic.allShipsSunk(ships, [0, 1, 10, 11]), isFalse);
      });

      test('empty shots means not sunk', () {
        expect(BattleshipLogic.allShipsSunk(ships, []), isFalse);
      });
    });

    group('shipAt', () {
      final ships = [
        const ShipPlacement(
            type: 'Carrier', length: 5, startRow: 0, startCol: 0, horizontal: true),
        const ShipPlacement(
            type: 'Patrol', length: 2, startRow: 5, startCol: 5, horizontal: false),
      ];

      test('returns correct ship', () {
        final ship = BattleshipLogic.shipAt(ships, 0);
        expect(ship, isNotNull);
        expect(ship!.type, 'Carrier');
      });

      test('returns correct ship for second ship', () {
        final ship = BattleshipLogic.shipAt(ships, 55); // row 5 col 5
        expect(ship, isNotNull);
        expect(ship!.type, 'Patrol');
      });

      test('returns null for empty cell', () {
        expect(BattleshipLogic.shipAt(ships, 99), isNull);
      });
    });
  });

  group('ShipPlacement', () {
    test('cellIndices horizontal', () {
      const ship = ShipPlacement(
          type: 'Destroyer', length: 3, startRow: 2, startCol: 5, horizontal: true);
      expect(ship.cellIndices, [25, 26, 27]);
    });

    test('cellIndices vertical', () {
      const ship = ShipPlacement(
          type: 'Destroyer', length: 3, startRow: 2, startCol: 5, horizontal: false);
      expect(ship.cellIndices, [25, 35, 45]);
    });

    test('serialization round-trip', () {
      const ship = ShipPlacement(
          type: 'Carrier', length: 5, startRow: 3, startCol: 2, horizontal: true);
      final json = ship.toJson();
      final restored = ShipPlacement.fromJson(json);
      expect(restored.type, 'Carrier');
      expect(restored.length, 5);
      expect(restored.startRow, 3);
      expect(restored.startCol, 2);
      expect(restored.horizontal, isTrue);
    });
  });

  group('BattleshipState', () {
    test('serialization round-trip', () {
      final state = BattleshipState(
        phase: 'gameplay',
        xReady: true,
        oReady: true,
        xShips: const [
          ShipPlacement(
              type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true),
        ],
        oShips: const [
          ShipPlacement(
              type: 'Patrol', length: 2, startRow: 9, startCol: 8, horizontal: true),
        ],
        xShots: const [98, 99],
        oShots: const [0],
      );

      final json = state.serialize();
      final restored = BattleshipState.deserialize(json)!;

      expect(restored.phase, 'gameplay');
      expect(restored.xReady, isTrue);
      expect(restored.oReady, isTrue);
      expect(restored.xShips.length, 1);
      expect(restored.xShips[0].type, 'Patrol');
      expect(restored.oShips.length, 1);
      expect(restored.oShips[0].startRow, 9);
      expect(restored.xShots, [98, 99]);
      expect(restored.oShots, [0]);
    });

    test('deserialize empty string returns null', () {
      expect(BattleshipState.deserialize(''), isNull);
    });

    test('deserialize invalid json returns null', () {
      expect(BattleshipState.deserialize('not json'), isNull);
    });

    test('isHit returns true for ship cell', () {
      const ships = [
        ShipPlacement(
            type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true),
      ];
      expect(BattleshipState.isHit(ships, 0), isTrue);
      expect(BattleshipState.isHit(ships, 1), isTrue);
      expect(BattleshipState.isHit(ships, 2), isFalse);
    });

    test('isSunk checks all cells', () {
      const ship = ShipPlacement(
          type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true);
      expect(BattleshipState.isSunk(ship, [0, 1]), isTrue);
      expect(BattleshipState.isSunk(ship, [0]), isFalse);
    });

    test('allSunk checks every ship', () {
      const ships = [
        ShipPlacement(
            type: 'Patrol', length: 2, startRow: 0, startCol: 0, horizontal: true),
        ShipPlacement(
            type: 'Submarine', length: 3, startRow: 1, startCol: 0, horizontal: true),
      ];
      expect(BattleshipState.allSunk(ships, [0, 1, 10, 11, 12]), isTrue);
      expect(BattleshipState.allSunk(ships, [0, 1, 10, 11]), isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final state = BattleshipLogic.initialState();
      final updated = state.copyWith(phase: 'gameplay');
      expect(updated.phase, 'gameplay');
      expect(updated.xReady, isFalse);
      expect(updated.oReady, isFalse);
      expect(updated.xShips, isEmpty);
    });
  });
}
