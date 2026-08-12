import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../products/presentation/bloc/products_bloc.dart';
import '../../../products/presentation/bloc/wishlist_cubit.dart';
import '../../../products/presentation/widgets/product_sliver_grid.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_strip.dart';
import '../widgets/home_filter_chips.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/promo_carousel.dart';

/// The GazaLook home feed: search + filter chips, promo carousel, category
/// shortcuts and the product grid — the app's primary shopping surface.
///
/// Owns the [HomeBloc] and [ProductsBloc] (fresh per visit) and reuses the
/// app-wide singleton [WishlistCubit] so hearts stay in sync everywhere.
class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
        ),
        BlocProvider<ProductsBloc>(
          create: (_) => sl<ProductsBloc>()..add(const ProductsStarted()),
        ),
        BlocProvider<WishlistCubit>.value(value: sl<WishlistCubit>()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _refresh(BuildContext context) async {
    context.read<HomeBloc>().add(const HomeStarted());
    context
        .read<ProductsBloc>()
        .add(ProductsFilterSelected(context.read<ProductsBloc>().state.activeFilter));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(current: AppTab.home),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: CustomScrollView(
          slivers: <Widget>[
            // Search bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.containerMargin,
                AppDimensions.containerMargin,
                AppDimensions.containerMargin,
                AppDimensions.stackBase,
              ),
              sliver: const SliverToBoxAdapter(child: HomeSearchBar()),
            ),

            // Filter chips
            const SliverToBoxAdapter(child: HomeFilterChips()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.stackBase),
            ),

            // Promo carousel
            const SliverToBoxAdapter(child: PromoCarousel()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.sectionGap),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'التصنيفات', theme: theme),
            ),
            const SliverToBoxAdapter(child: CategoryStrip()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.sectionGap),
            ),

            // Product grid header
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'اكتشف للتو', theme: theme),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.stackBase),
            ),

            // Products
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.containerMargin,
        vertical: AppDimensions.stackBase,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: theme.textTheme.headlineMedium),
          Text(
            'عرض الكل',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
