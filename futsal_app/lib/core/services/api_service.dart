import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
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
          final token = prefs.getString('token');
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
        onError: (DioException e, handler) {
          log(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          log('Message: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Existing POST method for login/register
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      // You can add more robust error handling here
      throw Exception('Failed to post data: ${e.message}');
    }
  }

  // ** ADD THIS NEW GET METHOD **
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get data: ${e.message}');
    }
  }
}
