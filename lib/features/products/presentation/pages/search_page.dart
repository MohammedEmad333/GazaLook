import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../cubit/search_cubit.dart';
import '../widgets/product_card.dart';

/// Full search screen: a live text field over the catalog with result grid,
/// "no results" and idle prompt states.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) context.read<SearchCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (String v) => context.read<SearchCubit>().search(v),
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'ابحث عن أحدث التصاميم...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.outline.withOpacity(0.7),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'مسح',
            onPressed: () {
              _controller.clear();
              context.read<SearchCubit>().clear();
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (BuildContext context, SearchState state) {
          switch (state.status) {
            case SearchStatus.idle:
              return const EmptyView(
                message: 'ابحث عن المنتجات بالاسم أو الوصف.',
                icon: Icons.search,
              );
            case SearchStatus.loading:
              return const LoadingView();
            case SearchStatus.failure:
              return ErrorView(
                message: 'تعذّر إجراء البحث. حاول مرة أخرى.',
                onRetry: () =>
                    context.read<SearchCubit>().search(state.query),
              );
            case SearchStatus.empty:
              return EmptyView(
                message: 'لا توجد نتائج لـ "${state.query}".',
                icon: Icons.search_off,
              );
            case SearchStatus.results:
              return _ResultsGrid(results: state.results);
          }
        },
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results});

  final List<Product> results;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.containerMargin),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.gutter,
        mainAxisSpacing: AppDimensions.gutter,
        childAspectRatio: 0.62,
      ),
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) =>
          ProductCard(product: results[index]),
    );
  }
}
