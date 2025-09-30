part of 'upload_image_bloc.dart';

@immutable
sealed class UploadImageState {}

final class UploadImageInitial extends UploadImageState {}

final class UploadImageLoading extends UploadImageState {}

final class UploadImageSuccess extends UploadImageState {
  final int imageId;
  final String filePath;

  UploadImageSuccess({required this.imageId, required this.filePath});
}

final class UploadImageFailure extends UploadImageState {
  final String error;

  UploadImageFailure(this.error);
}
