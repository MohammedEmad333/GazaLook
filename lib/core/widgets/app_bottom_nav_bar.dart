import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// The five primary destinations, matching the design's bottom bar.
enum AppTab {
  home(Icons.home_outlined, Icons.home, 'الرئيسية', AppRoutes.home),
  categories(Icons.category_outlined, Icons.category, 'التصنيفات',
      AppRoutes.categories),
  cart(Icons.shopping_cart_outlined, Icons.shopping_cart, 'السلة',
      AppRoutes.cart),
  wishlist(Icons.favorite_border, Icons.favorite, 'المفضلة',
      AppRoutes.wishlist),
  profile(Icons.person_outline, Icons.person, 'حسابي', AppRoutes.profile);

  const AppTab(this.icon, this.activeIcon, this.label, this.route);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Shared bottom navigation bar with an active "pill" highlight.
///
/// Navigates with `go` so switching tabs replaces the stack rather than
/// pushing endlessly. Reused across the top-level screens.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.current});

  final AppTab current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (final AppTab tab in AppTab.values)
                _NavItem(
                  tab: tab,
                  selected: tab == current,
                  onTap: () {
                    if (tab != current) context.go(tab.route);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              selected ? tab.activeIcon : tab.icon,
              size: 24,
              color: selected
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 10,
                color: selected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
