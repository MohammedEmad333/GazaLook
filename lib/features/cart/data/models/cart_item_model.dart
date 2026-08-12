import '../../../products/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

/// Serialisable [CartItem] used for local cart caching.
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.product,
    required super.quantity,
    super.size,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
        product: item.product,
        quantity: item.quantity,
        size: item.size,
      );

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        product:
            ProductModel.fromMap(map['product'] as Map<String, dynamic>),
        quantity: (map['quantity'] as int?) ?? 1,
        size: map['size'] as String?,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'product': ProductModel.fromEntity(product).toMap(),
        'quantity': quantity,
        'size': size,
      };
}
