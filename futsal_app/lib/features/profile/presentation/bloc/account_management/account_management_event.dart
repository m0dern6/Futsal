part of 'account_management_bloc.dart';

@immutable
sealed class AccountManagementEvent {}

final class DeactivateAccountRequested extends AccountManagementEvent {}

final class SendRevalidateEmailRequested extends AccountManagementEvent {}
