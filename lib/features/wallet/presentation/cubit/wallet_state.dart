part of 'wallet_cubit.dart';

enum WalletStatus { initial, loading, ready, failure }

/// State for the wallet screen: the approved balance, the funding channels and
/// the top-up history, plus a transient submitting flag for the top-up form.
class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = 0,
    this.channels = const <TopUpChannel>[],
    this.transactions = const <WalletTransaction>[],
    this.submitting = false,
  });

  final WalletStatus status;
  final double balance;
  final List<TopUpChannel> channels;
  final List<WalletTransaction> transactions;
  final bool submitting;

  WalletState copyWith({
    WalletStatus? status,
    double? balance,
    List<TopUpChannel>? channels,
    List<WalletTransaction>? transactions,
    bool? submitting,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      channels: channels ?? this.channels,
      transactions: transactions ?? this.transactions,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, balance, channels, transactions, submitting];
}
