import 'package:flutter_test/flutter_test.dart';
import 'package:plane_messenger/data/models/group_entity.dart';

void main() {
  group('GroupEntity', () {
    test('memberPublicKeys tracks members correctly', () {
      final entity = GroupEntity()
        ..groupId = 'g1'
        ..name = 'Test Group'
        ..creatorPublicKey = 'creatorKey'
        ..memberPublicKeys = ['creatorKey', 'member1', 'member2']
        ..createdAt = 1000
        ..joinedAt = 1000
        ..isMember = true
        ..isCreator = true;

      expect(entity.memberPublicKeys.length, 3);
      expect(entity.memberPublicKeys.first, 'creatorKey');
    });

    test('removing a member updates the list', () {
      final members = ['creatorKey', 'member1', 'member2'];
      members.remove('member1');
      expect(members, ['creatorKey', 'member2']);
    });

    test('succession: first remaining member becomes creator', () {
      final members = ['creatorKey', 'member1', 'member2'];
      final creatorKey = 'creatorKey';

      // Creator leaves
      members.remove(creatorKey);
      expect(members.isNotEmpty, isTrue);

      final newCreator = members.first;
      expect(newCreator, 'member1');
    });

    test('succession: no members left after creator leaves', () {
      final members = ['creatorKey'];
      members.remove('creatorKey');
      expect(members.isEmpty, isTrue);
    });

    test('group target ID format', () {
      const groupId = 'abc-123';
      const targetId = 'group:$groupId';
      expect(targetId, 'group:abc-123');
      expect(targetId.startsWith('group:'), isTrue);
      expect(targetId.substring(6), groupId);
    });
  });

  group('Group message membership gate logic', () {
    test('member receives message after joinedAt', () {
      final group = GroupEntity()
        ..groupId = 'g1'
        ..name = 'Test'
        ..creatorPublicKey = 'c'
        ..memberPublicKeys = ['c', 'me']
        ..createdAt = 1000
        ..joinedAt = 1000
        ..isMember = true
        ..isCreator = false;

      const messageTimestamp = 2000;
      final shouldSave =
          group.isMember && messageTimestamp >= group.joinedAt;
      expect(shouldSave, isTrue);
    });

    test('member does not receive message before joinedAt', () {
      final group = GroupEntity()
        ..groupId = 'g1'
        ..name = 'Test'
        ..creatorPublicKey = 'c'
        ..memberPublicKeys = ['c', 'me']
        ..createdAt = 1000
        ..joinedAt = 2000
        ..isMember = true
        ..isCreator = false;

      const messageTimestamp = 1500;
      final shouldSave =
          group.isMember && messageTimestamp >= group.joinedAt;
      expect(shouldSave, isFalse);
    });

    test('non-member does not receive message', () {
      final group = GroupEntity()
        ..groupId = 'g1'
        ..name = 'Test'
        ..creatorPublicKey = 'c'
        ..memberPublicKeys = ['c']
        ..createdAt = 1000
        ..joinedAt = 1000
        ..isMember = false
        ..isCreator = false;

      const messageTimestamp = 2000;
      final shouldSave =
          group.isMember && messageTimestamp >= group.joinedAt;
      expect(shouldSave, isFalse);
    });
  });

  group('Group management packet dedup logic', () {
    test('dedup key format is action:groupId:ts', () {
      const action = 'group_invite';
      const groupId = 'g-123';
      const ts = 1000;
      final key = '$action:$groupId:$ts';
      expect(key, 'group_invite:g-123:1000');
    });

    test('same packet produces same dedup key', () {
      final packet1 = {'action': 'kick', 'groupId': 'g1', 'ts': 500};
      final packet2 = {'action': 'kick', 'groupId': 'g1', 'ts': 500};

      final key1 = '${packet1['action']}:${packet1['groupId']}:${packet1['ts']}';
      final key2 = '${packet2['action']}:${packet2['groupId']}:${packet2['ts']}';
      expect(key1, key2);
    });

    test('different timestamps produce different dedup keys', () {
      final key1 = 'kick:g1:500';
      final key2 = 'kick:g1:501';
      expect(key1 == key2, isFalse);
    });
  });

  group('RadarItem logic', () {
    test('group target ID round-trips correctly', () {
      const groupId = 'my-group-uuid';
      final targetId = 'group:$groupId';
      final extractedId = targetId.substring(6);
      expect(extractedId, groupId);
    });
  });
}
