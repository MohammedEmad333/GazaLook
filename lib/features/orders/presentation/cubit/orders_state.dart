part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, success, empty, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const <Order>[],
    this.message,
  });

  final OrdersStatus status;
  final List<Order> orders;
  final String? message;

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    String? message,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      message: message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, orders, message];
}
