/// Central registry of route paths and names for GazaLook.
///
/// Kept as plain constants so navigation call-sites never hard-code raw
/// strings. Screens are wired up feature-by-feature across the build phases.
abstract final class AppRoutes {
  const AppRoutes._();

  // Onboarding & auth (Phase 2)
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';

  // Home & catalog (Phase 3)
  static const String home = '/';
  static const String categories = '/categories';
  static const String search = '/search';

  // Products (Phase 4)
  static const String productDetail = '/product/:id';
  static String productDetailPath(String id) => '/product/$id';

  // Cart & checkout (Phase 5)
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  // Orders & profile
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';

  // Wallet & top-up
  static const String wallet = '/wallet';
  static const String walletTopUp = '/wallet/top-up';
}
