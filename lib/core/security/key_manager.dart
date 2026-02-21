
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class KeyManager {
  // Use final, not const — FlutterSecureStorage has a runtime constructor
  static final _storage = const FlutterSecureStorage();
  static const _privateKeyKey = 'ed25519_private_key';

  // Cache the algorithm to avoid repeated instantiation
  static final _algorithm = Ed25519();

  final SimpleKeyPair? _cachedKeyPair;

  KeyManager._(this._cachedKeyPair);

  static Future<KeyManager> get instance async {
    final keyPair = await _loadOrGenerateKeyPair();
    return KeyManager._(keyPair);
  }

  SimpleKeyPair get keyPair {
    if (_cachedKeyPair == null) {
      throw StateError('KeyPair not initialized. Call KeyManager.instance first.');
    }
    return _cachedKeyPair;
  }

  static Future<SimpleKeyPair> _loadOrGenerateKeyPair() async {
    final storedKey = await _storage.read(key: _privateKeyKey);
    if (storedKey != null) {
      try {
        final bytes = base64Decode(storedKey);
        return await _algorithm.newKeyPairFromSeed(bytes);
      } catch (e) {
        // Corrupted or invalid key — regenerate and overwrite
        debugPrint('[KeyManager] Failed to load stored key, regenerating: $e');
      }
    }

    // Generate a new key pair and persist its private bytes
    final keyPair = await _algorithm.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    await _storage.write(
      key: _privateKeyKey,
      value: base64Encode(privateKeyBytes),
    );

    return keyPair;
  }

  Future<List<int>> get publicKeyBytes async {
    final pubKey = await keyPair.extractPublicKey();
    return pubKey.bytes;
  }

  Future<String> get publicKeyBase64 async {
    final bytes = await publicKeyBytes;
    return base64Encode(bytes);
  }

  Future<List<int>> sign(List<int> message) async {
    final signature = await _algorithm.sign(message, keyPair: keyPair);
    return signature.bytes;
  }

  Future<bool> verify(
    List<int> message,
    List<int> signature,
    List<int> publicKeyBytes,
  ) async {
    final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
    final signatureObj = Signature(signature, publicKey: publicKey);
    return _algorithm.verify(message, signature: signatureObj);
  }
}
