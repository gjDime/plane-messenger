import 'package:cryptography/cryptography.dart';

/// Manages the device's cryptographic identity (Ed25519 signing + X25519 ECDH).
abstract interface class SigningService {
  Future<List<int>> get publicKeyBytes;
  Future<String> get publicKeyBase64;
  Future<List<int>> get x25519PublicKeyBytes;
  Future<String> get x25519PublicKeyBase64;
  Future<List<int>> sign(List<int> data);
  Future<bool> verify(List<int> data, List<int> signature, List<int> publicKey);
  Future<SecretKey> deriveSharedSecret(List<int> remoteX25519PublicKeyBytes);
}
