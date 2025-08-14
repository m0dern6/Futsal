import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/home/data/model/top_review_ground_model.dart';
import 'package:futsalpay/features/home/domain/top_review_ground_repository.dart';
import 'dart:developer';

class TopReviewGroundRepositoryImpl implements TopReviewGroundRepository {
  final ApiService apiService;
  TopReviewGroundRepositoryImpl(this.apiService);

  @override
  Future<List<TopReviewGroundModel>> getTopReviewGrounds({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiConst.topReviewGround,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return (response as List)
          .map((e) => TopReviewGroundModel.fromJson(e))
          .toList();
    } catch (e) {
      log('Error fetching top review grounds: $e');
      throw Exception('Failed to load top review grounds: $e');
    }
  }
}
