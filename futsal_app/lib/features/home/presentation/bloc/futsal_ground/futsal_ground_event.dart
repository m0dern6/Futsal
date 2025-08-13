part of 'futsal_ground_bloc.dart';

abstract class FutsalGroundEvent extends Equatable {
  const FutsalGroundEvent();

  @override
  List<Object> get props => [];
}

class LoadFutsalGrounds extends FutsalGroundEvent {}
