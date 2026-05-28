import 'dart:async';

import 'package:plane_messenger/core/user_prefs.dart';
import 'package:plane_messenger/data/models/group_entity.dart';
import 'package:plane_messenger/data/models/peer_entity.dart';
import 'package:plane_messenger/data/services/group_management_handler.dart';
import 'package:plane_messenger/domain/repositories/group_repository.dart';
import 'package:plane_messenger/domain/repositories/mesh_repository.dart';
import 'package:plane_messenger/domain/repositories/message_repository.dart';
import 'package:plane_messenger/domain/repositories/peer_repository.dart';
import 'package:plane_messenger/domain/services/p2p_connection_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'package:plane_messenger/domain/services/system_service.dart';

/// Unified item type for the radar list (peers + groups mixed).
sealed class RadarItem {}

class PeerRadarItem extends RadarItem {
  final PeerEntity peer;
  PeerRadarItem(this.peer);
}

class GroupRadarItem extends RadarItem {
  final GroupEntity group;
  GroupRadarItem(this.group);
}

class RadarViewModel {
  final MeshRepository _meshRepository;
  final PeerRepository _peerRepository;
  final MessageRepository _messageRepository;
  final P2PConnectionService _connectionService;
  final SigningService _signingService;
  final UserPrefs _userPrefs;
  final SystemService _systemService;
  final GroupRepository _groupRepository;
  final GroupManagementHandler _groupMgmtHandler;

  String? _myPublicKey;
  String? _myNickname;

  RadarViewModel({
    required MeshRepository meshRepository,
    required PeerRepository peerRepository,
    required MessageRepository messageRepository,
    required P2PConnectionService connectionService,
    required SigningService signingService,
    required UserPrefs userPrefs,
    required SystemService systemService,
    required GroupRepository groupRepository,
    required GroupManagementHandler groupMgmtHandler,
  })  : _meshRepository = meshRepository,
        _peerRepository = peerRepository,
        _messageRepository = messageRepository,
        _connectionService = connectionService,
        _signingService = signingService,
        _userPrefs = userPrefs,
        _systemService = systemService,
        _groupRepository = groupRepository,
        _groupMgmtHandler = groupMgmtHandler;

  String? get myPublicKey => _myPublicKey;
  String? get myNickname => _myNickname;

  Stream<String> get serviceEventStream => _systemService.serviceEventStream;

  Stream<PendingGroupInvite> get pendingGroupInvites =>
      _groupMgmtHandler.pendingInvites;

  Future<void> init() async {
    _myPublicKey = await _signingService.publicKeyBase64;
    _myNickname = await _userPrefs.getNickname();
  }

  Stream<List<PeerEntity>> watchPeers() => _peerRepository.watchPeers();

  Stream<List<RadarItem>> watchRadarItems() {
    final controller = StreamController<List<RadarItem>>();
    List<PeerEntity> latestPeers = [];
    List<GroupEntity> latestGroups = [];

    void emit() {
      final items = <RadarItem>[
        ...latestGroups.map((g) => GroupRadarItem(g)),
        ...latestPeers.map((p) => PeerRadarItem(p)),
      ];
      controller.add(items);
    }

    final peerSub = _peerRepository.watchPeers().listen((peers) {
      latestPeers = peers;
      emit();
    });

    final groupSub = _groupRepository.watchMemberGroups().listen((groups) {
      latestGroups = groups;
      emit();
    });

    controller.onCancel = () {
      peerSub.cancel();
      groupSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  Stream<int> watchUnreadCount(String peerPublicKey, int lastReadTimestamp) =>
      _peerRepository.watchUnreadCountForPeer(
        peerPublicKey,
        _myPublicKey!,
        lastReadTimestamp,
      );

  Stream<int> watchGroupUnreadCount(String groupId, int lastReadTimestamp) =>
      _groupRepository.watchUnreadCountForGroup(groupId, lastReadTimestamp);

  Future<void> refreshDiscovery() => _meshRepository.restartDiscovery();

  Future<void> deletePeer(PeerEntity peer) async {
    if (peer.isConnected) {
      await _connectionService.disconnectFromEndpoint(peer.deviceId);
    }
    if (peer.publicKey.isNotEmpty && _myPublicKey != null) {
      await _messageRepository.deleteMessagesForPeer(peer.publicKey, _myPublicKey!);
    }
    await _peerRepository.deletePeer(peer.deviceId);
  }

  Future<void> createGroup(String name, List<String> memberPubKeys) =>
      _meshRepository.createGroup(name, memberPubKeys);

  Future<void> deleteGroup(GroupEntity group) async {
    final targetId = 'group:${group.groupId}';
    await _messageRepository.deleteMessagesForGroup(targetId);
    await _groupRepository.deleteGroup(group.groupId);
  }

  Future<void> acceptGroupInvite(PendingGroupInvite invite) =>
      _groupMgmtHandler.acceptInvite(invite);

  Future<void> declineGroupInvite(PendingGroupInvite invite) =>
      _groupMgmtHandler.declineInvite(invite);

  Future<void> changeNickname(String nickname) async {
    await _userPrefs.saveNickname(nickname);
    _myNickname = nickname;
    _meshRepository.broadcastNicknameUpdate(nickname);
  }

  Future<void> openBluetoothSettings() => _systemService.openBluetoothSettings();
  Future<void> openWifiSettings() => _systemService.openWifiSettings();
  Future<void> openLocationSettings() => _systemService.openLocationSettings();
}
