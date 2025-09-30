part of 'upload_image_bloc.dart';

@immutable
sealed class UploadImageEvent {}

final class UploadImageRequested extends UploadImageEvent {
  final String filePath;

  UploadImageRequested(this.filePath);
}

final class UploadImageReset extends UploadImageEvent {}
