import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'account_management_event.dart';
part 'account_management_state.dart';

class AccountManagementBloc extends Bloc<AccountManagementEvent, AccountManagementState> {
  final AuthRepository authRepository;

  AccountManagementBloc({required this.authRepository}) : super(AccountManagementInitial()) {
    on<DeactivateAccountRequested>((event, emit) async {
      emit(AccountManagementLoading());
      try {
        await authRepository.deactivateAccount();
        emit(AccountDeactivated(message: 'Account deactivated successfully'));
      } catch (e) {
        emit(AccountManagementFailure(error: e.toString()));
      }
    });

    on<SendRevalidateEmailRequested>((event, emit) async {
      emit(AccountManagementLoading());
      try {
        await authRepository.sendRevalidateEmail();
        emit(RevalidateEmailSent(message: 'Revalidation email sent successfully'));
      } catch (e) {
        emit(AccountManagementFailure(error: e.toString()));
      }
    });
  }
}
