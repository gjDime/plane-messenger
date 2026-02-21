
import 'package:isar/isar.dart';

part 'peer_entity.g.dart';

@collection
class PeerEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String deviceId; // Nearby Connections EndpointId (unique per session)

  late String publicKey; // Base64-encoded Ed25519 public key; empty string until handshake completes

  late int lastSeen; // Milliseconds since Unix epoch of last observed activity

  bool isConnected = false; // True while an active Nearby Connections session exists

  String? nickname; // Optional user-facing display name
}
