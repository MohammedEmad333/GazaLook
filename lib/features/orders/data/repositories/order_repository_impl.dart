import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_model.dart';

/// [OrderRepository] backed by the local (persisted) data source.
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl({required OrderLocalDataSource local})
      : _local = local;

  final OrderLocalDataSource _local;

  @override
  Future<Either<Failure, Unit>> placeOrder(Order order) async {
    try {
      // Newest first.
      final List<OrderModel> next = <OrderModel>[
        OrderModel.fromEntity(order),
        ..._local.getOrders(),
      ];
      await _local.saveOrders(next);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('تعذّر حفظ الطلب. حاول مرة أخرى.'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      return Right(_local.getOrders());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
