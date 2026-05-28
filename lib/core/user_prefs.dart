import 'package:plane_messenger/domain/services/secure_storage_service.dart';

class UserPrefs {
  static const _nicknameKey = 'user_nickname';
  final SecureStorageService _storage;

  const UserPrefs(this._storage);

  /// Returns the stored nickname, or null if none has been set yet.
  Future<String?> getNickname() => _storage.read(_nicknameKey);

  /// Persists [nickname] after trimming surrounding whitespace.
  /// Passing an empty or whitespace-only string is a no-op.
  Future<void> saveNickname(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return Future.value();
    return _storage.write(_nicknameKey, trimmed);
  }
}
