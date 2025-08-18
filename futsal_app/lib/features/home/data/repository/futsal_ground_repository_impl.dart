import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';
import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';

// ... imports
import 'dart:developer'; // Import the developer log

class FutsalGroundRepositoryImpl implements FutsalGroundRepository {
  final ApiService apiService;
  FutsalGroundRepositoryImpl(this.apiService);
  // ...
  @override
  Future<List<FutsalGroundModel>> getFutsalGrounds({
    required int page,
    required int pageSize,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    String? location,
  }) async {
    try {
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (minRating != null) 'minRating': minRating,
        if (location != null && location.isNotEmpty) 'location': location,
      };

      final response = await apiService.get(
        ApiConst.futsalGround,
        queryParameters: queryParameters,
      );
      return (response as List)
          .map((e) => FutsalGroundModel.fromJson(e))
          .toList();
    } catch (e) {
      // Add this log to see the specific error
      log('Error fetching futsal grounds: $e');
      throw Exception('Failed to load futsal grounds: $e');
    }
  }
}
