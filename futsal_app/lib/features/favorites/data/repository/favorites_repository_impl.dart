import 'dart:developer';

import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/favorites/domain/favorites_repository.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<List<FutsalGroundModel>> getFavoriteGrounds() async {
    try {
      final response = await _apiService.get(ApiConst.favorites);

      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map(FutsalGroundModel.fromJson)
            .toList();
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(FutsalGroundModel.fromJson)
            .toList();
      }

      throw const FormatException('Unexpected favorites response format');
    } catch (e, stackTrace) {
      log('Failed to fetch favorite grounds: $e', stackTrace: stackTrace);
      throw Exception('Unable to load favorite grounds');
    }
  }

  @override
  Future<void> addFavorite(String groundId) async {
    try {
      await _apiService.post(ApiConst.addFavorite(groundId));
    } catch (e, stackTrace) {
      log(
        'Failed to add favorite ground $groundId: $e',
        stackTrace: stackTrace,
      );
      throw Exception('Unable to add favorite ground');
    }
  }
}
