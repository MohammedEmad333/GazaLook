import 'package:bloc/bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/entities/cart_item.dart';

/// App-wide shopping cart. State is the list of cart lines; every mutation is
/// persisted locally. A single instance keeps the badge, PDP and cart screen
/// in sync.
class CartCubit extends Cubit<List<CartItem>> {
  CartCubit(this._local) : super(_local.getItems());

  final CartLocalDataSource _local;

  /// Total number of units across all lines (used for the nav badge).
  int get itemCount =>
      state.fold<int>(0, (int sum, CartItem i) => sum + i.quantity);

  /// Sum of every line total, in ₪.
  double get subtotal =>
      state.fold<double>(0, (double sum, CartItem i) => sum + i.lineTotal);

  /// Adds [product] (optionally with [size]); merges into an existing line.
  Future<void> addItem(
    Product product, {
    String? size,
    int quantity = 1,
  }) async {
    final CartItem candidate =
        CartItem(product: product, quantity: quantity, size: size);
    final List<CartItem> next = List<CartItem>.of(state);
    final int index =
        next.indexWhere((CartItem i) => i.lineId == candidate.lineId);
    if (index >= 0) {
      next[index] =
          next[index].copyWith(quantity: next[index].quantity + quantity);
    } else {
      next.add(candidate);
    }
    await _emitAndPersist(next);
  }

  /// Sets an exact quantity for a line; removes it when [quantity] <= 0.
  Future<void> updateQuantity(String lineId, int quantity) async {
    final List<CartItem> next = <CartItem>[];
    for (final CartItem item in state) {
      if (item.lineId == lineId) {
        if (quantity > 0) next.add(item.copyWith(quantity: quantity));
      } else {
        next.add(item);
      }
    }
    await _emitAndPersist(next);
  }

  Future<void> increment(String lineId) async {
    final CartItem? item = _find(lineId);
    if (item != null) await updateQuantity(lineId, item.quantity + 1);
  }

  Future<void> decrement(String lineId) async {
    final CartItem? item = _find(lineId);
    if (item != null) await updateQuantity(lineId, item.quantity - 1);
  }

  Future<void> removeItem(String lineId) async {
    await _emitAndPersist(
      state.where((CartItem i) => i.lineId != lineId).toList(growable: false),
    );
  }

  Future<void> clear() => _emitAndPersist(<CartItem>[]);

  CartItem? _find(String lineId) {
    for (final CartItem i in state) {
      if (i.lineId == lineId) return i;
    }
    return null;
  }

  Future<void> _emitAndPersist(List<CartItem> items) async {
    emit(items);
    await _local.saveItems(
      items.map(CartItemModel.fromEntity).toList(growable: false),
    );
  }
}
