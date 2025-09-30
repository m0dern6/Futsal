part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingSuccess extends BookingState {
  final String message;

  BookingSuccess(this.message);
}

final class BookingError extends BookingState {
  final String error;

  BookingError(this.error);
}
