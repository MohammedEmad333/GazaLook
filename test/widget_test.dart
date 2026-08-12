import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/core/utils/currency_formatter.dart';
import 'package:gazalook/core/utils/phone_validator.dart';
import 'package:gazalook/features/products/domain/entities/product.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats whole shekel amounts without decimals', () {
      expect(CurrencyFormatter.format(120), '120 ₪');
      expect(CurrencyFormatter.format(250), '250 ₪');
    });

    test('keeps two decimals for fractional amounts', () {
      expect(CurrencyFormatter.format(19.9), '19.90 ₪');
    });
  });

  group('PhoneValidator', () {
    test('accepts a valid local Gaza mobile number', () {
      expect(PhoneValidator.isValidLocalMobile('59 123 4567'), isTrue);
      expect(PhoneValidator.isValidLocalMobile('0591234567'), isTrue);
    });

    test('rejects malformed numbers', () {
      expect(PhoneValidator.isValidLocalMobile('12345'), isFalse);
      expect(PhoneValidator.isValidLocalMobile('691234567'), isFalse);
    });

    test('normalises to E.164 with the given prefix', () {
      expect(PhoneValidator.toE164('0591234567', '+970'), '+970591234567');
      expect(PhoneValidator.toE164('59 123 4567', '+972'), '+972591234567');
    });
  });

  group('CatalogFilter', () {
    test('maps a product category to its filter', () {
      expect(
        CatalogFilter.fromCategory(ProductCategory.women),
        CatalogFilter.women,
      );
      expect(
        CatalogFilter.fromCategory(ProductCategory.accessories),
        CatalogFilter.accessories,
      );
    });

    test('exposes exactly the five design chips', () {
      expect(CatalogFilter.chips, <CatalogFilter>[
        CatalogFilter.all,
        CatalogFilter.women,
        CatalogFilter.men,
        CatalogFilter.kids,
        CatalogFilter.offers,
      ]);
    });
  });

  group('Product', () {
    test('isOnOffer reflects a lower current price', () {
      const onOffer = Product(
        id: 'x',
        name: 'test',
        price: 95,
        oldPrice: 130,
        imageUrl: '',
        category: ProductCategory.men,
      );
      const notOnOffer = Product(
        id: 'y',
        name: 'test',
        price: 95,
        imageUrl: '',
        category: ProductCategory.men,
      );
      expect(onOffer.isOnOffer, isTrue);
      expect(notOnOffer.isOnOffer, isFalse);
    });
  });
}
