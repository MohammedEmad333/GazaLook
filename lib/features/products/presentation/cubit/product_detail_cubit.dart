import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_by_id.dart';

part 'product_detail_state.dart';

/// Loads a single product for the detail page, with explicit
/// loading / success / failure states.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getProductById)
      : super(const ProductDetailState());

  final GetProductById _getProductById;

  Future<void> load(String id) async {
    emit(const ProductDetailState(status: ProductDetailStatus.loading));
    final result = await _getProductById(GetProductByIdParams(id: id));
    result.fold(
      (failure) => emit(
        ProductDetailState(
          status: ProductDetailStatus.failure,
          message: failure.message,
        ),
      ),
      (Product product) => emit(
        ProductDetailState(
          status: ProductDetailStatus.success,
          product: product,
        ),
      ),
    );
  }
}
