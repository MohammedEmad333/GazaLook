/// App-wide immutable constants for GazaLook.
abstract final class AppConstants {
  const AppConstants._();

  static const String appName = 'GazaLook';

  /// Base URL of the GazaLook backend API (see /backend). Defaults to the live
  /// InfinityFree deployment; override at build time with
  /// `flutter build apk --dart-define=API_BASE_URL=https://your-host`.
  /// Set to an empty define to force the bundled demo catalog instead.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gazalook.great-site.net',
  );

  /// Whether a real backend is configured.
  static bool get hasApiBackend => apiBaseUrl.isNotEmpty;

  /// Currency: Israeli Shekel.
  static const String currencySymbol = '₪';
  static const String currencyCode = 'ILS';

  /// Supported Gaza phone prefixes.
  static const String phonePrefixPS = '+970';
  static const String phonePrefixIL = '+972';

  /// Gaza governorates used by the delivery address selector.
  static const List<String> gazaGovernorates = <String>[
    'شمال غزة', // North Gaza
    'مدينة غزة', // Gaza City
    'المحافظة الوسطى', // Middle Area
    'خانيونس', // Khan Younis
    'رفح', // Rafah
  ];

  /// Hive box names used for local caching.
  static const String cartBox = 'cart_box';
  static const String sessionBox = 'session_box';
  static const String wishlistBox = 'wishlist_box';
}
