import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/cached_product_image.dart';
import '../../domain/entities/cart_item.dart';
import '../cubit/cart_cubit.dart';

/// A single cart line: thumbnail, name/size, quantity stepper, delete, price.
class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CartCubit cart = context.read<CartCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackBase),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Thumbnail
          ClipRRect(
            borderRadius: AppDimensions.borderRadiusLg,
            child: SizedBox(
              width: 88,
              height: 112,
              child: CachedProductImage(imageUrl: item.product.imageUrl),
            ),
          ),
          const SizedBox(width: AppDimensions.gutter),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.outline,
                      onPressed: () => cart.removeItem(item.lineId),
                    ),
                  ],
                ),
                if (item.size != null)
                  Text(
                    'المقاس: ${item.size}',
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: AppDimensions.stackBase),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _QtyStepper(item: item, cart: cart),
                    Text(
                      CurrencyFormatter.format(item.lineTotal),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.item, required this.cart});

  final CartItem item;
  final CartCubit cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepButton(
            icon: Icons.remove,
            onTap: () => cart.decrement(item.lineId),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () => cart.increment(item.lineId),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusLg,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
