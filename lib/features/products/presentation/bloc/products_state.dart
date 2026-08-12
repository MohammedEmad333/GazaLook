part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, success, empty, failure }

/// Catalog grid state. Carries the active filter so the chips stay in sync.
class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const <Product>[],
    this.activeFilter = CatalogFilter.all,
    this.message,
  });

  final ProductsStatus status;
  final List<Product> products;
  final CatalogFilter activeFilter;

  /// Error message, present when [status] is [ProductsStatus.failure].
  final String? message;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    CatalogFilter? activeFilter,
    String? message,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      activeFilter: activeFilter ?? this.activeFilter,
      message: message,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, products, activeFilter, message];
}
