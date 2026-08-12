part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const <PromoBanner>[],
    this.message,
  });

  final HomeStatus status;
  final List<PromoBanner> banners;
  final String? message;

  HomeState copyWith({
    HomeStatus? status,
    List<PromoBanner>? banners,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      message: message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, banners, message];
}
