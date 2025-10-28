abstract class ReviewRepository {
  Future<List<dynamic>> getUserReviews({int page = 1});
  Future<dynamic> createReview(Map<String, dynamic> reviewData);
  Future<List<dynamic>> getReviewsByGroundId(String groundId);
  Future<dynamic> getReviewById(String reviewId);
  Future<dynamic> updateReview(
    String reviewId,
    Map<String, dynamic> reviewData,
  );
  Future<void> deleteReview(String reviewId);
}
