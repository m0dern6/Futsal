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

      // Debug: Print the response type and structure
      print('Register Response type: ${response.runtimeType}');
      print('Register Response: $response');

      // Since the response is successful (no exception thrown),
      // we assume registration was successful
      return RegisterResponseModel(
        status: 200, // Default success status
        title: "Success",
      );
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network issues, error responses)
      print('DioException details: ${e.response?.data}');
      print('DioException type: ${e.response?.data.runtimeType}');

      if (e.response != null && e.response!.data != null) {
        try {
          // If the error response data is a string, try to parse it
          if (e.response!.data is String) {
            final errorData = jsonDecode(e.response!.data);
            return RegisterResponseModel.fromJson(errorData);
          } else if (e.response!.data is Map<String, dynamic>) {
            // If it's already a Map, use it directly
            return RegisterResponseModel.fromJson(e.response!.data);
          } else {
            // If we can't parse the error, throw a generic error
            throw Exception(
              'Registration failed: ${e.response!.statusMessage}',
            );
          }
        } catch (parseError) {
          // If parsing fails, throw a generic error with the server's message
          print('Parse error: $parseError');
          throw Exception('Registration failed: ${e.response!.data}');
        }
      }
      // Re-throw the error if it's not a parsable response
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      print('Register error details: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await _apiService.post(
        ApiConst.login,
        data: {'email': email, 'password': password},
      );

      // Debug: Print the response type and structure
      print('Response type: ${response.runtimeType}');
      print('Response: $response');

      // Handle different response types
      Map<String, dynamic> loginData;

      if (response is Map<String, dynamic>) {
        // If response is already a Map (parsed JSON)
        loginData = response;
      } else if (response.data != null) {
        // If response has a data property (Dio Response object)
        loginData = response.data;
      } else {
        // Fallback - try to use response directly
        loginData = response as Map<String, dynamic>;
      }

      // Save token to SharedPreferences
      if (loginData['accessToken'] != null) {
        await prefs.setString('token', loginData['accessToken']);
        print('Token saved: ${loginData['accessToken']}');
      }

      return LoginResponseModel.fromJson(loginData);
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        throw Exception(
          'Login failed: ${e.response!.statusMessage ?? e.message}',
        );
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      print('Login error details: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConst.logout);
      // If no exception was thrown, logout was successful
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        throw Exception(
          'Logout failed: ${e.response!.statusMessage ?? e.message}',
        );
      }
      throw Exception('Logout failed: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Logout failed: $e');
    }
  }
}
