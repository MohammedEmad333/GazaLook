import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/arabic_text.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

part 'search_state.dart';

/// Drives the search screen. The catalog is loaded once (lazily) and then
/// filtered client-side by name / description, so results are instant and work
/// offline — a good fit for low-bandwidth users.
///
/// Swap [_getProducts] for a server-side search later without touching the UI.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._getProducts) : super(const SearchState());

  final GetProducts _getProducts;

  List<Product> _catalog = const <Product>[];
  bool _loaded = false;

  /// Runs a search for [rawQuery]. An empty query resets to the idle state.
  Future<void> search(String rawQuery) async {
    final String query = rawQuery.trim();
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(SearchState(status: SearchStatus.loading, query: query));

    if (!_loaded) {
      final result = await _getProducts(const GetProductsParams());
      final bool failed = result.fold(
        (_) => true,
        (List<Product> products) {
          _catalog = products;
          _loaded = true;
          return false;
        },
      );
      if (failed) {
        emit(SearchState(status: SearchStatus.failure, query: query));
        return;
      }
    }

    // The query may have changed while the catalog was loading; keep the latest.
    if (state.query != query) return;

    // Arabic-aware match: fold alef/taa-marbuta/diacritic variants so shoppers
    // find products however they spell the query (see [ArabicText]).
    final String needle = ArabicText.normalize(query);
    final List<Product> matches = _catalog
        .where((Product p) =>
            ArabicText.normalize(p.name).contains(needle) ||
            ArabicText.normalize(p.description).contains(needle))
        .toList(growable: false);

    emit(
      SearchState(
        status:
            matches.isEmpty ? SearchStatus.empty : SearchStatus.results,
        query: query,
        results: matches,
      ),
    );
  }

  /// Clears the field back to the idle prompt.
  void clear() => emit(const SearchState());
}
