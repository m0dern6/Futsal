part of 'top_review_ground_bloc.dart';

abstract class TopReviewGroundState extends Equatable {
  const TopReviewGroundState();

  @override
  List<Object> get props => [];
}

class TopReviewGroundInitial extends TopReviewGroundState {}

class TopReviewGroundLoading extends TopReviewGroundState {}

class TopReviewGroundLoaded extends TopReviewGroundState {
  final List<TopReviewGroundModel> grounds;
  const TopReviewGroundLoaded(this.grounds);

  @override
  List<Object> get props => [grounds];
}

class TopReviewGroundError extends TopReviewGroundState {
  final String message;
  const TopReviewGroundError(this.message);

  @override
  List<Object> get props => [message];
}
