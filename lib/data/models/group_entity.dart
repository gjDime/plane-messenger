import 'package:isar/isar.dart';

part 'group_entity.g.dart';

@collection
class GroupEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String groupId; // UUID v4

  late String name; // display name
  late String creatorPublicKey; // Ed25519 pubkey of current creator
  late List<String> memberPublicKeys; // ordered; creator is [0]
  late int createdAt; // epoch ms
  late int joinedAt; // epoch ms — this device's join time (history cutoff)

  int lastReadTimestamp = 0; // for unread badge
  bool isMember = false; // false after kick/leave or pending invite
  bool isCreator = false; // true only on the creator's device
}
