import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _tokenExpiryKey = 'tokenExpiry';
  static const Duration _preemptiveRefreshWindow = Duration(minutes: 1);

  final Dio _dio;
  final Dio _refreshDio;
  Future<String?>? _refreshTokenFuture;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConst.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ),
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConst.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          log('REQUEST[${options.method}] => PATH: ${options.path}');
          log('Headers: ${options.headers}');
          log('Data: ${options.data}');
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString(_tokenKey);
          final String? refreshToken = prefs.getString(_refreshTokenKey);
          final int? expiryMillis = prefs.getInt(_tokenExpiryKey);

          final bool shouldRefresh =
              !_isRefreshRequest(options.path) &&
              refreshToken != null &&
              (token == null || _isTokenExpired(expiryMillis));

          if (shouldRefresh) {
            token = await _refreshAccessToken(existingPrefs: prefs);
          }

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          log('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          log(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          log('Message: ${e.message}');
          if (_shouldAttemptRefresh(e)) {
            try {
              final newToken = await _refreshAccessToken();
              if (newToken != null) {
                final updatedHeaders = Map<String, dynamic>.from(
                  e.requestOptions.headers,
                )..['Authorization'] = 'Bearer $newToken';

                final retriedOptions = e.requestOptions.copyWith(
                  headers: updatedHeaders,
                  extra: {...e.requestOptions.extra, 'retrying': true},
                );

                final response = await _dio.fetch(retriedOptions);
                return handler.resolve(response);
              }
            } catch (error) {
              log('Token refresh failed: $error');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  bool _shouldAttemptRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final isRetrying = error.requestOptions.extra['retrying'] == true;
    return statusCode == 401 &&
        !isRetrying &&
        !_isRefreshRequest(error.requestOptions.path);
  }

  bool _isRefreshRequest(String path) {
    return path.contains(ApiConst.refresh);
  }

  bool _isTokenExpired(int? expiryMillis) {
    if (expiryMillis == null) {
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final refreshThreshold =
        expiryMillis - _preemptiveRefreshWindow.inMilliseconds;
    return now >= refreshThreshold;
  }

  Future<String?> _refreshAccessToken({
    SharedPreferences? existingPrefs,
  }) async {
    if (_refreshTokenFuture != null) {
      return _refreshTokenFuture!;
    }

    final completer = Completer<String?>();
    _refreshTokenFuture = completer.future;

    SharedPreferences? prefs;
    try {
      prefs = existingPrefs ?? await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        completer.complete(null);
        return null;
      }

      final response = await _refreshDio.post(
        ApiConst.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = _mapFromResponse(response.data);
      if (data == null) {
        await _clearStoredTokens(prefs);
        completer.complete(null);
        return null;
      }

      final String? newAccessToken = data['accessToken'] as String?;
      final String newRefreshToken =
          (data['refreshToken'] as String?) ?? refreshToken;
      final dynamic expiresInRaw = data['expiresIn'];

      if (newAccessToken == null) {
        await _clearStoredTokens(prefs);
        completer.complete(null);
        return null;
      }

      await prefs.setString(_tokenKey, newAccessToken);
      await prefs.setString(_refreshTokenKey, newRefreshToken);

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
        await prefs.setInt(_tokenExpiryKey, expiresAt);
      } else {
        await prefs.remove(_tokenExpiryKey);
      }

      completer.complete(newAccessToken);
      return newAccessToken;
    } catch (error) {
      if (prefs != null) {
        await _clearStoredTokens(prefs);
      }
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      rethrow;
    } finally {
      _refreshTokenFuture = null;
    }
  }

  Map<String, dynamic>? _mapFromResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    if (responseData is String && responseData.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // Ignore json parsing errors and fall through to return null.
      }
    }
    return null;
  }

  Future<void> _clearStoredTokens(SharedPreferences prefs) async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  // POST method
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        log('DioException Response Status: ${e.response?.statusCode}');
        log('DioException Response Data: ${e.response?.data}');
        log('DioException Response Headers: ${e.response?.headers}');

        String errorMessage = 'Server Error ${e.response?.statusCode}';

        // Handle specific error cases
        if (e.response?.statusCode == 500) {
          final responseData = e.response?.data;
          if (responseData is String) {
            if (responseData.toLowerCase().contains('time slot') ||
                responseData.toLowerCase().contains('already booked') ||
                responseData.toLowerCase().contains('slot already')) {
              errorMessage =
                  'This time slot is already booked. Please select a different time.';
            } else {
              errorMessage = 'Server error: $responseData';
            }
          } else {
            errorMessage = 'Server error: ${responseData ?? e.message}';
          }
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid booking data. Please check your selection.';
        }

        throw Exception(errorMessage);
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    }
  }

  // GET method
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get data: ${e.message}');
    }
  }

  // PUT method
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to put data: ${e.message}');
    }
  }

  // PATCH method
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to patch data: ${e.message}');
    }
  }

  // DELETE method
  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to delete data: ${e.message}');
    }
  }
}
