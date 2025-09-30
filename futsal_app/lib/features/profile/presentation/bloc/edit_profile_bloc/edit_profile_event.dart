part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

final class EditProfileSubmitted extends EditProfileEvent {
  final String? username;
  final String? email;
  final String? phoneNumber;
  final int? profileImageId;

  EditProfileSubmitted({
    this.username,
    this.email,
    this.phoneNumber,
    this.profileImageId,
  });
}

final class EditProfileReset extends EditProfileEvent {}
