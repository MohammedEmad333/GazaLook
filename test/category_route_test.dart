import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/core/router/app_routes.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

void main() {
  group('category products route', () {
    test('builds a path from a filter name', () {
      expect(
        AppRoutes.categoryProductsPath(CatalogFilter.women.name),
        '/category/women',
      );
      expect(
        AppRoutes.categoryProductsPath(CatalogFilter.offers.name),
        '/category/offers',
      );
    });

    test('every filter name round-trips back to its enum value', () {
      for (final CatalogFilter filter in CatalogFilter.values) {
        final CatalogFilter resolved = CatalogFilter.values.firstWhere(
          (CatalogFilter f) => f.name == filter.name,
          orElse: () => CatalogFilter.all,
        );
        expect(resolved, filter);
      }
    });
  });
}
