import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/models/email_confirmation_model.dart';
import 'package:futsalpay/features/auth/data/models/forgot_password_model.dart';
import 'package:futsalpay/features/auth/data/models/login_model.dart';
import 'package:futsalpay/features/auth/data/models/register_model.dart';
import 'package:futsalpay/features/auth/data/models/reset_password_model.dart';
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

      if (loginData['refreshToken'] != null) {
        await prefs.setString('refreshToken', loginData['refreshToken']);
        print('Refresh token saved');
      }

      final expiresInRaw = loginData['expiresIn'];
      int? expiresInSeconds;
      if (expiresInRaw is int) {
        expiresInSeconds = expiresInRaw;
      } else if (expiresInRaw is String) {
        expiresInSeconds = int.tryParse(expiresInRaw);
      }

      if (expiresInSeconds != null) {
        final expiresAt = DateTime.now()
            .add(Duration(seconds: expiresInSeconds))
            .millisecondsSinceEpoch;
        await prefs.setInt('tokenExpiry', expiresAt);
      } else {
        await prefs.remove('tokenExpiry');
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
      await prefs.remove('refreshToken');
      await prefs.remove('tokenExpiry');
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

  @override
  Future<LoginResponseModel> refreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await _apiService.post(
        ApiConst.refresh,
        data: {'refreshToken': refreshToken},
      );

      Map<String, dynamic> loginData;
      if (response is Map<String, dynamic>) {
        loginData = response;
      } else if (response.data != null) {
        loginData = response.data;
      } else {
        loginData = response as Map<String, dynamic>;
      }

      if (loginData['accessToken'] != null) {
        await prefs.setString('token', loginData['accessToken']);
      }

      if (loginData['refreshToken'] != null) {
        await prefs.setString('refreshToken', loginData['refreshToken']);
      }

      final expiresInRaw = loginData['expiresIn'];
      int? expiresInSeconds;
      if (expiresInRaw is int) {
        expiresInSeconds = expiresInRaw;
      } else if (expiresInRaw is String) {
        expiresInSeconds = int.tryParse(expiresInRaw);
      }

      if (expiresInSeconds != null) {
        final expiresAt = DateTime.now()
            .add(Duration(seconds: expiresInSeconds))
            .millisecondsSinceEpoch;
        await prefs.setInt('tokenExpiry', expiresAt);
      }

      return LoginResponseModel.fromJson(loginData);
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }

  @override
  Future<EmailConfirmationResponse> resendConfirmationEmail(
    String email,
  ) async {
    try {
      await _apiService.post(
        ApiConst.resendConfirmationEmail,
        data: {'email': email},
      );
      return EmailConfirmationResponse(
        message: 'Confirmation email sent successfully',
      );
    } catch (e) {
      throw Exception('Failed to resend confirmation email: $e');
    }
  }

  @override
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      await _apiService.post(ApiConst.forgotPassword, data: {'email': email});
      return ForgotPasswordResponse(
        message: 'Password reset code sent to your email',
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> verifyResetCode(String email, String resetCode) async {
    try {
      await _apiService.post(
        ApiConst.verifyResetCode,
        data: {'email': email, 'resetCode': resetCode},
      );
    } catch (e) {
      throw Exception('Invalid or expired reset code: $e');
    }
  }

  @override
  Future<ResetPasswordResponse> resetPassword(
    String email,
    String resetCode,
    String newPassword,
  ) async {
    try {
      await _apiService.post(
        ApiConst.resetPassword,
        data: {
          'email': email,
          'resetCode': resetCode,
          'newPassword': newPassword,
        },
      );
      return ResetPasswordResponse(message: 'Password reset successfully');
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<void> deactivateAccount() async {
    try {
      await _apiService.post(ApiConst.deactivateAccount);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refreshToken');
      await prefs.remove('tokenExpiry');
    } catch (e) {
      throw Exception('Failed to deactivate account: $e');
    }
  }

  @override
  Future<void> sendRevalidateEmail() async {
    try {
      await _apiService.post(ApiConst.sendRevalidateEmail);
    } catch (e) {
      throw Exception('Failed to send revalidation email: $e');
    }
  }
}
