part of 'favorite_ground_bloc.dart';

abstract class FavoriteGroundState extends Equatable {
  const FavoriteGroundState();

  @override
  List<Object?> get props => [];
}

class FavoriteGroundInitial extends FavoriteGroundState {
  const FavoriteGroundInitial();
}

class FavoriteGroundLoading extends FavoriteGroundState {
  const FavoriteGroundLoading();
}

class FavoriteGroundRefreshing extends FavoriteGroundState {
  const FavoriteGroundRefreshing({required this.previous});

  final FavoriteGroundState previous;

  @override
  List<Object?> get props => [previous];
}

class FavoriteGroundLoaded extends FavoriteGroundState {
  const FavoriteGroundLoaded(this.grounds);

  final List<FutsalGroundModel> grounds;

  @override
  List<Object?> get props => [grounds];
}

class FavoriteGroundEmpty extends FavoriteGroundState {
  const FavoriteGroundEmpty();
}

class FavoriteGroundError extends FavoriteGroundState {
  const FavoriteGroundError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
