import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:plane_messenger/domain/services/secure_storage_service.dart';

/// [SecureStorageService] backed by the platform keystore.
class FlutterSecureStorageService implements SecureStorageService {
  final FlutterSecureStorage _storage;

  const FlutterSecureStorageService([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
