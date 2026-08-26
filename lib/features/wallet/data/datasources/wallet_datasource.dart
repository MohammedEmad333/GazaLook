import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/top_up_channel.dart';
import '../../domain/entities/top_up_status.dart';
import '../../domain/entities/wallet_transaction.dart';

/// Wallet data access. Today this is backed by a local mock (below) so the
/// "شحن الرصيد" flow is fully demoable offline; the real implementation calls
/// the PHP wallet API (see /backend) — swap the registration in the DI
/// container and the presentation layer stays untouched.
abstract interface class WalletDataSource {
  Future<List<TopUpChannel>> getChannels();

  /// Approved balance in shekels (pending top-ups are not counted).
  Future<double> getBalance();

  Future<List<WalletTransaction>> getTransactions();

  /// Submits a manual (Phase 1) top-up. Returns the created `pending` entry.
  Future<WalletTransaction> submitTopUp({
    required TopUpChannel channel,
    required double amount,
    required String transactionRef,
    String? receiptName,
  });
}

/// Local, `SharedPreferences`-backed mock. Mirrors backend semantics: a new
/// top-up is stored as [TopUpStatus.pending] and does NOT change the balance
/// until an admin approves it, so the UI reflects the real review flow.
class MockWalletDataSource implements WalletDataSource {
  MockWalletDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _txnKey = 'wallet_transactions';

  static const List<TopUpChannel> _channels = <TopUpChannel>[
    TopUpChannel(
      code: 'bank_of_palestine',
      nameAr: 'بنك فلسطين',
      accountRef: 'ACC-0000-0000',
    ),
    TopUpChannel(code: 'jawwal_pay', nameAr: 'جوال باي', accountRef: '059-000-0000'),
    TopUpChannel(code: 'bal_pay', nameAr: 'بالبي', accountRef: '056-000-0000'),
  ];

  @override
  Future<List<TopUpChannel>> getChannels() async => _channels;

  @override
  Future<double> getBalance() async {
    final List<WalletTransaction> txns = await getTransactions();
    return txns
        .where((WalletTransaction t) => t.status == TopUpStatus.approved)
        .fold<double>(0, (double sum, WalletTransaction t) => sum + t.amount);
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final String? raw = _prefs.getString(_txnKey);
    if (raw == null || raw.isEmpty) return <WalletTransaction>[];
    try {
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      final List<WalletTransaction> items = decoded
          .map((dynamic e) => _fromMap(e as Map<String, dynamic>))
          .toList();
      items.sort((WalletTransaction a, WalletTransaction b) =>
          b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (_) {
      return <WalletTransaction>[];
    }
  }

  @override
  Future<WalletTransaction> submitTopUp({
    required TopUpChannel channel,
    required double amount,
    required String transactionRef,
    String? receiptName,
  }) async {
    final WalletTransaction txn = WalletTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      channelCode: channel.code,
      channelNameAr: channel.nameAr,
      amount: amount,
      status: TopUpStatus.pending,
      createdAt: DateTime.now(),
      transactionRef: transactionRef,
      receiptName: receiptName,
    );

    final List<WalletTransaction> current = await getTransactions();
    final List<WalletTransaction> next = <WalletTransaction>[txn, ...current];
    await _prefs.setString(
      _txnKey,
      json.encode(next.map(_toMap).toList(growable: false)),
    );
    return txn;
  }

  static Map<String, dynamic> _toMap(WalletTransaction t) => <String, dynamic>{
        'id': t.id,
        'channel_code': t.channelCode,
        'channel_name_ar': t.channelNameAr,
        'amount': t.amount,
        'status': t.status.name,
        'created_at': t.createdAt.toIso8601String(),
        'transaction_ref': t.transactionRef,
        'receipt_name': t.receiptName,
      };

  static WalletTransaction _fromMap(Map<String, dynamic> m) => WalletTransaction(
        id: m['id'] as String,
        channelCode: m['channel_code'] as String,
        channelNameAr: m['channel_name_ar'] as String,
        amount: (m['amount'] as num).toDouble(),
        status: TopUpStatus.fromName(m['status'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
        transactionRef: m['transaction_ref'] as String?,
        receiptName: m['receipt_name'] as String?,
      );
}
