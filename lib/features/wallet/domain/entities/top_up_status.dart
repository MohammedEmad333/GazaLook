/// Lifecycle of a wallet top-up request, mirroring the backend
/// `wallet_transactions.status` column.
enum TopUpStatus {
  pending('قيد المراجعة'),
  approved('تمت الموافقة'),
  rejected('مرفوض');

  const TopUpStatus(this.labelAr);

  final String labelAr;

  static TopUpStatus fromName(String value) => TopUpStatus.values.firstWhere(
        (TopUpStatus s) => s.name == value,
        orElse: () => TopUpStatus.pending,
      );
}
