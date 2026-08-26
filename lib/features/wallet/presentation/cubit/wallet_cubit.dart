import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/datasources/wallet_datasource.dart';
import '../../domain/entities/top_up_channel.dart';
import '../../domain/entities/wallet_transaction.dart';

part 'wallet_state.dart';

/// Drives the wallet + top-up screens. Loads the balance, funding channels and
/// history, and submits manual (Phase 1) top-ups for admin review.
class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._dataSource) : super(const WalletState());

  final WalletDataSource _dataSource;

  Future<void> load() async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final List<TopUpChannel> channels = await _dataSource.getChannels();
      final double balance = await _dataSource.getBalance();
      final List<WalletTransaction> txns = await _dataSource.getTransactions();
      emit(state.copyWith(
        status: WalletStatus.ready,
        channels: channels,
        balance: balance,
        transactions: txns,
      ));
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  /// Submits a top-up. Returns the created transaction on success, or `null`
  /// on failure (the caller shows the appropriate feedback).
  Future<WalletTransaction?> submitTopUp({
    required TopUpChannel channel,
    required double amount,
    required String transactionRef,
    String? receiptName,
  }) async {
    emit(state.copyWith(submitting: true));
    try {
      final WalletTransaction txn = await _dataSource.submitTopUp(
        channel: channel,
        amount: amount,
        transactionRef: transactionRef,
        receiptName: receiptName,
      );
      final List<WalletTransaction> txns = await _dataSource.getTransactions();
      final double balance = await _dataSource.getBalance();
      emit(state.copyWith(
        submitting: false,
        transactions: txns,
        balance: balance,
      ));
      return txn;
    } catch (_) {
      emit(state.copyWith(submitting: false));
      return null;
    }
  }
}
