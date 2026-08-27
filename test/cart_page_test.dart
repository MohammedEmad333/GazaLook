import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/core/theme/app_theme.dart';
import 'package:gazalook/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:gazalook/features/cart/data/models/cart_item_model.dart';
import 'package:gazalook/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:gazalook/features/cart/presentation/pages/cart_page.dart';
import 'package:gazalook/features/products/domain/entities/product.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

/// In-memory cart store so the page can be exercised without SharedPreferences.
class _FakeCartLocal implements CartLocalDataSource {
  _FakeCartLocal(this._items);

  List<CartItemModel> _items;

  @override
  List<CartItemModel> getItems() => _items;

  @override
  Future<void> saveItems(List<CartItemModel> items) async => _items = items;
}

Widget _wrap(CartCubit cubit) {
  return BlocProvider<CartCubit>.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const CartPage(),
    ),
  );
}

void main() {
  const product = Product(
    id: 'p1',
    name: 'قميص قطني',
    price: 120,
    imageUrl: 'https://example.com/x.jpg',
    category: ProductCategory.women,
    sizes: <String>['M'],
  );

  testWidgets(
    'renders line item and checkout summary without a layout overflow',
    (WidgetTester tester) async {
      // Regression: the checkout FilledButton sits in a Row next to a Spacer.
      // The themed `minimumSize` (Size.fromHeight) leaves its width unbounded,
      // which used to throw "BoxConstraints forces an infinite width" and left
      // the cart blank/frozen. Guard that the page lays out cleanly.
      final CartCubit cubit = CartCubit(
        _FakeCartLocal(<CartItemModel>[
          const CartItemModel(product: product, quantity: 2, size: 'M'),
        ]),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_wrap(cubit));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('قميص قطني'), findsOneWidget);
      expect(find.textContaining('المتابعة للدفع'), findsOneWidget);
    },
  );

  testWidgets('shows the empty state when the cart has no items',
      (WidgetTester tester) async {
    final CartCubit cubit = CartCubit(_FakeCartLocal(<CartItemModel>[]));
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('سلة المشتريات فارغة'), findsOneWidget);
  });
}
