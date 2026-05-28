import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:plane_messenger/domain/services/secure_storage_service.dart';
import 'package:plane_messenger/domain/services/signing_service.dart';
import 'dart:convert';

/// Manages the device's long-lived cryptographic identity.
///
/// Two key pairs are maintained:
///   - **Ed25519** — used for signing and verifying messages.
///   - **X25519**  — used for ECDH key agreement to derive shared secrets.
///
/// Both are generated once and persisted via [SecureStorageService].
class KeyManager implements SigningService {
  static const _ed25519PrivateKeyKey = 'ed25519_private_key';
  static const _x25519PrivateKeyKey = 'x25519_private_key';

  static final _ed25519 = Ed25519();
  static final _x25519 = X25519();

  final SimpleKeyPair _ed25519KeyPair;
  final SimpleKeyPair _x25519KeyPair;

  KeyManager._(this._ed25519KeyPair, this._x25519KeyPair);

  static Future<KeyManager> create(SecureStorageService storage) async {
    final ed25519KeyPair = await _loadOrGenerateKeyPair(
      algorithm: _ed25519,
      storageKey: _ed25519PrivateKeyKey,
      label: 'Ed25519',
      storage: storage,
    );
    final x25519KeyPair = await _loadOrGenerateKeyPair(
      algorithm: _x25519,
      storageKey: _x25519PrivateKeyKey,
      label: 'X25519',
      storage: storage,
    );
    return KeyManager._(ed25519KeyPair, x25519KeyPair);
  }

  @override
  Future<List<int>> get publicKeyBytes async {
    final pubKey = await _ed25519KeyPair.extractPublicKey();
    return pubKey.bytes;
  }

  @override
  Future<String> get publicKeyBase64 async {
    return base64Encode(await publicKeyBytes);
  }

  @override
  Future<List<int>> sign(List<int> message) async {
    final signature = await _ed25519.sign(message, keyPair: _ed25519KeyPair);
    return signature.bytes;
  }

  @override
  Future<bool> verify(
    List<int> message,
    List<int> signature,
    List<int> publicKeyBytes,
  ) async {
    final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
    final signatureObj = Signature(signature, publicKey: publicKey);
    return _ed25519.verify(message, signature: signatureObj);
  }

  @override
  Future<List<int>> get x25519PublicKeyBytes async {
    final pubKey = await _x25519KeyPair.extractPublicKey();
    return pubKey.bytes;
  }

  @override
  Future<String> get x25519PublicKeyBase64 async {
    return base64Encode(await x25519PublicKeyBytes);
  }

  @override
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

  static Future<SimpleKeyPair> _loadOrGenerateKeyPair({
    required dynamic algorithm,
    required String storageKey,
    required String label,
    required SecureStorageService storage,
  }) async {
    final storedKey = await storage.read(storageKey);
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
    await storage.write(
      storageKey,
      base64Encode(privateKeyBytes),
    );
    return keyPair;
  }
}
