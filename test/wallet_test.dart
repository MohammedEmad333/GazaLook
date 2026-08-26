import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:gazalook/features/wallet/domain/entities/top_up_channel.dart';
import 'package:gazalook/features/wallet/domain/entities/top_up_status.dart';
import 'package:gazalook/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:gazalook/features/wallet/presentation/cubit/wallet_cubit.dart';

/// In-memory [WalletDataSource] mirroring the mock's semantics: a new top-up is
/// `pending` and does not affect the balance until approved.
class _FakeWalletDataSource implements WalletDataSource {
  final List<WalletTransaction> _txns = <WalletTransaction>[];

  static const List<TopUpChannel> _channels = <TopUpChannel>[
    TopUpChannel(code: 'bank_of_palestine', nameAr: 'بنك فلسطين', accountRef: 'ACC-1'),
  ];

  @override
  Future<List<TopUpChannel>> getChannels() async => _channels;

  @override
  Future<double> getBalance() async => _txns
      .where((WalletTransaction t) => t.status == TopUpStatus.approved)
      .fold<double>(0, (double s, WalletTransaction t) => s + t.amount);

  @override
  Future<List<WalletTransaction>> getTransactions() async =>
      List<WalletTransaction>.unmodifiable(_txns);

  @override
  Future<WalletTransaction> submitTopUp({
    required TopUpChannel channel,
    required double amount,
    required String transactionRef,
    String? receiptName,
  }) async {
    final WalletTransaction txn = WalletTransaction(
      id: '${_txns.length + 1}',
      channelCode: channel.code,
      channelNameAr: channel.nameAr,
      amount: amount,
      status: TopUpStatus.pending,
      createdAt: DateTime.now(),
      transactionRef: transactionRef,
      receiptName: receiptName,
    );
    _txns.add(txn);
    return txn;
  }
}

void main() {
  late _FakeWalletDataSource ds;
  late WalletCubit cubit;

  setUp(() {
    ds = _FakeWalletDataSource();
    cubit = WalletCubit(ds);
  });

  tearDown(() => cubit.close());

  test('load populates channels and starts with zero balance', () async {
    await cubit.load();

    expect(cubit.state.status, WalletStatus.ready);
    expect(cubit.state.channels, hasLength(1));
    expect(cubit.state.balance, 0);
    expect(cubit.state.transactions, isEmpty);
  });

  test('a submitted top-up is pending and does not credit the balance', () async {
    await cubit.load();

    final WalletTransaction? txn = await cubit.submitTopUp(
      channel: cubit.state.channels.first,
      amount: 50,
      transactionRef: 'OP-1',
      receiptName: 'r.jpg',
    );

    expect(txn, isNotNull);
    expect(txn!.status, TopUpStatus.pending);
    expect(cubit.state.transactions, hasLength(1));
    expect(cubit.state.balance, 0); // credited only after admin approval
    expect(cubit.state.submitting, isFalse);
  });
}
