import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/message_entity.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/mesh_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

class GroupChatViewModel {
  final MeshRepository _meshRepository;
  final MessageRepository _messageRepository;
  final GroupRepository _groupRepository;
  final PeerRepository _peerRepository;
  final SigningService _signingService;
  final GroupManagementHandler _groupMgmtHandler;

  String? _myPublicKey;

  GroupChatViewModel({
    required MeshRepository meshRepository,
    required MessageRepository messageRepository,
    required GroupRepository groupRepository,
    required PeerRepository peerRepository,
    required SigningService signingService,
    required GroupManagementHandler groupMgmtHandler,
  })  : _meshRepository = meshRepository,
        _messageRepository = messageRepository,
        _groupRepository = groupRepository,
        _peerRepository = peerRepository,
        _signingService = signingService,
        _groupMgmtHandler = groupMgmtHandler;

  String? get myPublicKey => _myPublicKey;

  Future<void> init(GroupEntity group) async {
    _myPublicKey = await _signingService.publicKeyBase64;
    await _groupRepository.markGroupAsRead(group.groupId);
  }

  Stream<List<MessageEntity>> watchMessages(GroupEntity group) {
    final targetId = 'group:${group.groupId}';
    return _messageRepository.watchMessagesForGroup(targetId, group.joinedAt);
  }

  Future<void> sendMessage(GroupEntity group, String text) =>
      _meshRepository.sendGroupMessage(group.groupId, text);

  Future<void> inviteMember(GroupEntity group, String pubKey) =>
      _groupMgmtHandler.sendInvite(group.groupId, pubKey);

  Future<void> kickMember(GroupEntity group, String pubKey) =>
      _groupMgmtHandler.sendKick(group.groupId, pubKey);

  Future<void> leaveGroup(GroupEntity group) =>
      _groupMgmtHandler.sendLeave(group.groupId);

  Stream<GroupEntity?> watchGroup(String groupId) =>
      _groupRepository.watchMemberGroups().map((groups) {
        for (final g in groups) {
          if (g.groupId == groupId) return g;
        }
        return null;
      });

  Future<String?> getNicknameForKey(String pubKey) async {
    final peer = await _peerRepository.getPeerByPublicKey(pubKey);
    return peer?.nickname;
  }
}
