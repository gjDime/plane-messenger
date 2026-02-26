import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Manages the device's long-lived cryptographic identity.
///
/// Two key pairs are maintained:
///   - **Ed25519** — used for signing and verifying messages.
///   - **X25519**  — used for ECDH key agreement to derive shared secrets.
///
/// Both are generated once and persisted in the platform's secure keystore.
class KeyManager {
  // Use final, not const — FlutterSecureStorage has a runtime constructor
  static final _storage = const FlutterSecureStorage();

  static const _ed25519PrivateKeyKey = 'ed25519_private_key';
  static const _x25519PrivateKeyKey = 'x25519_private_key';

  static final _ed25519 = Ed25519();
  static final _x25519 = X25519();

  final SimpleKeyPair _ed25519KeyPair;
  final SimpleKeyPair _x25519KeyPair;

  KeyManager._(this._ed25519KeyPair, this._x25519KeyPair);

  static Future<KeyManager> get instance async {
    final ed25519KeyPair = await _loadOrGenerateKeyPair(
      algorithm: _ed25519,
      storageKey: _ed25519PrivateKeyKey,
      label: 'Ed25519',
    );
    final x25519KeyPair = await _loadOrGenerateKeyPair(
      algorithm: _x25519,
      storageKey: _x25519PrivateKeyKey,
      label: 'X25519',
    );
    return KeyManager._(ed25519KeyPair, x25519KeyPair);
  }

  // ---------------------------------------------------------------------------
  // Ed25519 — identity & signing
  // ---------------------------------------------------------------------------

  SimpleKeyPair get ed25519KeyPair => _ed25519KeyPair;

  Future<List<int>> get publicKeyBytes async {
    final pubKey = await _ed25519KeyPair.extractPublicKey();
    return pubKey.bytes;
  }

  Future<String> get publicKeyBase64 async {
    return base64Encode(await publicKeyBytes);
  }

  Future<List<int>> sign(List<int> message) async {
    final signature = await _ed25519.sign(message, keyPair: _ed25519KeyPair);
    return signature.bytes;
  }

  Future<bool> verify(
    List<int> message,
    List<int> signature,
    List<int> publicKeyBytes,
  ) async {
    final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
    final signatureObj = Signature(signature, publicKey: publicKey);
    return _ed25519.verify(message, signature: signatureObj);
  }

  // ---------------------------------------------------------------------------
  // X25519 — ECDH key agreement
  // ---------------------------------------------------------------------------

  SimpleKeyPair get x25519KeyPair => _x25519KeyPair;

  Future<List<int>> get x25519PublicKeyBytes async {
    final pubKey = await _x25519KeyPair.extractPublicKey();
    return pubKey.bytes;
  }

  Future<String> get x25519PublicKeyBase64 async {
    return base64Encode(await x25519PublicKeyBytes);
  }

  /// Derives a shared secret from our X25519 private key and a remote peer's
  /// X25519 public key. The returned [SecretKey] is suitable for use with
  /// AES-GCM or any other symmetric cipher.
  Future<SecretKey> deriveSharedSecret(List<int> remoteX25519PublicKeyBytes) async {
    final remotePublicKey = SimplePublicKey(
      remoteX25519PublicKeyBytes,
      type: KeyPairType.x25519,
    );
    return _x25519.sharedSecretKey(
      keyPair: _x25519KeyPair,
      remotePublicKey: remotePublicKey,
    );
  }

  // ---------------------------------------------------------------------------
  // Key persistence (shared by both algorithms)
  // ---------------------------------------------------------------------------

  static Future<SimpleKeyPair> _loadOrGenerateKeyPair({
    required dynamic algorithm,
    required String storageKey,
    required String label,
  }) async {
    final storedKey = await _storage.read(key: storageKey);
    if (storedKey != null) {
      try {
        final bytes = base64Decode(storedKey);
        return await algorithm.newKeyPairFromSeed(bytes);
      } catch (e) {
        debugPrint('[KeyManager] Failed to load $label key, regenerating: $e');
      }
    }

    final keyPair = await algorithm.newKeyPair() as SimpleKeyPair;
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    await _storage.write(
      key: storageKey,
      value: base64Encode(privateKeyBytes),
    );
    return keyPair;
  }
}
