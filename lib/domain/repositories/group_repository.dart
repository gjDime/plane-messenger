import 'package:plane_messenger/data/models/group_entity.dart';

/// Persistence contract for group chat entities.
abstract interface class GroupRepository {
  Future<void> saveGroup(GroupEntity group);
  Future<GroupEntity?> getGroup(String groupId);
  Stream<List<GroupEntity>> watchMemberGroups(); // isMember == true
  Future<void> deleteGroup(String groupId);
  Stream<int> watchUnreadCountForGroup(String groupId, int afterTimestamp);
  Future<void> markGroupAsRead(String groupId);
}
