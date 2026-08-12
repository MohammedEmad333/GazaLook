import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

/// Persists the shopping cart locally so it survives app restarts (offline,
/// low-bandwidth friendly).
abstract interface class CartLocalDataSource {
  List<CartItemModel> getItems();
  Future<void> saveItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'cart_items';

  @override
  List<CartItemModel> getItems() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <CartItemModel>[];
    try {
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((dynamic e) =>
              CartItemModel.fromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      // Corrupt cache — start clean rather than crash.
      return <CartItemModel>[];
    }
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) {
    final String raw = json.encode(
      items.map((CartItemModel e) => e.toMap()).toList(growable: false),
    );
    return _prefs.setString(_key, raw);
  }
}
