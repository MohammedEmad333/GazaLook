import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of wishlisted product ids locally so favourites survive
/// app restarts (cheap and offline-friendly for low-bandwidth users).
abstract interface class WishlistLocalDataSource {
  Set<String> getIds();
  Future<void> saveIds(Set<String> ids);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  const WishlistLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'wishlist_ids';

  @override
  Set<String> getIds() => _prefs.getStringList(_key)?.toSet() ?? <String>{};

  @override
  Future<void> saveIds(Set<String> ids) =>
      _prefs.setStringList(_key, ids.toList(growable: false));
}
