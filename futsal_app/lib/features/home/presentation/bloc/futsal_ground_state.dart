part of 'futsal_ground_bloc.dart';

abstract class FutsalGroundState extends Equatable {
  const FutsalGroundState();

  @override
  List<Object> get props => [];
}

class FutsalGroundInitial extends FutsalGroundState {}

class FutsalGroundLoading extends FutsalGroundState {}

class FutsalGroundLoaded extends FutsalGroundState {
  final List<FutsalGroundModel> grounds;
  const FutsalGroundLoaded(this.grounds);

  @override
  List<Object> get props => [grounds];
}

class FutsalGroundError extends FutsalGroundState {
  final String message;
  const FutsalGroundError(this.message);

  @override
  List<Object> get props => [message];
}
