import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/cached_product_image.dart';
import '../../domain/entities/product.dart';
import '../bloc/wishlist_cubit.dart';

/// A single catalog card: 3:4 image, wishlist heart, optional "محلي" badge,
/// name, rating and price. Tapping opens the product detail page.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The image flexes to fill whatever height the grid cell leaves after
          // the name/price block, so the card never overflows regardless of the
          // cell's exact height (fixes the "Bottom overflowed" render error).
          Expanded(child: _ImageBlock(product: product)),
          const SizedBox(height: AppDimensions.stackTight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                _PriceAndRating(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppDimensions.borderRadiusXl,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedProductImage(imageUrl: product.imageUrl),

            // Wishlist heart (top-start).
            PositionedDirectional(
              top: AppDimensions.stackBase,
              start: AppDimensions.stackBase,
              child: _WishlistHeart(productId: product.id),
            ),

            // "محلي" badge (bottom-end).
            if (product.isLocal)
              PositionedDirectional(
                bottom: AppDimensions.stackBase,
                end: AppDimensions.stackBase,
                child: _Badge(
                  label: 'محلي',
                  background: AppColors.secondaryContainer,
                  foreground: AppColors.onSecondaryContainer,
                ),
              ),

            // Out-of-stock veil.
            if (!product.inStock)
              const _OutOfStockOverlay(),
          ],
        ),
      ),
    );
  }
}

class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.select(
      (WishlistCubit c) => c.state.contains(productId),
    );
    return Material(
      color: AppColors.surface.withOpacity(0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.read<WishlistCubit>().toggle(productId),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFavorite ? AppColors.primary : AppColors.outline,
          ),
        ),
      ),
    );
  }
}

class _PriceAndRating extends StatelessWidget {
  const _PriceAndRating({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Text(
          CurrencyFormatter.format(product.price),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (product.isOnOffer) ...<Widget>[
          const SizedBox(width: 6),
          Text(
            CurrencyFormatter.format(product.oldPrice!),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.outline,
            ),
          ),
        ],
        const Spacer(),
        if (product.ratingCount > 0) ...<Widget>[
          const Icon(Icons.star, size: 14, color: AppColors.secondary),
          const SizedBox(width: 2),
          Text(
            product.rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _OutOfStockOverlay extends StatelessWidget {
  const _OutOfStockOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface.withOpacity(0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inverseSurface.withOpacity(0.75),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            'نفد المخزون',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.inverseOnSurface,
                ),
          ),
        ),
      ),
    );
  }
}
