import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:futsalpay/features/book_now/data/repository/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc(this.bookingRepository) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await bookingRepository.createBooking(
        userId: event.userId,
        groundId: event.groundId,
        bookingDate: event.bookingDate,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      emit(BookingSuccess('Booking created successfully!'));
    } catch (e) {
      emit(BookingError('Failed to create booking: ${e.toString()}'));
    }
  }
}
