class UploadImageModel {
  final int id;
  final DateTime uploadedAt;
  final String filePath;
  final String fileName;
  final String fileType;
  final int size;
  final String userId;
  final bool isDeleted;

  UploadImageModel({
    required this.id,
    required this.uploadedAt,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.size,
    required this.userId,
    required this.isDeleted,
  });

  factory UploadImageModel.fromJson(Map<String, dynamic> json) {
    return UploadImageModel(
      id: json['id'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      size: json['size'] as int,
      userId: json['userId'] as String,
      isDeleted: json['isDeleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploadedAt': uploadedAt.toIso8601String(),
      'filePath': filePath,
      'fileName': fileName,
      'fileType': fileType,
      'size': size,
      'userId': userId,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() {
    return 'UploadImageModel(id: $id, uploadedAt: $uploadedAt, filePath: $filePath, fileName: $fileName, fileType: $fileType, size: $size, userId: $userId, isDeleted: $isDeleted)';
  }
}
