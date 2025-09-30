part of 'bookings_bloc.dart';

sealed class BookingsState {}

final class BookingsInitial extends BookingsState {}

final class BookingsLoading extends BookingsState {}

final class BookingsLoaded extends BookingsState {
  final List<BookingModel> bookings;
  final List<BookingModel> upcomingBookings;
  final List<BookingModel> pastBookings;

  BookingsLoaded(this.bookings)
    : upcomingBookings = bookings
          .where((booking) => booking.isUpcoming)
          .toList(),
      pastBookings = bookings.where((booking) => booking.isPast).toList();
}

final class BookingsError extends BookingsState {
  final String message;

  BookingsError(this.message);
}
