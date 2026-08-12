import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/features/cart/domain/entities/cart_item.dart';
import 'package:gazalook/features/orders/domain/entities/order.dart';
import 'package:gazalook/features/orders/domain/entities/order_enums.dart';
import 'package:gazalook/features/products/domain/entities/product.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

Product _product(String id, double price) => Product(
      id: id,
      name: 'p$id',
      price: price,
      imageUrl: '',
      category: ProductCategory.women,
    );

void main() {
  group('CartItem', () {
    test('lineTotal multiplies unit price by quantity', () {
      final item = CartItem(product: _product('1', 120), quantity: 3);
      expect(item.lineTotal, 360);
    });

    test('lineId separates same product by size', () {
      final m = CartItem(product: _product('1', 10), quantity: 1, size: 'M');
      final l = CartItem(product: _product('1', 10), quantity: 1, size: 'L');
      expect(m.lineId == l.lineId, isFalse);
    });
  });

  group('Order', () {
    final order = Order(
      id: 'GZ-1',
      items: <CartItem>[
        CartItem(product: _product('1', 120), quantity: 2), // 240
        CartItem(product: _product('2', 50), quantity: 1), // 50
      ],
      governorate: Governorate.khanYounis,
      addressDetails: 'Test st.',
      paymentMethod: PaymentMethod.cashOnDelivery,
      subtotal: 290,
      deliveryFee: Governorate.khanYounis.deliveryFee,
      createdAt: DateTime(2026),
    );

    test('total adds delivery fee to subtotal', () {
      expect(order.total, 290 + 20);
    });

    test('itemCount sums line quantities', () {
      expect(order.itemCount, 3);
    });

    test('defaults to pending status and COD is available', () {
      expect(order.status, OrderStatus.pending);
      expect(PaymentMethod.cashOnDelivery.available, isTrue);
      expect(PaymentMethod.jawwalPay.available, isFalse);
    });
  });

  group('Governorate', () {
    test('each governorate exposes a positive delivery fee', () {
      for (final Governorate g in Governorate.values) {
        expect(g.deliveryFee, greaterThan(0));
      }
    });
  });
}
