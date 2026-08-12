import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

part 'orders_state.dart';

/// Loads the order history for the orders screen. App-wide singleton so it
/// refreshes after checkout places a new order.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrders) : super(const OrdersState());

  final GetOrders _getOrders;

  Future<void> load() async {
    emit(state.copyWith(status: OrdersStatus.loading));
    final result = await _getOrders(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: OrdersStatus.failure, message: failure.message),
      ),
      (List<Order> orders) => emit(
        OrdersState(
          status: orders.isEmpty ? OrdersStatus.empty : OrdersStatus.success,
          orders: orders,
        ),
      ),
    );
  }
}
