part of 'reset_password_bloc.dart';

@immutable
sealed class ResetPasswordState {}

final class ResetPasswordInitial extends ResetPasswordState {}

final class ResetPasswordLoading extends ResetPasswordState {}

final class ResetCodeVerified extends ResetPasswordState {
  final String email;
  final String resetCode;

  ResetCodeVerified({required this.email, required this.resetCode});
}

final class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  ResetPasswordSuccess({required this.message});
}

final class ResetPasswordFailure extends ResetPasswordState {
  final String error;

  ResetPasswordFailure({required this.error});
}
