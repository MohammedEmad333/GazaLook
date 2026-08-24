part of 'search_cubit.dart';

enum SearchStatus { idle, loading, results, empty, failure }

/// Search screen state: the current query and its matching products.
class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const <Product>[],
  });

  final SearchStatus status;
  final String query;
  final List<Product> results;

  @override
  List<Object?> get props => <Object?>[status, query, results];
}
