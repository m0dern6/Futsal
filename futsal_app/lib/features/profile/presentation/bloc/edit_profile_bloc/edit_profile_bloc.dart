import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../profile/data/repository/profile_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final ProfileRepository repository;

  EditProfileBloc(this.repository) : super(EditProfileInitial()) {
    on<EditProfileSubmitted>(_onSubmitted);
    on<EditProfileReset>((event, emit) => emit(EditProfileInitial()));
  }

  Future<void> _onSubmitted(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    try {
      final Map<String, dynamic> body = {};
      if (event.username != null) body['username'] = event.username;
      if (event.email != null) body['newEmail'] = event.email;
      if (event.phoneNumber != null) body['phoneNumber'] = event.phoneNumber;
      if (event.profileImageId != null)
        body['profileImageId'] = event.profileImageId;

      if (body.isEmpty) {
        emit(EditProfileFailure('No changes provided'));
        return;
      }

      await repository.updateProfile(body);
      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileFailure(e.toString()));
    }
  }
}
