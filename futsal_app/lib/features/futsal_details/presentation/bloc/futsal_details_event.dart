part of 'futsal_details_bloc.dart';

@immutable
sealed class FutsalDetailsEvent {}

final class LoadFutsalDetails extends FutsalDetailsEvent {
  final String id;
  LoadFutsalDetails(this.id);
}
