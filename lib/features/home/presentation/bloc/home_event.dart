part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Load home content (banners).
class HomeStarted extends HomeEvent {
  const HomeStarted();
}
