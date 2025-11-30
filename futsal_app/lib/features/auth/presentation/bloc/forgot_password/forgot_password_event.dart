part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordEvent {}

final class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordSubmitted({required this.email});
}
