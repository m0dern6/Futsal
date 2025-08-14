import 'package:futsalpay/features/home/data/model/top_review_ground_model.dart';

abstract class TopReviewGroundRepository {
  Future<List<TopReviewGroundModel>> getTopReviewGrounds({
    required int page,
    required int pageSize,
  });
}
