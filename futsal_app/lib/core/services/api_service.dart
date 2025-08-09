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

  // POST method
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed: ${response.statusCode} ${response.statusMessage}',
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to post data: ${e.message}');
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
