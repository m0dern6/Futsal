part of 'top_review_ground_bloc.dart';

abstract class TopReviewGroundEvent extends Equatable {
  const TopReviewGroundEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopReviewGrounds extends TopReviewGroundEvent {
  final int? page;
  final int? pageSize;

  const LoadTopReviewGrounds({this.page, this.pageSize});

  @override
  List<Object?> get props => [page, pageSize];
}
