import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_item.dart';
import 'order_enums.dart';

/// A placed order — a cart snapshot plus delivery + payment details.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.items,
    required this.governorate,
    required this.addressDetails,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  final String id;
  final List<CartItem> items;
  final Governorate governorate;
  final String addressDetails;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final DateTime createdAt;
  final OrderStatus status;

  /// Grand total in ₪.
  double get total => subtotal + deliveryFee;

  /// Total number of units in the order.
  int get itemCount =>
      items.fold<int>(0, (int sum, CartItem i) => sum + i.quantity);

  @override
  List<Object?> get props => <Object?>[
        id,
        items,
        governorate,
        addressDetails,
        paymentMethod,
        subtotal,
        deliveryFee,
        createdAt,
        status,
      ];
}
