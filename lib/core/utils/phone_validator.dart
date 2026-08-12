import '../constants/app_constants.dart';

/// Validates and normalises Gaza / Palestinian mobile numbers.
///
/// Accepts local input such as `059 123 4567`, `0591234567` or `591234567`
/// and pairs it with a dialing prefix (`+970` Palestine or `+972` Israel) to
/// produce an E.164 number like `+970591234567`.
///
/// Mobile rule: 9 national digits beginning with `5` (Jawwal `059x`, Ooredoo
/// `056x`). A leading `0` (trunk prefix) is stripped before validation.
abstract final class PhoneValidator {
  const PhoneValidator._();

  /// Supported dialing prefixes shown in the country selector.
  static const List<String> supportedPrefixes = <String>[
    AppConstants.phonePrefixPS, // +970
    AppConstants.phonePrefixIL, // +972
  ];

  /// Strips everything except digits.
  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');

  /// National significant number: digits without any leading trunk `0`.
  static String _national(String raw) {
    final String d = digitsOnly(raw);
    return d.startsWith('0') ? d.substring(1) : d;
  }

  /// Whether [raw] is a plausible local mobile number.
  static bool isValidLocalMobile(String raw) {
    final String n = _national(raw);
    return n.length == 9 && n.startsWith('5');
  }

  /// Converts local input + [prefix] into an E.164 string (e.g. `+970591234567`).
  ///
  /// Does not validate — call [isValidLocalMobile] first.
  static String toE164(String raw, String prefix) => '$prefix${_national(raw)}';

  /// Returns a localised validation message, or `null` when [raw] is valid.
  static String? validationError(String raw) {
    if (raw.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
    if (!isValidLocalMobile(raw)) {
      return 'رقم غير صالح. مثال: 59 123 4567';
    }
    return null;
  }
}
