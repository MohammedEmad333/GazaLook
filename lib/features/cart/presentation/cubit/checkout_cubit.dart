import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_enums.dart';
import '../../../orders/domain/usecases/place_order.dart';
import '../../domain/entities/cart_item.dart';

part 'checkout_state.dart';

/// Manages the checkout form (governorate, address, payment) and order
/// submission. Kept separate from [CartCubit]; the page clears the cart on
/// success.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._placeOrder) : super(const CheckoutState());

  final PlaceOrder _placeOrder;

  void selectGovernorate(Governorate governorate) =>
      emit(state.copyWith(governorate: governorate));

  void updateAddress(String address) =>
      emit(state.copyWith(addressDetails: address));

  void selectPayment(PaymentMethod method) {
    if (!method.available) return; // e-wallet slots are not selectable yet
    emit(state.copyWith(paymentMethod: method));
  }

  /// Builds and persists the order from the current form + cart snapshot.
  Future<void> submit({
    required List<CartItem> items,
    required double subtotal,
  }) async {
    if (items.isEmpty) return;
    if (state.addressDetails.trim().isEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'يرجى إدخال العنوان التفصيلي',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting));

    final Order order = Order(
      id: 'GZ-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      governorate: state.governorate,
      addressDetails: state.addressDetails.trim(),
      paymentMethod: state.paymentMethod,
      subtotal: subtotal,
      deliveryFee: state.governorate.deliveryFee,
      createdAt: DateTime.now(),
    );

    final result = await _placeOrder(PlaceOrderParams(order: order));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(status: CheckoutStatus.success, placedOrder: order),
      ),
    );
  }
}
