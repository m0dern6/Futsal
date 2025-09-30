import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/repository/upload_image_repository.dart';
import '../data/model/upload_image_model.dart';

part 'upload_image_event.dart';
part 'upload_image_state.dart';

class UploadImageBloc extends Bloc<UploadImageEvent, UploadImageState> {
  final UploadImageRepository repository;

  UploadImageBloc(this.repository) : super(UploadImageInitial()) {
    on<UploadImageRequested>(_onUploadRequested);
    on<UploadImageReset>((event, emit) => emit(UploadImageInitial()));
  }

  Future<void> _onUploadRequested(
    UploadImageRequested event,
    Emitter<UploadImageState> emit,
  ) async {
    emit(UploadImageLoading());
    try {
      final file = File(event.filePath);
      final UploadImageModel model = await repository.upload(file);
      // assuming model.id is the returned id
      emit(UploadImageSuccess(imageId: model.id, filePath: model.filePath));
    } catch (e) {
      emit(UploadImageFailure(e.toString()));
    }
  }
}
