import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

/// [ProductRepository] backed by a remote (currently mock) data source.
///
/// Category/offer filtering is applied here so the data source stays a dumb
/// catalog provider.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required ProductRemoteDataSource remote})
      : _remote = remote;

  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    CatalogFilter filter = CatalogFilter.all,
  }) async {
    try {
      final products = await _remote.fetchProducts();
      return Right(_applyFilter(products, filter));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      return Right(await _remote.fetchProductById(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  List<Product> _applyFilter(List<Product> all, CatalogFilter filter) {
    return switch (filter) {
      CatalogFilter.all => all,
      CatalogFilter.offers =>
        all.where((Product p) => p.isOnOffer).toList(growable: false),
      CatalogFilter.women => _byCategory(all, ProductCategory.women),
      CatalogFilter.men => _byCategory(all, ProductCategory.men),
      CatalogFilter.kids => _byCategory(all, ProductCategory.kids),
      CatalogFilter.accessories =>
        _byCategory(all, ProductCategory.accessories),
    };
  }

  List<Product> _byCategory(List<Product> all, ProductCategory category) =>
      all.where((Product p) => p.category == category).toList(growable: false);
}
