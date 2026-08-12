import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/usecases/get_banners.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads home-screen content (promo banners) with explicit state handling.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetBanners getBanners})
      : _getBanners = getBanners,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  final GetBanners _getBanners;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    final result = await _getBanners(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: HomeStatus.failure, message: failure.message),
      ),
      (List<PromoBanner> banners) => emit(
        state.copyWith(status: HomeStatus.success, banners: banners),
      ),
    );
  }
}
