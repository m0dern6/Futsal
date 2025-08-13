import 'package:futsalpay/features/home/data/model/trending_ground_model.dart';

abstract class TrendingGroundRepository {
  Future<List<TrendingGroundModel>> getTrendingGrounds({
    required int page,
    required int pageSize,
  });
}
