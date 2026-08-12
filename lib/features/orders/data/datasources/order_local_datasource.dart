import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';

/// Persists placed orders locally (most-recent-first).
abstract interface class OrderLocalDataSource {
  List<OrderModel> getOrders();
  Future<void> saveOrders(List<OrderModel> orders);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  const OrderLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'orders';

  @override
  List<OrderModel> getOrders() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <OrderModel>[];
    try {
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((dynamic e) => OrderModel.fromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return <OrderModel>[];
    }
  }

  @override
  Future<void> saveOrders(List<OrderModel> orders) {
    final String raw = json.encode(
      orders.map((OrderModel o) => o.toMap()).toList(growable: false),
    );
    return _prefs.setString(_key, raw);
  }
}
