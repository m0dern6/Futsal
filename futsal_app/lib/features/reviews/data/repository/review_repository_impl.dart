import '../../domain/review_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/const/api_const.dart';
import '../model/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final String baseUrl = ApiConst.baseUrl;

  @override
  Future<List<ReviewModel>> getUserReviews({int page = 1}) async {
    final response = await http.get(
      Uri.parse(baseUrl + ApiConst.reviews + '?page=$page'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user reviews');
    }
  }

  @override
  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final response = await http.post(
      Uri.parse(baseUrl + ApiConst.reviews),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reviewData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ReviewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create review');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByGroundId(String groundId) async {
    final response = await http.get(
      Uri.parse(baseUrl + ApiConst.getReviewsById(groundId)),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ground reviews');
    }
  }

  @override
  Future<ReviewModel> getReviewById(String reviewId) async {
    final response = await http.get(
      Uri.parse(baseUrl + ApiConst.individualReviews(reviewId)),
    );
    if (response.statusCode == 200) {
      return ReviewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load review');
    }
  }

  @override
  Future<ReviewModel> updateReview(
    String reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    final response = await http.put(
      Uri.parse(baseUrl + ApiConst.individualReviews(reviewId)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reviewData),
    );
    if (response.statusCode == 200) {
      return ReviewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update review');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final response = await http.delete(
      Uri.parse(baseUrl + ApiConst.individualReviews(reviewId)),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete review');
    }
  }
}
