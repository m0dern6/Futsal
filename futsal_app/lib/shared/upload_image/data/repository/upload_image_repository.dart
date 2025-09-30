import 'dart:io';

import 'package:dio/dio.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/const/api_const.dart';
import '../model/upload_image_model.dart';

class UploadImageRepository {
  final ApiService _apiService;

  UploadImageRepository(this._apiService);

  /// Uploads a single image file. Returns [UploadImageModel] on success.
  Future<UploadImageModel> upload(File file) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _apiService.post(
        ApiConst.uploadImage,
        data: formData,
      );

      // Expecting JSON body that maps to UploadImageModel
      return UploadImageModel.fromJson(response);
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
