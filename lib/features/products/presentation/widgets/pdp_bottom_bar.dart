import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Sticky bottom action bar for the product detail page:
/// "Add to Cart" (secondary) + "Buy Now" (primary).
///
/// Disabled when the product is out of stock.
class PdpBottomBar extends StatelessWidget {
  const PdpBottomBar({
    super.key,
    required this.enabled,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final bool enabled;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.containerMargin,
            vertical: AppDimensions.componentPadding,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  label: 'أضف للسلة',
                  icon: Icons.shopping_bag_outlined,
                  background: AppColors.secondaryContainer,
                  foreground: AppColors.onSecondaryContainer,
                  onTap: enabled ? onAddToCart : null,
                ),
              ),
              const SizedBox(width: AppDimensions.gutter),
              Expanded(
                child: _ActionButton(
                  label: 'اشترِ الآن',
                  icon: Icons.bolt,
                  background: AppColors.primaryContainer,
                  foreground: AppColors.onPrimaryContainer,
                  onTap: enabled ? onBuyNow : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: AppDimensions.borderRadiusXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.borderRadiusXl,
          child: Container(
            height: AppDimensions.buttonHeight,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: AppDimensions.stackBase),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
