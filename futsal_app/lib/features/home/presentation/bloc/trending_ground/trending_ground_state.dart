part of 'trending_ground_bloc.dart';

abstract class TrendingGroundState extends Equatable {
  const TrendingGroundState();

  @override
  List<Object> get props => [];
}

class TrendingGroundInitial extends TrendingGroundState {}

class TrendingGroundLoading extends TrendingGroundState {}

class TrendingGroundLoaded extends TrendingGroundState {
  final List<TrendingGroundModel> grounds;
  const TrendingGroundLoaded(this.grounds);

  @override
  List<Object> get props => [grounds];
}

class TrendingGroundError extends TrendingGroundState {
  final String message;
  const TrendingGroundError(this.message);

  @override
  List<Object> get props => [message];
}
