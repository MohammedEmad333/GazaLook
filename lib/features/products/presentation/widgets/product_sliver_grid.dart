import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/state_views.dart';
import '../bloc/products_bloc.dart';
import 'product_card.dart';

/// The catalog grid as a sliver, wired to [ProductsBloc].
///
/// Renders the four async states as slivers so the whole home feed scrolls as
/// one: loading spinner, error (with retry), empty message, or a 2-column grid.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (BuildContext context, ProductsState state) {
        switch (state.status) {
          case ProductsStatus.initial:
          case ProductsStatus.loading:
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.sectionGap),
                child: LoadingView(),
              ),
            );

          case ProductsStatus.failure:
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.sectionGap,
                ),
                child: ErrorView(
                  message: state.message ?? 'تعذّر تحميل المنتجات.',
                  onRetry: () => context
                      .read<ProductsBloc>()
                      .add(ProductsFilterSelected(state.activeFilter)),
                ),
              ),
            );

          case ProductsStatus.empty:
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.sectionGap),
                child: EmptyView(
                  message: 'لا توجد منتجات ضمن هذا التصنيف حالياً.',
                  icon: Icons.checkroom_outlined,
                ),
              ),
            );

          case ProductsStatus.success:
            return SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.containerMargin,
              ),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.gutter,
                  mainAxisSpacing: AppDimensions.gutter,
                  // Room for the 3:4 image plus the name/price/rating block.
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) =>
                      ProductCard(product: state.products[index]),
                  childCount: state.products.length,
                ),
              ),
            );
        }
      },
    );
  }
}
