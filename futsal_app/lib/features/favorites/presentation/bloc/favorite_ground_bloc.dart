import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:futsalpay/features/favorites/domain/favorites_repository.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

part 'favorite_ground_event.dart';
part 'favorite_ground_state.dart';

class FavoriteGroundBloc
    extends Bloc<FavoriteGroundEvent, FavoriteGroundState> {
  FavoriteGroundBloc(this._repository) : super(FavoriteGroundInitial()) {
    on<LoadFavoriteGrounds>(_onLoadFavorites);
    on<RefreshFavoriteGrounds>(_onRefreshFavorites);
  }

  final FavoritesRepository _repository;

  Future<void> _onLoadFavorites(
    LoadFavoriteGrounds event,
    Emitter<FavoriteGroundState> emit,
  ) async {
    if (state is FavoriteGroundLoading) {
      return;
    }

    emit(FavoriteGroundLoading());
    await _fetchFavorites(emit);
  }

  Future<void> _onRefreshFavorites(
    RefreshFavoriteGrounds event,
    Emitter<FavoriteGroundState> emit,
  ) async {
    emit(FavoriteGroundRefreshing(previous: state));
    await _fetchFavorites(emit);
  }

  Future<void> _fetchFavorites(Emitter<FavoriteGroundState> emit) async {
    try {
      final favorites = await _repository.getFavoriteGrounds();
      if (favorites.isEmpty) {
        emit(const FavoriteGroundEmpty());
      } else {
        emit(FavoriteGroundLoaded(favorites));
      }
    } catch (e) {
      emit(FavoriteGroundError(e.toString()));
    }
  }
}
