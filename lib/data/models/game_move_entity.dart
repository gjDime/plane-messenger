import 'package:isar/isar.dart';

part 'game_move_entity.g.dart';

@collection
class GameMoveEntity {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String gameId;

  @Index(type: IndexType.value)
  late String moveId; // UUID for dedup + ACK

  late String playerKey;
  late int moveNumber; // sequential: 1, 2, 3...
  late int position; // 0-8 board cell index
  late int timestamp;
  late String signature; // Ed25519 sig base64

  bool acked = false; // true once opponent ACK'd
}
