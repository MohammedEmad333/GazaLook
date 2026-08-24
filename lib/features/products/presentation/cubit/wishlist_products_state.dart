part of 'wishlist_products_cubit.dart';

enum WishlistProductsStatus { initial, loading, success, failure }

/// State for the wishlist catalog load (the raw product list; the screen filters
/// it by the current favourite ids).
class WishlistProductsState extends Equatable {
  const WishlistProductsState({
    this.status = WishlistProductsStatus.initial,
    this.products = const <Product>[],
    this.message,
  });

  final WishlistProductsStatus status;
  final List<Product> products;
  final String? message;

  @override
  List<Object?> get props => <Object?>[status, products, message];
}
