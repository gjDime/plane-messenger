import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPrefs {
  static final _storage = const FlutterSecureStorage();
  static const _nicknameKey = 'user_nickname';

  /// Returns the stored nickname, or null if none has been set yet.
  static Future<String?> getNickname() => _storage.read(key: _nicknameKey);

  /// Persists [nickname] after trimming surrounding whitespace.
  /// Passing an empty or whitespace-only string is a no-op.
  static Future<void> saveNickname(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return Future.value();
    return _storage.write(key: _nicknameKey, value: trimmed);
  }
}
