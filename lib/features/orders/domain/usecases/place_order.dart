import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Persists a placed order.
class PlaceOrder implements UseCase<Unit, PlaceOrderParams> {
  const PlaceOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(PlaceOrderParams params) =>
      _repository.placeOrder(params.order);
}

class PlaceOrderParams extends Equatable {
  const PlaceOrderParams({required this.order});

  final Order order;

  @override
  List<Object?> get props => <Object?>[order];
}
