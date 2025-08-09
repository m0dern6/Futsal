import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/shared/user_info/data/model/user_info_model.dart';

class UserInfoRepository {
  final ApiService _apiService;

  UserInfoRepository(this._apiService);

  Future<UserInfoModel> fetchUserInfo() async {
    try {
      final response = await _apiService.get(ApiConst.userInfo);
      return UserInfoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user info: $e');
    }
  }
}
