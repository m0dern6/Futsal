import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'dart:convert';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// Update user profile. Provide a map of fields to update.
  /// The API expects POST to /User/manage/info (see API docs)
  Future<void> updateProfile(Map<String, dynamic> body) async {
    try {
      await _apiService.post(ApiConst.userInfo, data: body);
    } on Exception catch (e) {
      // Try to extract server error message
      final msg = e.toString();
      final match = RegExp(r'\{.*?\}').stringMatch(msg);
      if (match != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(match);
          if (json['errors'] is Map) {
            final errors = json['errors'] as Map;
            final allMsgs = errors.values
                .expand((v) => v is List ? v : [v])
                .map((e) => e.toString())
                .join('\n');
            throw Exception(allMsgs);
          }
        } catch (_) {}
      }
      rethrow;
    }
  }
}
