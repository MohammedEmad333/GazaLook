import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/features/products/data/models/product_model.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

/// Guards the contract between the PHP products API (ProductRepository::toApi)
/// and the Flutter model: a product JSON object returned by `/api/products`
/// must deserialize cleanly via [ProductModel.fromMap].
void main() {
  // Exactly the shape the backend emits (see backend/src/Repository/ProductRepository.php).
  const String apiProductJson = '''
  {
    "id": "p3",
    "name": "قميص كتان خفيف",
    "price": 95.0,
    "oldPrice": 130.0,
    "imageUrl": "https://img/p3",
    "category": "men",
    "description": "قميص كتان خفيف ومريح",
    "images": [],
    "sizes": ["M", "L", "XL"],
    "rating": 4.4,
    "ratingCount": 61,
    "isLocal": false,
    "inStock": true,
    "storeName": null
  }
  ''';

  test('ProductModel.fromMap parses the API product shape', () {
    final Map<String, dynamic> map =
        json.decode(apiProductJson) as Map<String, dynamic>;

    final ProductModel product = ProductModel.fromMap(map);

    expect(product.id, 'p3');
    expect(product.price, 95);
    expect(product.oldPrice, 130);
    expect(product.isOnOffer, isTrue);
    expect(product.category, ProductCategory.men);
    expect(product.sizes, <String>['M', 'L', 'XL']);
    expect(product.ratingCount, 61);
    expect(product.inStock, isTrue);
    // Empty images list falls back to the thumbnail for the gallery.
    expect(product.gallery, <String>['https://img/p3']);
  });
}
