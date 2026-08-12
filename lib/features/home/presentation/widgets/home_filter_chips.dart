import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/domain/entities/product_category.dart';
import '../../../products/presentation/bloc/products_bloc.dart';

/// Horizontally scrollable filter chips (All / Women / Men / Kids / Offers).
///
/// Reflects and drives the [ProductsBloc]'s active filter.
class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final CatalogFilter active =
        context.select((ProductsBloc b) => b.state.activeFilter);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.containerMargin,
        ),
        itemCount: CatalogFilter.chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final CatalogFilter filter = CatalogFilter.chips[index];
          final bool selected = filter == active;
          return ChoiceChip(
            label: Text(filter.labelAr),
            selected: selected,
            showCheckmark: false,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurfaceVariant,
                ),
            onSelected: (_) => context
                .read<ProductsBloc>()
                .add(ProductsFilterSelected(filter)),
          );
        },
      ),
    );
  }
}
