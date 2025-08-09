import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';
import '../model/booking_model.dart';

class BookingRepository {
  final ApiService _apiService;

  BookingRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<BookingModel> createBooking({
    required String userId,
    required int groundId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    final body = {
      'userId': userId,
      'groundId': groundId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
    };
    final response = await _apiService.post(ApiConst.bookFutsal, data: body);
    return BookingModel.fromJson(response);
  }
}
