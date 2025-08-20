import 'dart:developer';

import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/futsal_details/data/model/futsal_details_model.dart';
import 'package:futsalpay/features/futsal_details/domain/futsal_details_repository.dart';

class FutsalDetailsRepositoryImpl implements FutsalDetailsRepository {
  final ApiService apiService;
  FutsalDetailsRepositoryImpl(this.apiService);

  @override
  Future<FutsalDetailsModel> getFutsalDetails(String id) async {
    try {
      final response = await apiService.get(ApiConst.futsalDetails(id));
      // API returns a JSON object
      return FutsalDetailsModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      log('Error fetching futsal details: $e');
      throw Exception('Failed to load futsal details: $e');
    }
  }
}
