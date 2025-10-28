part of 'favorite_ground_bloc.dart';

abstract class FavoriteGroundEvent extends Equatable {
  const FavoriteGroundEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoriteGrounds extends FavoriteGroundEvent {
  const LoadFavoriteGrounds();
}

class RefreshFavoriteGrounds extends FavoriteGroundEvent {
  const RefreshFavoriteGrounds();
}
