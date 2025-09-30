import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// Update user profile. Provide a map of fields to update.
  /// The API expects POST to /User/manage/info (see API docs)
  Future<void> updateProfile(Map<String, dynamic> body) async {
    try {
      await _apiService.post(ApiConst.userInfo, data: body);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
