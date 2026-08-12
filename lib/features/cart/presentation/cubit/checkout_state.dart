part of 'checkout_cubit.dart';

enum CheckoutStatus { editing, submitting, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.governorate = Governorate.gazaCity,
    this.addressDetails = '',
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    this.status = CheckoutStatus.editing,
    this.errorMessage,
    this.placedOrder,
  });

  final Governorate governorate;
  final String addressDetails;
  final PaymentMethod paymentMethod;
  final CheckoutStatus status;
  final String? errorMessage;

  /// Set once the order is successfully placed.
  final Order? placedOrder;

  /// Delivery fee for the selected governorate (₪).
  double get deliveryFee => governorate.deliveryFee;

  CheckoutState copyWith({
    Governorate? governorate,
    String? addressDetails,
    PaymentMethod? paymentMethod,
    CheckoutStatus? status,
    String? errorMessage,
    Order? placedOrder,
  }) {
    return CheckoutState(
      governorate: governorate ?? this.governorate,
      addressDetails: addressDetails ?? this.addressDetails,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      // Cleared unless explicitly provided.
      errorMessage: errorMessage,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        governorate,
        addressDetails,
        paymentMethod,
        status,
        errorMessage,
        placedOrder,
      ];
}
