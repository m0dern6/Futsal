part of 'bookings_bloc.dart';

sealed class BookingsEvent {}

class FetchBookings extends BookingsEvent {
  final String? userId;

  FetchBookings({this.userId});
}

class RefreshBookings extends BookingsEvent {
  final String? userId;

  RefreshBookings({this.userId});
}
