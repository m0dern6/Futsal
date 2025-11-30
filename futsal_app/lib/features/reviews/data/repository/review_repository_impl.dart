import '../../domain/review_repository.dart';

import 'dart:convert';
import 'dart:developer';
import '../../../../core/services/api_service.dart';
import '../../../../core/const/api_const.dart';
import '../model/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ApiService _apiService;

  ReviewRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  @override
  Future<List<ReviewModel>> getUserReviews({int page = 1}) async {
    try {
      log('Fetching user reviews - page: $page');
      final response = await _apiService.get(
        ApiConst.reviews,
        queryParameters: {'page': page},
      );

      log('User reviews response: $response');

      if (response is List) {
        return response.map((e) => ReviewModel.fromJson(e)).toList();
      } else if (response is Map<String, dynamic> &&
          response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => ReviewModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      log('Error fetching user reviews: $e');
      throw Exception('Failed to load user reviews: $e');
    }
  }

  @override
  @override
  Future<dynamic> createReview(Map<String, dynamic> reviewData) async {
    try {
      log('=== CREATE REVIEW DEBUG ===');
      log('Request Data: $reviewData');

      final response = await _apiService.post(
        ApiConst.reviews,
        data: reviewData,
      );

      log('Response: $response');
      log('Response Type: ${response.runtimeType}');

      if (response is Map<String, dynamic>) {
        return ReviewModel.fromJson(response);
      } else if (response is String) {
        // If response is a string, try to parse it
        try {
          final parsed = json.decode(response);
          if (parsed is Map<String, dynamic>) {
            return ReviewModel.fromJson(parsed);
          } else if (parsed is int) {
            // API returned review ID as int, wrap in a map for consistency
            log('Review created with ID: $parsed');
            return {'id': parsed};
          }
        } catch (e) {
          log('Failed to parse string response: $e');
          // If response is already int (not a stringified JSON)
          if (response is int) {
            log('Review created with ID: $response');
            return {'id': response};
          }
        }
      }

      throw Exception('Unexpected response format: ${response.runtimeType}');
    } catch (e, stackTrace) {
      log('=== ERROR CREATING REVIEW ===');
      log('Error: $e');
      log('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByGroundId(String groundId) async {
    try {
      log('Fetching reviews for ground: $groundId');
      final response = await _apiService.get(ApiConst.getReviewsById(groundId));

      log('Ground reviews response: $response');

      if (response is List) {
        return response.map((e) => ReviewModel.fromJson(e)).toList();
      } else if (response is Map<String, dynamic> &&
          response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => ReviewModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      log('Error fetching ground reviews: $e');
      throw Exception('Failed to load ground reviews: $e');
    }
  }

  @override
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      log('Fetching review: $reviewId');
      final response = await _apiService.get(
        ApiConst.individualReviews(reviewId),
      );

      log('Review response: $response');

      if (response is Map<String, dynamic>) {
        return ReviewModel.fromJson(response);
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      log('Error fetching review: $e');
      throw Exception('Failed to load review: $e');
    }
  }

  @override
  Future<ReviewModel> updateReview(
    String reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      log('Updating review: $reviewId with data: $reviewData');
      final response = await _apiService.put(
        ApiConst.individualReviews(reviewId),
        data: reviewData,
      );

      log('Update review response: $response');

      if (response is Map<String, dynamic>) {
        return ReviewModel.fromJson(response);
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      log('Error updating review: $e');
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      log('Deleting review: $reviewId');
      await _apiService.delete(ApiConst.individualReviews(reviewId));
      log('Review deleted successfully');
    } catch (e) {
      log('Error deleting review: $e');
      throw Exception('Failed to delete review: $e');
    }
  }
}
