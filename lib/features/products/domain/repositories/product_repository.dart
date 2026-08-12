import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';

/// Contract for reading catalog products.
///
/// Backed by a mock catalog for now; swap the data source for a real API /
/// Firestore later without touching callers.
abstract interface class ProductRepository {
  /// Returns products matching [filter] (defaults to all).
  Future<Either<Failure, List<Product>>> getProducts({
    CatalogFilter filter = CatalogFilter.all,
  });

  /// Returns a single product by [id], or a [Failure] if not found.
  Future<Either<Failure, Product>> getProductById(String id);
}
