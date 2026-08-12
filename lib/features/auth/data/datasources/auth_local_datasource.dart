import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

/// Persists the user session locally so the app remembers who is signed in
/// across launches. Backed by `shared_preferences`.
abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(AuthUserModel user);
  Future<AuthUserModel?> getCachedUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _sessionKey = 'auth_session';

  @override
  Future<void> cacheUser(AuthUserModel user) async {
    try {
      await _prefs.setString(_sessionKey, user.toJson());
    } catch (_) {
      throw const CacheException('Failed to cache session');
    }
  }

  @override
  Future<AuthUserModel?> getCachedUser() async {
    try {
      final String? raw = _prefs.getString(_sessionKey);
      if (raw == null) return null;
      return AuthUserModel.fromJson(raw);
    } catch (_) {
      throw const CacheException('Failed to read session');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.remove(_sessionKey);
    } catch (_) {
      throw const CacheException('Failed to clear session');
    }
  }
}
