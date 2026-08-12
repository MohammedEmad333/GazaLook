part of 'product_detail_cubit.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.message,
  });

  final ProductDetailStatus status;
  final Product? product;
  final String? message;

  @override
  List<Object?> get props => <Object?>[status, product, message];
}
