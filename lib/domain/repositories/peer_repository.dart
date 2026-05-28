import 'package:plane_messenger/data/models/peer_entity.dart';

/// Persistence contract for discovered peers.
abstract interface class PeerRepository {
  Future<void> savePeer(PeerEntity peer);
  Future<PeerEntity?> getPeer(String deviceId);
  Future<PeerEntity?> getPeerByPublicKey(String publicKey);
  Future<void> deletePeer(String deviceId);
  Stream<List<PeerEntity>> watchPeers();
  Stream<int> watchUnreadCountForPeer(String peerPublicKey, String myPublicKey, int afterTimestamp);
  Future<void> markPeerAsRead(String deviceId);
  Future<void> resetConnectionStatus();
}
