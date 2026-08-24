import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../bloc/wishlist_cubit.dart';
import '../cubit/wishlist_products_cubit.dart';
import '../widgets/product_card.dart';

/// The favourites screen: every product the user has hearted, backed by the
/// app-wide [WishlistCubit] (persisted locally) intersected with the catalog.
class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WishlistProductsCubit>(
      create: (_) => sl<WishlistProductsCubit>()..load(),
      child: const _WishlistView(),
    );
  }
}

class _WishlistView extends StatelessWidget {
  const _WishlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      bottomNavigationBar: const AppBottomNavBar(current: AppTab.wishlist),
      body: BlocBuilder<WishlistProductsCubit, WishlistProductsState>(
        builder: (BuildContext context, WishlistProductsState state) {
          switch (state.status) {
            case WishlistProductsStatus.initial:
            case WishlistProductsStatus.loading:
              return const LoadingView();
            case WishlistProductsStatus.failure:
              return ErrorView(
                message: state.message ?? 'تعذّر تحميل المفضلة.',
                onRetry: () =>
                    context.read<WishlistProductsCubit>().load(),
              );
            case WishlistProductsStatus.success:
              return _WishlistGrid(catalog: state.products);
          }
        },
      ),
    );
  }
}

/// Rebuilds against the live favourite-id set so removing a heart updates the
/// grid immediately.
class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({required this.catalog});

  final List<Product> catalog;

  @override
  Widget build(BuildContext context) {
    final Set<String> ids = context.watch<WishlistCubit>().state;
    final List<Product> favorites = catalog
        .where((Product p) => ids.contains(p.id))
        .toList(growable: false);

    if (favorites.isEmpty) {
      return _EmptyWishlist(onBrowse: () => context.go(AppRoutes.home));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.containerMargin),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.gutter,
        mainAxisSpacing: AppDimensions.gutter,
        childAspectRatio: 0.62,
      ),
      itemCount: favorites.length,
      itemBuilder: (BuildContext context, int index) =>
          ProductCard(product: favorites[index]),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const EmptyView(
            message: 'لم تُضِف أي منتج إلى المفضلة بعد.',
            icon: Icons.favorite_border,
          ),
          FilledButton(
            onPressed: onBrowse,
            child: const Text('تصفّح المنتجات'),
          ),
        ],
      ),
    );
  }
}
