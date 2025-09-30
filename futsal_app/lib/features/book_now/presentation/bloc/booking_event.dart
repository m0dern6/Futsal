part of 'booking_bloc.dart';

@immutable
sealed class BookingEvent {}

class CreateBooking extends BookingEvent {
  final String userId;
  final int groundId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;

  CreateBooking({
    required this.userId,
    required this.groundId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });
}
