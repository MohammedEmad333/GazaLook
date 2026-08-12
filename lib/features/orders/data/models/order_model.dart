import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_enums.dart';

/// Serialisable [Order] for local persistence.
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.items,
    required super.governorate,
    required super.addressDetails,
    required super.paymentMethod,
    required super.subtotal,
    required super.deliveryFee,
    required super.createdAt,
    super.status,
  });

  factory OrderModel.fromEntity(Order o) => OrderModel(
        id: o.id,
        items: o.items,
        governorate: o.governorate,
        addressDetails: o.addressDetails,
        paymentMethod: o.paymentMethod,
        subtotal: o.subtotal,
        deliveryFee: o.deliveryFee,
        createdAt: o.createdAt,
        status: o.status,
      );

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
        id: map['id'] as String,
        items: (map['items'] as List<dynamic>)
            .map((dynamic e) =>
                CartItemModel.fromMap(e as Map<String, dynamic>))
            .toList(growable: false),
        governorate: Governorate.values.byName(map['governorate'] as String),
        addressDetails: map['addressDetails'] as String,
        paymentMethod:
            PaymentMethod.values.byName(map['paymentMethod'] as String),
        subtotal: (map['subtotal'] as num).toDouble(),
        deliveryFee: (map['deliveryFee'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        status: OrderStatus.values.byName(map['status'] as String),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'items': items
            .map((CartItem i) => CartItemModel.fromEntity(i).toMap())
            .toList(growable: false),
        'governorate': governorate.name,
        'addressDetails': addressDetails,
        'paymentMethod': paymentMethod.name,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };
}
