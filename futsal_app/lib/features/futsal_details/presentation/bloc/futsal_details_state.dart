part of 'futsal_details_bloc.dart';

@immutable
sealed class FutsalDetailsState {}

final class FutsalDetailsInitial extends FutsalDetailsState {}

final class FutsalDetailsLoading extends FutsalDetailsState {}

final class FutsalDetailsLoaded extends FutsalDetailsState {
  final data;
  FutsalDetailsLoaded(this.data);
}

final class FutsalDetailsError extends FutsalDetailsState {
  final String message;
  FutsalDetailsError(this.message);
}
