import 'package:equatable/equatable.dart';

import 'top_up_status.dart';

/// A single top-up entry in the user's wallet history.
class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.channelCode,
    required this.channelNameAr,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.transactionRef,
    this.receiptName,
  });

  final String id;
  final String channelCode;
  final String channelNameAr;

  /// Amount in shekels (₪).
  final double amount;
  final TopUpStatus status;
  final DateTime createdAt;
  final String? transactionRef;

  /// Local file name of the attached receipt screenshot (Phase 1).
  final String? receiptName;

  @override
  List<Object?> get props =>
      <Object?>[id, channelCode, amount, status, createdAt, transactionRef];
}
