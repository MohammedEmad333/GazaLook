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

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Wires up dependencies. Call once from `main()` before `runApp`.
Future<void> initDependencies() async {
  // ---- External ------------------------------------------------------------
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ---- Feature: auth -------------------------------------------------------
  _initAuth();
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
