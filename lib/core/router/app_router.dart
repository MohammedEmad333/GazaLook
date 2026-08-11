import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/placeholder_screen.dart';
import 'app_routes.dart';

/// Application router built on `go_router`.
///
/// Phase 1 wires the shell and route table with placeholder destinations so
/// navigation is exercised end-to-end. Each subsequent phase swaps its
/// placeholder for the real screen (auth → home → PDP → cart/checkout).
abstract final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'الرئيسية', icon: Icons.home_outlined),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const PlaceholderScreen(
          title: 'أهلاً بك',
          icon: Icons.waving_hand_outlined,
        ),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const PlaceholderScreen(
          title: 'السلة',
          icon: Icons.shopping_cart_outlined,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const PlaceholderScreen(
          title: 'حسابي',
          icon: Icons.person_outline,
        ),
      ),
    ],
    errorBuilder: (context, state) => PlaceholderScreen(
      title: 'الصفحة غير موجودة',
      icon: Icons.error_outline,
      message: state.error?.toString() ?? '404',
    ),
  );
}
