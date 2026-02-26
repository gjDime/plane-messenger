
import 'package:isar/isar.dart';

part 'message_entity.g.dart';

/// Delivery status for outgoing messages.
/// Ordinals are stored in Isar as an int field.
/// `sent = 0` so existing DB rows (which default to 0) are treated as "sent".
enum DeliveryStatus {
  sent,    // 0 — successfully transmitted to at least one peer
  sending, // 1 — transmission in progress
  failed,  // 2 — all send attempts failed
}

@collection
class MessageEntity {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String messageId; // UUID v4

  late String senderId; // Base64-encoded Ed25519 public key of the sender
  late String targetId; // Recipient public key, or "BROADCAST" for mesh-wide messages

  late String payload; // Message text (plain text for MVP; E2EE not yet implemented)

  late int timestamp; // Milliseconds since Unix epoch

  late String signature; // Base64-encoded Ed25519 signature over the data section

  late int ttl; // Remaining mesh hops; must be >= 0

  bool isMine = false; // True when this device sent the message

  int deliveryStatus = 0; // DeliveryStatus ordinal; 0 = sent (default)

  @ignore
  DeliveryStatus get status => DeliveryStatus.values[deliveryStatus];
  set status(DeliveryStatus s) => deliveryStatus = s.index;
}
