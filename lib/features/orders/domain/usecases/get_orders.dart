import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Loads the order history (most recent first).
class GetOrders implements UseCase<List<Order>, NoParams> {
  const GetOrders(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<Order>>> call(NoParams params) =>
      _repository.getOrders();
}
