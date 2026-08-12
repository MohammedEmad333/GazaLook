import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/home/presentation/pages/home_feed_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../widgets/placeholder_screen.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

/// Builds the app router and guards routes against the current [AuthState].
///
/// Redirect rules:
///   * unauthenticated  → `/login`
///   * OTP sent         → `/otp`
///   * authenticated    → the requested in-app route (default `/`)
abstract final class AppRouter {
  const AppRouter._();

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final AuthStatus status = authBloc.state.status;
        final String location = state.matchedLocation;

        // Wait for the cached-session check to resolve before redirecting.
        if (status == AuthStatus.unknown) return null;

        final bool onLogin = location == AppRoutes.login;
        final bool onOtp = location == AppRoutes.otp;

        switch (status) {
          case AuthStatus.unauthenticated:
            return onLogin ? null : AppRoutes.login;
          case AuthStatus.codeSent:
            return onOtp ? null : AppRoutes.otp;
          case AuthStatus.authenticated:
            return (onLogin || onOtp) ? AppRoutes.home : null;
          case AuthStatus.unknown:
            return null;
        }
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeFeedPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          name: 'otp',
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          name: 'productDetail',
          builder: (context, state) => ProductDetailPage(
            productId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: AppRoutes.categories,
          name: 'categories',
          builder: (context, state) => const PlaceholderScreen(
            title: 'التصنيفات',
            icon: Icons.category_outlined,
          ),
        ),
        GoRoute(
          path: AppRoutes.wishlist,
          name: 'wishlist',
          builder: (context, state) => const PlaceholderScreen(
            title: 'المفضلة',
            icon: Icons.favorite_border,
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
          path: AppRoutes.orders,
          name: 'orders',
          builder: (context, state) => const PlaceholderScreen(
            title: 'طلباتي',
            icon: Icons.receipt_long_outlined,
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
}
