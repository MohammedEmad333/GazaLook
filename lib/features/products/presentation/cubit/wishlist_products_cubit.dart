import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

part 'wishlist_products_state.dart';

/// Loads the full catalog for the wishlist screen. The screen then intersects
/// this list with the app-wide [WishlistCubit] ids to show only favourited
/// products, so hearts stay in sync everywhere.
class WishlistProductsCubit extends Cubit<WishlistProductsState> {
  WishlistProductsCubit(this._getProducts)
      : super(const WishlistProductsState());

  final GetProducts _getProducts;

  Future<void> load() async {
    emit(const WishlistProductsState(status: WishlistProductsStatus.loading));
    final result = await _getProducts(const GetProductsParams());
    result.fold(
      (failure) => emit(
        WishlistProductsState(
          status: WishlistProductsStatus.failure,
          message: failure.message,
        ),
      ),
      (List<Product> products) => emit(
        WishlistProductsState(
          status: WishlistProductsStatus.success,
          products: products,
        ),
      ),
    );
  }
}
