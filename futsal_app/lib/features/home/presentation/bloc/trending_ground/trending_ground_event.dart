part of 'trending_ground_bloc.dart';

abstract class TrendingGroundEvent extends Equatable {
  const TrendingGroundEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingGrounds extends TrendingGroundEvent {
  final int? page;
  final int? pageSize;

  const LoadTrendingGrounds({this.page, this.pageSize});

  @override
  List<Object?> get props => [page, pageSize];
}
