import 'package:isar/isar.dart';
import 'package:plane_messenger/data/datasources/local/isar_database.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';

class IsarGroupRepository implements GroupRepository {
  final IsarDatabase _db;

  IsarGroupRepository(this._db);

  @override
  Future<void> saveGroup(GroupEntity group) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.groupEntitys.put(group);
    });
  }

  @override
  Future<GroupEntity?> getGroup(String groupId) async {
    final isar = await _db.instance;
    return isar.groupEntitys.filter().groupIdEqualTo(groupId).findFirst();
  }

  @override
  Stream<List<GroupEntity>> watchMemberGroups() async* {
    final isar = await _db.instance;
    yield* isar.groupEntitys
        .filter()
        .isMemberEqualTo(true)
        .watch(fireImmediately: true);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    final isar = await _db.instance;
    await isar.writeTxn(() async {
      await isar.groupEntitys
          .filter()
          .groupIdEqualTo(groupId)
          .deleteAll();
    });
  }

  @override
  Stream<int> watchUnreadCountForGroup(
    String groupId,
    int afterTimestamp,
  ) async* {
    final isar = await _db.instance;
    final targetId = 'group:$groupId';
    yield* isar.messageEntitys
        .filter()
        .targetIdEqualTo(targetId)
        .isMineEqualTo(false)
        .timestampGreaterThan(afterTimestamp)
        .watch(fireImmediately: true)
        .map((messages) => messages.length);
  }

  @override
  Future<void> markGroupAsRead(String groupId) async {
    final isar = await _db.instance;
    final group = await isar.groupEntitys
        .filter()
        .groupIdEqualTo(groupId)
        .findFirst();
    if (group == null) return;
    group.lastReadTimestamp = DateTime.now().millisecondsSinceEpoch;
    await isar.writeTxn(() async {
      await isar.groupEntitys.put(group);
    });
  }
}
