import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/availability_badge.dart';
import '../widgets/pdp_bottom_bar.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/size_selector.dart';
import '../bloc/wishlist_cubit.dart';

/// Product Detail Page (PDP).
///
/// Loads a product by id and shows the image gallery (with zoom), price,
/// local availability, size selection (+ size guide) and a sticky
/// Add-to-Cart / Buy-Now bar.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailCubit>(
      create: (_) => sl<ProductDetailCubit>()..load(productId),
      child: _ProductDetailView(productId: productId),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView({required this.productId});

  final String productId;

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  String? _selectedSize;

  bool _requireSizeSatisfied(Product product) =>
      product.sizes.isEmpty || _selectedSize != null;

  void _onAddToCart(Product product, {required bool buyNow}) {
    if (!_requireSizeSatisfied(product)) {
      _showSnack('يرجى اختيار المقاس');
      return;
    }
    context
        .read<CartCubit>()
        .addItem(product, size: _selectedSize);

    if (buyNow) {
      context.push(AppRoutes.cart);
    } else {
      _showSnack('تمت الإضافة إلى السلة', actionToCart: true);
    }
  }

  void _showSnack(String message, {bool actionToCart = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionToCart
              ? SnackBarAction(
                  label: 'عرض السلة',
                  onPressed: () => context.push(AppRoutes.cart),
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (BuildContext context, ProductDetailState state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, state.product),
          bottomNavigationBar:
              state.status == ProductDetailStatus.success &&
                      state.product != null
                  ? PdpBottomBar(
                      enabled: state.product!.inStock,
                      onAddToCart: () =>
                          _onAddToCart(state.product!, buyNow: false),
                      onBuyNow: () =>
                          _onAddToCart(state.product!, buyNow: true),
                    )
                  : null,
          body: switch (state.status) {
            ProductDetailStatus.initial ||
            ProductDetailStatus.loading =>
              const LoadingView(),
            ProductDetailStatus.failure => ErrorView(
                message: state.message ?? 'تعذّر تحميل المنتج.',
                onRetry: () => context
                    .read<ProductDetailCubit>()
                    .load(widget.productId),
              ),
            ProductDetailStatus.success =>
              _Content(
                product: state.product!,
                selectedSize: _selectedSize,
                onSizeSelected: (String s) =>
                    setState(() => _selectedSize = s),
              ),
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Product? product) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const _CircleButton(icon: BackButtonIcon(), isBack: true),
      actions: <Widget>[
        const _CircleButton(icon: Icon(Icons.share_outlined)),
        if (product != null) _FavoriteButton(product: product),
        const SizedBox(width: AppDimensions.stackBase),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.product,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  final Product product;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ProductImageSlider(images: product.gallery),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.name, style: theme.textTheme.displayMedium),
              const SizedBox(height: AppDimensions.stackTight),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: theme.textTheme.displayMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                  if (product.isOnOffer) ...<Widget>[
                    const SizedBox(width: AppDimensions.stackBase),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        CurrencyFormatter.format(product.oldPrice!),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.componentPadding),
              AvailabilityBadge(
                inStock: product.inStock,
                storeName: product.storeName,
              ),
              const SizedBox(height: AppDimensions.componentPadding),
              if (product.ratingCount > 0)
                _RatingRow(product: product, theme: theme),
              const Divider(height: AppDimensions.sectionGap),
              if (product.sizes.isNotEmpty) ...<Widget>[
                SizeSelector(
                  sizes: product.sizes,
                  selected: selectedSize,
                  onSelected: onSizeSelected,
                ),
                const Divider(height: AppDimensions.sectionGap),
              ],
              Text(
                'تفاصيل القطعة',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.stackBase),
              Text(
                product.description.isNotEmpty
                    ? product.description
                    : 'لا يوجد وصف متاح لهذه القطعة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppDimensions.sectionGap),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product, required this.theme});

  final Product product;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.star, size: 18, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(
          product.rating.toStringAsFixed(1),
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.ratingCount} تقييم)',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Circular translucent header button (back / share / favourite).
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.onTap,
    this.isBack = false,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: AppColors.surfaceContainerLow.withOpacity(0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          iconSize: 22,
          color: AppColors.onSurface,
          icon: icon,
          onPressed:
              isBack ? () => Navigator.of(context).maybePop() : onTap,
        ),
      ),
    );
  }
}

/// Header favourite toggle backed by the app-wide [WishlistCubit].
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.select(
      (WishlistCubit c) => c.state.contains(product.id),
    );
    return _CircleButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppColors.primary : null,
      ),
      onTap: () => context.read<WishlistCubit>().toggle(product.id),
    );
  }
}
