import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formats prices as Israeli Shekels (₪) for GazaLook.
///
/// Example: `CurrencyFormatter.format(120)` → `"120 ₪"`.
abstract final class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _whole = NumberFormat.decimalPattern();
  static final NumberFormat _decimal = NumberFormat('#,##0.00');

  /// Returns a display string with the shekel symbol.
  ///
  /// Whole numbers render without decimals (e.g. `250 ₪`); fractional amounts
  /// keep two decimal places (e.g. `19.90 ₪`).
  static String format(num amount) {
    final bool isWhole = amount == amount.roundToDouble();
    final String value =
        isWhole ? _whole.format(amount) : _decimal.format(amount);
    return '$value ${AppConstants.currencySymbol}';
  }
}
