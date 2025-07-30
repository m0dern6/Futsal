import 'package:futsalpay/features/auth/data/models/login_model.dart';
import 'package:futsalpay/features/auth/data/models/register_model.dart';

abstract class AuthRepository {
  Future<RegisterResponseModel> register(Map<String, dynamic> userData);
  Future<LoginResponseModel> login(String email, String password);
  Future<void> logout();
}
