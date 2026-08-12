import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// App navigation drawer opened from the home header menu.
///
/// Shows who is signed in (real user or guest), quick links, and sign-out —
/// keeping the full auth loop reachable from the main shell.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthUser? user = context.select((AuthBloc b) => b.state.user);
    final bool isGuest = user?.isGuest ?? true;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      isGuest ? Icons.person_outline : Icons.person,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.componentPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                        Text(
                          isGuest ? 'زائر' : (user?.phoneNumber ?? ''),
                          textDirection: TextDirection.ltr,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'الرئيسية',
              onTap: () => _go(context, AppRoutes.home),
            ),
            _DrawerItem(
              icon: Icons.favorite_border,
              label: 'المفضلة',
              onTap: () => _go(context, AppRoutes.wishlist),
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_outlined,
              label: 'السلة',
              onTap: () => _go(context, AppRoutes.cart),
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'طلباتي',
              onTap: () => _go(context, AppRoutes.orders),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: isGuest ? 'تسجيل الدخول' : 'تسجيل الخروج',
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
            const SizedBox(height: AppDimensions.stackBase),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap,
    );
  }
}
