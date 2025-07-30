import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/models/login_model.dart';
import 'package:futsalpay/features/auth/data/models/register_model.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<RegisterResponseModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('User/register', data: userData);

      // Check for a successful HTTP status code (e.g., 200, 201)
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Registration was successful, but the response body might not be JSON.
        // We return a success model with a default status.
        return RegisterResponseModel(
          status: response.statusCode,
          title: "Success",
        );
      } else {
        // Handle non-successful status codes that might still return a body
        return RegisterResponseModel.fromJson(jsonDecode(response.data));
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network issues, error responses)
      if (e.response != null && e.response!.data is String) {
        // If the error response is a string, try to parse it.
        // This is common for validation errors (e.g., "Email already taken").
        try {
          final errorData = jsonDecode(e.response!.data);
          return RegisterResponseModel.fromJson(errorData);
        } catch (_) {
          // If parsing fails, throw a generic error with the server's message.
          throw Exception(e.response!.data);
        }
      }
      // Re-throw the error if it's not a parsable response.
      rethrow;
    } catch (e) {
      // Catch any other unexpected errors
      rethrow;
    }
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await _apiService.post(
      ApiConst.login,
      data: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      // Save token to SharedPreferences
      await prefs.setString('token', response.data['accessToken']);
      print('Token saved: ${response.data['accessToken']}');
    }
    return LoginResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    final response = await _apiService.post(ApiConst.logout);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }
}
