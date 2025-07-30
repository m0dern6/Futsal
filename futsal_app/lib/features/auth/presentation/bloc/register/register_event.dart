part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final Map<String, dynamic> userData;

  RegisterButtonPressed({required this.userData});
}
