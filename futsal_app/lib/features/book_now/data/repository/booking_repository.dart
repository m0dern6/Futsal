import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/features/bookings/data/model/booking_model.dart';
import 'dart:developer';

class BookingRepository {
  final ApiService _apiService;

  BookingRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<BookingModel>> fetchUserBookings({String? userId}) async {
    try {
      Map<String, dynamic>? queryParams;
      if (userId != null) {
        queryParams = {'userId': userId};
      }

      log('Fetching bookings with params: $queryParams');
      final response = await _apiService.get(
        ApiConst.bookFutsal,
        queryParameters: queryParams,
      );
      log('Bookings response: $response');
      log('Response type: ${response.runtimeType}');

      if (response is List) {
        return response
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> &&
          response.containsKey('data')) {
        // Handle case where response is wrapped in a data object
        final data = response['data'];
        if (data is List) {
          return data
              .map(
                (json) => BookingModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      // If no valid data format, return empty list
      log('No valid booking data found in response');
      return [];
    } catch (e) {
      log('Error fetching bookings: $e');
      rethrow;
    }
  }

  Future<void> createBooking({
    required String userId,
    required int groundId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // Format the datetime to match the API expectation
      final body = {
        'userId': userId,
        'groundId': groundId,
        'bookingDate': bookingDate.toIso8601String(),
        'startTime': startTime, // Should be in format "10:00:00"
        'endTime': endTime, // Should be in format "12:00:00"
      };

      log('Booking request body: $body');
      log('UserId type: ${userId.runtimeType}, value: $userId');
      log('GroundId type: ${groundId.runtimeType}, value: $groundId');
      log(
        'BookingDate type: ${bookingDate.runtimeType}, value: ${bookingDate.toIso8601String()}',
      );
      log('StartTime type: ${startTime.runtimeType}, value: $startTime');
      log('EndTime type: ${endTime.runtimeType}, value: $endTime');

      final response = await _apiService.post(ApiConst.bookFutsal, data: body);
      log('Booking response: $response');
      log('Response type: ${response.runtimeType}');

      // Handle different response types
      if (response is Map<String, dynamic>) {
        log('Response is JSON object - booking details returned');
        // API returned booking object - we can parse it but don't need to return it
      } else if (response is String) {
        log('Response is String: $response');
        // API returned a simple string message (likely success message)
      } else {
        log('Response is unknown type: ${response.runtimeType}');
      }

      // Don't try to parse as BookingModel since response format varies
      // Just return successfully if no exception was thrown
    } catch (e) {
      log('Booking error: $e');
      log('Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}
