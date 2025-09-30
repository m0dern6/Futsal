import 'package:bloc/bloc.dart';
import 'package:futsalpay/features/bookings/data/repository/bookings_repository.dart';
import 'package:futsalpay/features/bookings/data/model/booking_model.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final BookingsRepository bookingsRepository;

  BookingsBloc(this.bookingsRepository) : super(BookingsInitial()) {
    on<FetchBookings>(_onFetchBookings);
    on<RefreshBookings>(_onRefreshBookings);
  }

  Future<void> _onFetchBookings(
    FetchBookings event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingsLoading());
    try {
      final bookings = await bookingsRepository.fetchUserBookings(
        userId: event.userId,
      );
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingsError('Failed to fetch bookings: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshBookings(
    RefreshBookings event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      final bookings = await bookingsRepository.fetchUserBookings(
        userId: event.userId,
      );
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingsError('Failed to refresh bookings: ${e.toString()}'));
    }
  }
}
