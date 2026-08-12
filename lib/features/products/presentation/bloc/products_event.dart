part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial catalog load.
class ProductsStarted extends ProductsEvent {
  const ProductsStarted();
}

/// A filter chip was tapped.
class ProductsFilterSelected extends ProductsEvent {
  const ProductsFilterSelected(this.filter);

  final CatalogFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}
