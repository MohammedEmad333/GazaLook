import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product_category.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_sliver_grid.dart';

/// Product listing for a single catalog [filter] (a tapped category or the
/// offers view). Owns a fresh [ProductsBloc] seeded with the filter and reuses
/// the shared [ProductSliverGrid] so loading / empty / error / grid states all
/// look and behave exactly like the home feed.
class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key, required this.filter});

  final CatalogFilter filter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsBloc>(
      create: (_) =>
          sl<ProductsBloc>()..add(ProductsFilterSelected(filter)),
      child: Scaffold(
        appBar: AppBar(title: Text(filter.labelAr)),
        body: CustomScrollView(
          slivers: <Widget>[
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.stackBase),
            ),
            const ProductSliverGrid(),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.sectionGap),
            ),
          ],
        ),
      ),
    );
  }
}
