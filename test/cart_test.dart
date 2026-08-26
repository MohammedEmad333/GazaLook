import 'package:flutter_test/flutter_test.dart';
import 'package:gazalook/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:gazalook/features/cart/data/models/cart_item_model.dart';
import 'package:gazalook/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:gazalook/features/products/domain/entities/product.dart';
import 'package:gazalook/features/products/domain/entities/product_category.dart';

/// In-memory [CartLocalDataSource] so the cubit can be exercised without
/// SharedPreferences / platform channels.
class _FakeCartLocalDataSource implements CartLocalDataSource {
  List<CartItemModel> _stored = <CartItemModel>[];

  @override
  List<CartItemModel> getItems() => _stored;

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    _stored = items;
  }
}

Product _product(String id, double price, {List<String> sizes = const <String>[]}) =>
    Product(
      id: id,
      name: 'p$id',
      price: price,
      imageUrl: '',
      category: ProductCategory.women,
      sizes: sizes,
    );

void main() {
  late _FakeCartLocalDataSource local;
  late CartCubit cubit;

  setUp(() {
    local = _FakeCartLocalDataSource();
    cubit = CartCubit(local);
  });

  tearDown(() => cubit.close());

  group('CartCubit.addItem', () {
    test('adds a new line and exposes it in state (not empty)', () async {
      await cubit.addItem(_product('1', 100));

      expect(cubit.state, hasLength(1));
      expect(cubit.itemCount, 1);
      expect(cubit.subtotal, 100);
    });

    test('persists every mutation to the local store', () async {
      await cubit.addItem(_product('1', 100));

      expect(local.getItems(), hasLength(1));
      expect(local.getItems().first.product.id, '1');
    });

    test('merges the same product+size into one line', () async {
      await cubit.addItem(_product('1', 100, sizes: <String>['M']), size: 'M');
      await cubit.addItem(_product('1', 100, sizes: <String>['M']), size: 'M');

      expect(cubit.state, hasLength(1));
      expect(cubit.state.single.quantity, 2);
      expect(cubit.itemCount, 2);
    });

    test('keeps the same product in different sizes as separate lines', () async {
      final Product p = _product('1', 100, sizes: <String>['M', 'L']);
      await cubit.addItem(p, size: 'M');
      await cubit.addItem(p, size: 'L');

      expect(cubit.state, hasLength(2));
      expect(cubit.itemCount, 2);
    });
  });

  group('CartCubit quantity + removal', () {
    test('increment / decrement adjust the line quantity', () async {
      await cubit.addItem(_product('1', 50));
      final String lineId = cubit.state.single.lineId;

      await cubit.increment(lineId);
      expect(cubit.state.single.quantity, 2);

      await cubit.decrement(lineId);
      expect(cubit.state.single.quantity, 1);
    });

    test('decrementing the last unit removes the line', () async {
      await cubit.addItem(_product('1', 50));
      final String lineId = cubit.state.single.lineId;

      await cubit.decrement(lineId);
      expect(cubit.state, isEmpty);
    });

    test('removeItem drops the matching line', () async {
      await cubit.addItem(_product('1', 50));
      await cubit.addItem(_product('2', 70));
      await cubit.removeItem('1__one-size');

      expect(cubit.state, hasLength(1));
      expect(cubit.state.single.product.id, '2');
    });

    test('clear empties the cart and the store', () async {
      await cubit.addItem(_product('1', 50));
      await cubit.clear();

      expect(cubit.state, isEmpty);
      expect(local.getItems(), isEmpty);
    });
  });

  test('a fresh cubit restores previously persisted items', () async {
    await cubit.addItem(_product('1', 100));
    await cubit.addItem(_product('2', 40));

    final CartCubit restored = CartCubit(local);
    addTearDown(restored.close);

    expect(restored.state, hasLength(2));
    expect(restored.subtotal, 140);
  });
}
