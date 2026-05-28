import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:plane_messenger/domain/services/encryption_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';

/// Holds the three components of an AES-GCM encrypted payload, all
/// Base64-encoded and ready for inclusion in a wire-format JSON packet.
class EncryptedPayload {
  final String ciphertextBase64;
  final String nonceBase64;
  final String macBase64;

  const EncryptedPayload({
    required this.ciphertextBase64,
    required this.nonceBase64,
    required this.macBase64,
  });
}

/// Encapsulates all symmetric encryption concerns for E2EE direct messages.
///
/// Peers are identified by their Ed25519 public key (base64). When a handshake
/// provides a peer's X25519 public key, [establishSharedSecret] derives a
/// shared AES-256-GCM key via ECDH and caches it in memory.
class CryptoService implements EncryptionService {
  static final _aesGcm = AesGcm.with256bits();

  final SigningService _signingService;

  /// Cached ECDH shared secrets, keyed by the peer's Ed25519 identity key
  /// (base64). Populated during handshake; persists for the lifetime of the
  /// process (static X25519 keys produce deterministic secrets).
  final Map<String, SecretKey> _sharedSecrets = {};

  CryptoService({required SigningService signingService})
      : _signingService = signingService;

  @override
  bool hasSharedSecret(String peerEd25519PubKey) =>
      _sharedSecrets.containsKey(peerEd25519PubKey);

  @override
  Future<void> establishSharedSecret(
    String peerEd25519PubKey,
    String peerX25519PubKeyBase64,
  ) async {
    final remoteX25519Bytes = base64Decode(peerX25519PubKeyBase64);
    final secret = await _signingService.deriveSharedSecret(remoteX25519Bytes);
    _sharedSecrets[peerEd25519PubKey] = secret;
  }

  @override
  Future<EncryptedPayload> encryptForPeer(
    String peerEd25519PubKey,
    String plaintext,
  ) async {
    final secret = _sharedSecrets[peerEd25519PubKey];
    if (secret == null) {
      throw StateError(
        'No shared secret for peer ${peerEd25519PubKey.substring(0, 8)}...',
      );
    }

    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: secret,
    );

    return EncryptedPayload(
      ciphertextBase64: base64Encode(secretBox.cipherText),
      nonceBase64: base64Encode(secretBox.nonce),
      macBase64: base64Encode(secretBox.mac.bytes),
    );
  }

  @override
  Future<String> decryptFromPeer(
    String senderEd25519PubKey,
    EncryptedPayload encrypted,
  ) async {
    final secret = _sharedSecrets[senderEd25519PubKey];
    if (secret == null) {
      throw StateError(
        'No shared secret for peer ${senderEd25519PubKey.substring(0, 8)}...',
      );
    }

    final secretBox = SecretBox(
      base64Decode(encrypted.ciphertextBase64),
      nonce: base64Decode(encrypted.nonceBase64),
      mac: Mac(base64Decode(encrypted.macBase64)),
    );

    final plainBytes = await _aesGcm.decrypt(secretBox, secretKey: secret);
    return utf8.decode(plainBytes);
  }
}
