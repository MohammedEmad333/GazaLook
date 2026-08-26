import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/continue_as_guest.dart';
import '../../features/auth/domain/usecases/get_cached_user.dart';
import '../../features/auth/domain/usecases/request_otp.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_cubit.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_banners.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/datasources/wishlist_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_product_by_id.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';
import '../../features/products/presentation/bloc/wishlist_cubit.dart';
import '../../features/products/presentation/cubit/product_detail_cubit.dart';
import '../../features/products/presentation/cubit/search_cubit.dart';
import '../../features/products/presentation/cubit/wishlist_products_cubit.dart';
import '../../features/orders/data/datasources/order_local_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/domain/usecases/place_order.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/wallet/data/datasources/wallet_datasource.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Wires up dependencies. Call once from `main()` before `runApp`.
Future<void> initDependencies() async {
  // ---- External ------------------------------------------------------------
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ---- Features ------------------------------------------------------------
  _initAuth();
  _initProducts();
  _initHome();
  _initCart();
  _initOrders();
  _initWallet();
}

void _initWallet() {
  sl
    ..registerLazySingleton<WalletDataSource>(
      () => MockWalletDataSource(sl<SharedPreferences>()),
    )
    // App-wide wallet (balance + history shared across wallet/top-up screens).
    ..registerLazySingleton(() => WalletCubit(sl<WalletDataSource>()));
}

void _initAuth() {
  // Data sources
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => const MockAuthRemoteDataSource(),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    // Repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl<AuthRemoteDataSource>(),
        local: sl<AuthLocalDataSource>(),
      ),
    )
    // Use cases
    ..registerLazySingleton(() => RequestOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()))
    ..registerLazySingleton(() => ContinueAsGuest(sl<AuthRepository>()))
    ..registerLazySingleton(() => GetCachedUser(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOut(sl<AuthRepository>()))
    // Bloc (factory — new instance per injection, closed by its owner)
    ..registerFactory(
      () => AuthBloc(
        requestOtp: sl<RequestOtp>(),
        verifyOtp: sl<VerifyOtp>(),
        continueAsGuest: sl<ContinueAsGuest>(),
        getCachedUser: sl<GetCachedUser>(),
        signOut: sl<SignOut>(),
      ),
    );
}

void _initProducts() {
  sl
    // Data sources
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => const MockProductRemoteDataSource(),
    )
    ..registerLazySingleton<WishlistLocalDataSource>(
      () => WishlistLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    // Repository
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remote: sl<ProductRemoteDataSource>()),
    )
    // Use cases
    ..registerLazySingleton(() => GetProducts(sl<ProductRepository>()))
    ..registerLazySingleton(() => GetProductById(sl<ProductRepository>()))
    // Catalog grid bloc (fresh per screen)
    ..registerFactory(() => ProductsBloc(getProducts: sl<GetProducts>()))
    // Product detail cubit (fresh per PDP visit)
    ..registerFactory(() => ProductDetailCubit(sl<GetProductById>()))
    // Catalog search (fresh per search-screen visit).
    ..registerFactory(() => SearchCubit(sl<GetProducts>()))
    // Wishlist catalog loader (fresh per wishlist-screen visit).
    ..registerFactory(() => WishlistProductsCubit(sl<GetProducts>()))
    // Wishlist is app-wide (single source of truth, persisted) → singleton.
    ..registerLazySingleton(
      () => WishlistCubit(sl<WishlistLocalDataSource>()),
    );
}

void _initCart() {
  sl
    ..registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    // Cart is app-wide (badge + PDP + cart screen share it), persisted.
    ..registerLazySingleton(() => CartCubit(sl<CartLocalDataSource>()))
    // Checkout form/submission cubit (fresh per checkout visit).
    ..registerFactory(() => CheckoutCubit(sl<PlaceOrder>()));
}

void _initOrders() {
  sl
    ..registerLazySingleton<OrderLocalDataSource>(
      () => OrderLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(local: sl<OrderLocalDataSource>()),
    )
    ..registerLazySingleton(() => PlaceOrder(sl<OrderRepository>()))
    ..registerLazySingleton(() => GetOrders(sl<OrderRepository>()))
    // Fresh per orders-screen visit; reads from the persisted store.
    ..registerFactory(() => OrdersCubit(sl<GetOrders>()));
}

void _initHome() {
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => const MockHomeRemoteDataSource(),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remote: sl<HomeRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetBanners(sl<HomeRepository>()))
    ..registerFactory(() => HomeBloc(getBanners: sl<GetBanners>()));
}
