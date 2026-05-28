import 'package:plane_messenger/core/security/crypto_service.dart';

/// Symmetric encryption concerns for E2EE direct messages.
///
/// Peers are identified by their Ed25519 public key (base64).
abstract interface class EncryptionService {
  bool hasSharedSecret(String peerPublicKey);
  Future<void> establishSharedSecret(String peerEd25519PubKey, String peerX25519PubKeyBase64);
  Future<EncryptedPayload> encryptForPeer(String peerPublicKey, String plaintext);
  Future<String> decryptFromPeer(String peerPublicKey, EncryptedPayload payload);
}
