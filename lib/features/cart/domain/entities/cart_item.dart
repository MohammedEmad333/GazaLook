import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

/// A single line in the shopping cart: a product, a chosen size and a quantity.
class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.size,
  });

  final Product product;
  final int quantity;

  /// Selected size (e.g. `M`). `null` for one-size items.
  final String? size;

  /// Stable line identity — same product in a different size is a separate
  /// line, so size is part of the key.
  String get lineId => '${product.id}__${size ?? 'one-size'}';

  /// Price for this line (unit price × quantity), in ₪.
  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        size: size,
      );

  @override
  List<Object?> get props => <Object?>[product.id, size, quantity];
}
