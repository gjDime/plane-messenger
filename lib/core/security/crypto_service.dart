import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:plane_messenger/core/security/key_manager.dart';
import 'package:plane_messenger/data/datasources/local/isar_service.dart';

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
///
/// Designed so the underlying key-agreement strategy (static vs ephemeral) can
/// be swapped without changing callers.
class CryptoService {
  static final _aesGcm = AesGcm.with256bits();

  final KeyManager _keyManager;

  /// Cached ECDH shared secrets, keyed by the peer's Ed25519 identity key
  /// (base64). Populated during handshake; persists for the lifetime of the
  /// process (static X25519 keys produce deterministic secrets).
  final Map<String, SecretKey> _sharedSecrets = {};

  CryptoService({required KeyManager keyManager}) : _keyManager = keyManager;

  /// Whether we have (or can derive) a shared secret for [peerEd25519PubKey].
  bool hasSharedSecret(String peerEd25519PubKey) =>
      _sharedSecrets.containsKey(peerEd25519PubKey);

  /// Derives an ECDH shared secret from the peer's X25519 public key and
  /// caches it under their Ed25519 identity key.
  ///
  /// Call this when a handshake packet containing an `x25519PubKey` is received.
  Future<void> establishSharedSecret(
    String peerEd25519PubKey,
    String peerX25519PubKeyBase64,
  ) async {
    final remoteX25519Bytes = base64Decode(peerX25519PubKeyBase64);
    final secret = await _keyManager.deriveSharedSecret(remoteX25519Bytes);
    _sharedSecrets[peerEd25519PubKey] = secret;
  }

  /// Attempts to establish a shared secret by looking up the peer's X25519
  /// public key from the database. Returns `true` if a secret is now available.
  Future<bool> tryEstablishSharedSecret(
    String peerEd25519PubKey,
    IsarService isarService,
  ) async {
    if (_sharedSecrets.containsKey(peerEd25519PubKey)) return true;

    final peer = await isarService.getPeerByPublicKey(peerEd25519PubKey);
    if (peer == null || peer.x25519PublicKey.isEmpty) return false;

    await establishSharedSecret(peerEd25519PubKey, peer.x25519PublicKey);
    return true;
  }

  /// Encrypts [plaintext] so only the peer identified by [peerEd25519PubKey]
  /// can decrypt it.
  ///
  /// Throws [StateError] if no shared secret has been established for the peer.
  Future<EncryptedPayload> encryptForPeer(
    String peerEd25519PubKey,
    String plaintext,
  ) async {
    final secret = _sharedSecrets[peerEd25519PubKey];
    if (secret == null) {
      throw StateError(
        'No shared secret for peer ${peerEd25519PubKey.substring(0, 8)}…',
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

  /// Decrypts an [EncryptedPayload] sent by the peer identified by
  /// [senderEd25519PubKey].
  ///
  /// Throws [StateError] if no shared secret exists, or a cryptography
  /// exception if the ciphertext/MAC is invalid.
  Future<String> decryptFromPeer(
    String senderEd25519PubKey,
    EncryptedPayload encrypted,
  ) async {
    final secret = _sharedSecrets[senderEd25519PubKey];
    if (secret == null) {
      throw StateError(
        'No shared secret for peer ${senderEd25519PubKey.substring(0, 8)}…',
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
