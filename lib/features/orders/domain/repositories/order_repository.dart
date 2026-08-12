import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

/// Contract for placing and reading orders (persisted locally for now).
abstract interface class OrderRepository {
  /// Persists a newly placed [order].
  Future<Either<Failure, Unit>> placeOrder(Order order);

  /// Returns all orders, most recent first.
  Future<Either<Failure, List<Order>>> getOrders();
}
