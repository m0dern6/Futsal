import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/core/service/api_service.dart';
import 'package:ui/core/service/api_const.dart';
import 'package:ui/view/auth/data/model/auth_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // SharedPreferences keys
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'expiry_time';

  // Login with email and password
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConst.login,
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens and expiry time
      await _saveAuthData(authResponse);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Refresh token
  Future<AuthResponseModel> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        throw ApiException('No refresh token found');
      }

      final response = await _apiService.post(
        ApiConst.refresh,
        data: {'refreshToken': refreshToken},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Update tokens and expiry time
      await _saveAuthData(authResponse);

      return authResponse;
    } catch (e) {
      // If refresh fails, clear all auth data
      await _clearAuthData();
      rethrow;
    }
  }

  // Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConst.register,
        data: {'email': email, 'password': password, 'name': name},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens and expiry time
      await _saveAuthData(authResponse);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout API (optional, depends on backend)
      try {
        await _apiService.post(ApiConst.logout);
      } catch (e) {
        // Ignore API errors during logout
      }

      // Clear all stored auth data
      await _clearAuthData();
    } catch (e) {
      // Ensure data is cleared even if there's an error
      await _clearAuthData();
      rethrow;
    }
  }

  // Check if token is expired or about to expire (within 1 minute)
  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTimeString = prefs.getString(_expiryTimeKey);

      if (expiryTimeString == null) return true;

      final expiryTime = DateTime.parse(expiryTimeString);
      final now = DateTime.now();

      // Consider expired if within 1 minute of expiry (buffer time)
      return now.isAfter(expiryTime.subtract(const Duration(minutes: 1)));
    } catch (e) {
      return true;
    }
  }

  // Auto-refresh token if expired
  Future<void> ensureValidToken() async {
    final isExpired = await isTokenExpired();
    if (isExpired) {
      await refreshToken();
    }
  }

  // Get stored refresh token
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Save all auth data to SharedPreferences
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    // Save access token via ApiService
    await _apiService.saveToken(authResponse.accessToken);

    // Save refresh token and expiry time
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(
      _expiryTimeKey,
      authResponse.expiryTime.toIso8601String(),
    );
  }

  // Clear all auth data from SharedPreferences
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear access token via ApiService
    await _apiService.clearToken();

    // Clear refresh token and expiry time
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_expiryTimeKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final hasToken = _apiService.isAuthenticated;
    if (!hasToken) return false;

    // Check if token is expired
    final isExpired = await isTokenExpired();
    return !isExpired;
  }
}
