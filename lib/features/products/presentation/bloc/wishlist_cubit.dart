import 'package:bloc/bloc.dart';

import '../../data/datasources/wishlist_local_datasource.dart';

/// Manages the user's wishlist (the "heart" toggle on product cards).
///
/// State is the set of favourited product ids; changes are persisted locally.
/// A single app-wide instance keeps every card's heart in sync.
class WishlistCubit extends Cubit<Set<String>> {
  WishlistCubit(this._local) : super(_local.getIds());

  final WishlistLocalDataSource _local;

  bool isFavorite(String productId) => state.contains(productId);

  /// Adds or removes [productId] and persists the new set.
  Future<void> toggle(String productId) async {
    final Set<String> next = Set<String>.of(state);
    if (!next.remove(productId)) {
      next.add(productId);
    }
    emit(next);
    await _local.saveIds(next);
  }
}
