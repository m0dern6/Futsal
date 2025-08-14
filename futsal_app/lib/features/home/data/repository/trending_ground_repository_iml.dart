import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/home/data/model/trending_ground_model.dart';
import 'package:futsalpay/features/home/domain/trending_ground_repository.dart';
import 'dart:developer';

class TrendingGroundRepositoryImpl implements TrendingGroundRepository {
  final ApiService apiService;
  TrendingGroundRepositoryImpl(this.apiService);

  @override
  Future<List<TrendingGroundModel>> getTrendingGrounds({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiConst.trendingGround,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return (response as List)
          .map((e) => TrendingGroundModel.fromJson(e))
          .toList();
    } catch (e) {
      log('Error fetching trending grounds: $e');
      throw Exception('Failed to load trending grounds: $e');
    }
  }
}
