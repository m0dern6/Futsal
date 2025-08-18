import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

abstract class FutsalGroundRepository {
  /// Fetch futsal grounds with optional filtering.
  ///
  /// Supported filters: minPrice, maxPrice, minRating, location.
  Future<List<FutsalGroundModel>> getFutsalGrounds({
    required int page,
    required int pageSize,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    String? location,
  });
}
