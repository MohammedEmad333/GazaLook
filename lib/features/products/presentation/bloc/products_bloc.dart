import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/usecases/get_products.dart';

part 'products_event.dart';
part 'products_state.dart';

/// Drives the catalog grid: initial load and filter-chip changes, with
/// explicit loading / success / empty / failure states.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({required GetProducts getProducts})
      : _getProducts = getProducts,
        super(const ProductsState()) {
    on<ProductsStarted>(_onStarted);
    on<ProductsFilterSelected>(_onFilterSelected);
  }

  final GetProducts _getProducts;

  Future<void> _onStarted(
    ProductsStarted event,
    Emitter<ProductsState> emit,
  ) =>
      _load(state.activeFilter, emit);

  Future<void> _onFilterSelected(
    ProductsFilterSelected event,
    Emitter<ProductsState> emit,
  ) =>
      _load(event.filter, emit);

  Future<void> _load(CatalogFilter filter, Emitter<ProductsState> emit) async {
    emit(state.copyWith(status: ProductsStatus.loading, activeFilter: filter));
    final result = await _getProducts(GetProductsParams(filter: filter));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductsStatus.failure,
          message: failure.message,
        ),
      ),
      (List<Product> products) => emit(
        state.copyWith(
          status: products.isEmpty
              ? ProductsStatus.empty
              : ProductsStatus.success,
          products: products,
        ),
      ),
    );
  }
}
