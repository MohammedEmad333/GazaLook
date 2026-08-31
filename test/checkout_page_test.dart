import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/core/di/injection_container.dart';
import 'package:gazalook/core/error/failures.dart';
import 'package:gazalook/core/theme/app_theme.dart';
import 'package:gazalook/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:gazalook/features/cart/data/models/cart_item_model.dart';
import 'package:gazalook/features/cart/domain/entities/cart_item.dart';
import 'package:gazalook/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:gazalook/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:gazalook/features/cart/presentation/pages/checkout_page.dart';
import 'package:gazalook/features/orders/domain/entities/order.dart';
import 'package:gazalook/features/orders/domain/repositories/order_repository.dart';
import 'package:gazalook/features/orders/domain/usecases/place_order.dart';
import 'package:gazalook/features/products/domain/entities/product.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

/// In-memory cart store so the page runs without SharedPreferences.
class _FakeCartLocal implements CartLocalDataSource {
  _FakeCartLocal(this._items);

  List<CartItemModel> _items;

  @override
  List<CartItemModel> getItems() => _items;

  @override
  Future<void> saveItems(List<CartItemModel> items) async => _items = items;
}

/// Order repository that just accepts every order.
class _FakeOrderRepository implements OrderRepository {
  @override
  Future<Either<Failure, Unit>> placeOrder(Order order) async =>
      const Right(unit);

  @override
  Future<Either<Failure, List<Order>>> getOrders() async =>
      const Right(<Order>[]);
}

Widget _wrap(CartCubit cart) {
  return BlocProvider<CartCubit>.value(
    value: cart,
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const CheckoutPage(),
    ),
  );
}

void main() {
  const product = Product(
    id: 'p1',
    name: 'فستان سهرة أنيق',
    price: 370,
    imageUrl: 'https://example.com/x.jpg',
    category: ProductCategory.women,
    sizes: <String>['M'],
  );

  setUp(() {
    // CheckoutPage resolves its cubit from the service locator.
    if (sl.isRegistered<CheckoutCubit>()) sl.unregister<CheckoutCubit>();
    sl.registerFactory<CheckoutCubit>(
      () => CheckoutCubit(PlaceOrder(_FakeOrderRepository())),
    );
  });

  tearDown(() => sl.reset());

  testWidgets(
    'renders the checkout form and summary without a layout exception',
    (WidgetTester tester) async {
      final CartCubit cart = CartCubit(
        _FakeCartLocal(<CartItemModel>[
          CartItemModel.fromEntity(
            const CartItem(product: product, quantity: 1),
          ),
        ]),
      );
      addTearDown(cart.close);

      // Use a tall surface so the whole scrollable form fits without the
      // ListView lazily dropping off-screen sections.
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(cart));
      await tester.pumpAndSettle();

      // Regression: the total Column in the bottom bar used to expand to full
      // height and collapse the body to zero, so no section rendered at all.
      expect(tester.takeException(), isNull);

      // The three sections all render (they collapsed to nothing before the
      // fix).
      expect(find.text('التوصيل'), findsOneWidget);
      expect(find.text('طريقة الدفع'), findsOneWidget);
      expect(find.text('ملخص الطلب'), findsOneWidget);
      // 'إتمام الطلب' is both the AppBar title and the CTA label, so ≥1.
      expect(find.text('إتمام الطلب'), findsWidgets);
    },
  );
}
