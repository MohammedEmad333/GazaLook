import 'package:equatable/equatable.dart';

/// A funding source the shopper can transfer to (Bank of Palestine, Jawwal Pay,
/// Bal Pay). Mirrors a `payment_channels` row on the backend.
class TopUpChannel extends Equatable {
  const TopUpChannel({
    required this.code,
    required this.nameAr,
    this.accountRef,
  });

  final String code;
  final String nameAr;

  /// The account / number the shopper transfers to (shown during Phase 1).
  final String? accountRef;

  @override
  List<Object?> get props => <Object?>[code, nameAr, accountRef];
}
