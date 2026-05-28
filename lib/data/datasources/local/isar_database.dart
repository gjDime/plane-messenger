import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plane_messenger/data/models/game_move_entity.dart';
import 'package:plane_messenger/data/models/game_session_entity.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';

/// Manages the Isar database lifecycle. Shared by all Isar-backed repositories.
class IsarDatabase {
  Isar? _instance;

  Future<Isar> get instance async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    _instance = await _open();
    return _instance!;
  }

  Future<Isar> _open() async {
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) return existing;

    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        MessageEntitySchema,
        PeerEntitySchema,
        GroupEntitySchema,
        GameSessionEntitySchema,
        GameMoveEntitySchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
  }
}
