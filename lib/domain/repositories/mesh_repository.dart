import 'dart:typed_data';

import 'package:plane_messenger/data/models/message_entity.dart';

/// High-level mesh networking operations.
abstract interface class MeshRepository {
  Future<void> initialize();
  Future<void> restartDiscovery();
  void onConnectionEstablished(String endpointId);
  void onPeerDisconnected(String endpointId);
  Future<void> onPayloadReceived(String endpointId, Uint8List bytes);
  Future<void> sendDirectMessage(String recipientEd25519PubKey, String content);
  Future<void> broadcastMessage(String content);
  Future<void> broadcastNicknameUpdate(String nickname);
  Future<void> resendFailedMessage(MessageEntity message);
  Future<void> createGroup(String name, List<String> memberPubKeys);
  Future<void> sendGroupMessage(String groupId, String content);
}
