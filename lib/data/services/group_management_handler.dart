import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'package:uuid/uuid.dart';

const _kGroupMgmtTtl = 3;

class PendingGroupInvite {
  final String groupId;
  final String groupName;
  final String inviterPubKey;
  final String? inviterNickname;
  final List<String> currentMemberPubKeys;

  PendingGroupInvite({
    required this.groupId,
    required this.groupName,
    required this.inviterPubKey,
    this.inviterNickname,
    required this.currentMemberPubKeys,
  });
}

class GroupManagementHandler {
  final GroupRepository _groupRepository;
  final PeerRepository _peerRepository;
  final SigningService _signingService;
  final P2PConnectionService _connectionService;

  final _pendingInvites = StreamController<PendingGroupInvite>.broadcast();

  GroupManagementHandler({
    required GroupRepository groupRepository,
    required PeerRepository peerRepository,
    required SigningService signingService,
    required P2PConnectionService connectionService,
  })  : _groupRepository = groupRepository,
        _peerRepository = peerRepository,
        _signingService = signingService,
        _connectionService = connectionService;

  Stream<PendingGroupInvite> get pendingInvites => _pendingInvites.stream;

  Future<void> handlePacket(
    Map<String, dynamic> packet,
    String endpointId,
  ) async {
    final action = packet['action'] as String?;
    if (action == null) return;

    switch (action) {
      case 'group_invite':
        await _handleInvite(packet);
      case 'invite_response':
        await _handleInviteResponse(packet);
      case 'kick':
        await _handleKick(packet);
      case 'leave':
        await _handleLeave(packet);
    }
  }

  Future<GroupEntity> createGroup(
    String name,
    List<String> memberPubKeys,
  ) async {
    final myKey = await _signingService.publicKeyBase64;
    final groupId = _generateId();
    final now = DateTime.now().millisecondsSinceEpoch;

    final group = GroupEntity()
      ..groupId = groupId
      ..name = name
      ..creatorPublicKey = myKey
      ..memberPublicKeys = [myKey, ...memberPubKeys]
      ..createdAt = now
      ..joinedAt = now
      ..isMember = true
      ..isCreator = true;

    await _groupRepository.saveGroup(group);

    for (final pubKey in memberPubKeys) {
      await sendInvite(groupId, pubKey);
    }

    return group;
  }

  Future<void> sendInvite(String groupId, String inviteePubKey) async {
    final group = await _groupRepository.getGroup(groupId);
    if (group == null) return;

    final myKey = await _signingService.publicKeyBase64;
    final peer = await _peerRepository.getPeerByPublicKey(myKey);

    await _buildAndFloodPacket({
      'action': 'group_invite',
      'groupId': groupId,
      'groupName': group.name,
      'senderPubKey': myKey,
      'inviteePubKey': inviteePubKey,
      'currentMemberPubKeys': group.memberPublicKeys,
      'nickname': peer?.nickname,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> acceptInvite(PendingGroupInvite invite) async {
    final myKey = await _signingService.publicKeyBase64;
    final now = DateTime.now().millisecondsSinceEpoch;

    final group = GroupEntity()
      ..groupId = invite.groupId
      ..name = invite.groupName
      ..creatorPublicKey = invite.inviterPubKey
      ..memberPublicKeys = [...invite.currentMemberPubKeys, myKey]
      ..createdAt = now
      ..joinedAt = now
      ..isMember = true
      ..isCreator = false;

    await _groupRepository.saveGroup(group);

    await _buildAndFloodPacket({
      'action': 'invite_response',
      'groupId': invite.groupId,
      'senderPubKey': myKey,
      'accepted': true,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> declineInvite(PendingGroupInvite invite) async {
    final myKey = await _signingService.publicKeyBase64;

    await _buildAndFloodPacket({
      'action': 'invite_response',
      'groupId': invite.groupId,
      'senderPubKey': myKey,
      'accepted': false,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> sendKick(String groupId, String targetPubKey) async {
    final group = await _groupRepository.getGroup(groupId);
    if (group == null || !group.isCreator) return;

    group.memberPublicKeys.remove(targetPubKey);
    await _groupRepository.saveGroup(group);

    final myKey = await _signingService.publicKeyBase64;

    await _buildAndFloodPacket({
      'action': 'kick',
      'groupId': groupId,
      'senderPubKey': myKey,
      'targetPubKey': targetPubKey,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> sendLeave(String groupId) async {
    final group = await _groupRepository.getGroup(groupId);
    if (group == null || !group.isMember) return;

    final myKey = await _signingService.publicKeyBase64;

    group.memberPublicKeys.remove(myKey);
    group.isMember = false;
    group.isCreator = false;
    await _groupRepository.saveGroup(group);

    await _buildAndFloodPacket({
      'action': 'leave',
      'groupId': groupId,
      'senderPubKey': myKey,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _handleInvite(Map<String, dynamic> packet) async {
    final groupId = packet['groupId'] as String;
    final groupName = packet['groupName'] as String;
    final senderPubKey = packet['senderPubKey'] as String;
    final inviteePubKey = packet['inviteePubKey'] as String;
    final nickname = packet['nickname'] as String?;
    final members = (packet['currentMemberPubKeys'] as List).cast<String>();

    final myKey = await _signingService.publicKeyBase64;
    if (inviteePubKey != myKey) return;

    final existing = await _groupRepository.getGroup(groupId);
    if (existing != null && existing.isMember) return;

    _pendingInvites.add(PendingGroupInvite(
      groupId: groupId,
      groupName: groupName,
      inviterPubKey: senderPubKey,
      inviterNickname: nickname,
      currentMemberPubKeys: members,
    ));
  }

  Future<void> _handleInviteResponse(Map<String, dynamic> packet) async {
    final groupId = packet['groupId'] as String;
    final senderPubKey = packet['senderPubKey'] as String;
    final accepted = packet['accepted'] as bool;

    final group = await _groupRepository.getGroup(groupId);
    if (group == null) return;

    if (accepted) {
      if (!group.memberPublicKeys.contains(senderPubKey)) {
        group.memberPublicKeys.add(senderPubKey);
        await _groupRepository.saveGroup(group);
      }
    }
  }

  Future<void> _handleKick(Map<String, dynamic> packet) async {
    final groupId = packet['groupId'] as String;
    final senderPubKey = packet['senderPubKey'] as String;
    final targetPubKey = packet['targetPubKey'] as String;

    final group = await _groupRepository.getGroup(groupId);
    if (group == null) return;

    if (senderPubKey != group.creatorPublicKey) {
      debugPrint('[GROUP] Ignoring kick from non-creator');
      return;
    }

    group.memberPublicKeys.remove(targetPubKey);

    final myKey = await _signingService.publicKeyBase64;
    if (targetPubKey == myKey) {
      group.isMember = false;
      group.isCreator = false;
    }

    await _groupRepository.saveGroup(group);
  }

  Future<void> _handleLeave(Map<String, dynamic> packet) async {
    final groupId = packet['groupId'] as String;
    final senderPubKey = packet['senderPubKey'] as String;

    final group = await _groupRepository.getGroup(groupId);
    if (group == null) return;

    group.memberPublicKeys.remove(senderPubKey);

    if (senderPubKey == group.creatorPublicKey &&
        group.memberPublicKeys.isNotEmpty) {
      group.creatorPublicKey = group.memberPublicKeys.first;

      final myKey = await _signingService.publicKeyBase64;
      if (group.creatorPublicKey == myKey) {
        group.isCreator = true;
      }
    }

    await _groupRepository.saveGroup(group);
  }

  Future<void> _buildAndFloodPacket(Map<String, dynamic> dataMap) async {
    final myKey = await _signingService.publicKeyBase64;
    dataMap['senderPubKey'] = myKey;

    final dataJson = jsonEncode(dataMap);
    final dataBytes = utf8.encode(dataJson);
    final signatureBytes = await _signingService.sign(dataBytes);
    final signature = base64Encode(signatureBytes);

    final packet = {
      'type': 'group_management',
      ...dataMap,
      'ttl': _kGroupMgmtTtl,
      's': signature,
    };

    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(packet)));

    for (final endpointId in _connectionService.connectedEndpoints) {
      try {
        await _connectionService.sendPayload(endpointId, bytes);
      } catch (e) {
        debugPrint('[GROUP] Failed to send to $endpointId: $e');
      }
    }
  }

  String _generateId() => const Uuid().v4();
}
