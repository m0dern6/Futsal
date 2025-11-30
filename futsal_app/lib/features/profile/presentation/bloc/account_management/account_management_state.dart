part of 'account_management_bloc.dart';

@immutable
sealed class AccountManagementState {}

final class AccountManagementInitial extends AccountManagementState {}

final class AccountManagementLoading extends AccountManagementState {}

final class AccountDeactivated extends AccountManagementState {
  final String message;

  AccountDeactivated({required this.message});
}

final class RevalidateEmailSent extends AccountManagementState {
  final String message;

  RevalidateEmailSent({required this.message});
}

final class AccountManagementFailure extends AccountManagementState {
  final String error;

  AccountManagementFailure({required this.error});
}
