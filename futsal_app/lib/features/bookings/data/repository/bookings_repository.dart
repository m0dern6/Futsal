import 'package:futsalpay/features/book_now/data/repository/booking_repository.dart';
import '../model/booking_model.dart';

class BookingsRepository {
  final BookingRepository _bookingRepository;

  BookingsRepository({BookingRepository? bookingRepository})
    : _bookingRepository = bookingRepository ?? BookingRepository();

  Future<List<BookingModel>> fetchUserBookings({String? userId}) async {
    return await _bookingRepository.fetchUserBookings(userId: userId);
  }
}
