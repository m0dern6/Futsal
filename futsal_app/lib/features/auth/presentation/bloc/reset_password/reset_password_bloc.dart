import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final AuthRepository authRepository;

  ResetPasswordBloc({required this.authRepository}) : super(ResetPasswordInitial()) {
    on<VerifyResetCodeSubmitted>((event, emit) async {
      emit(ResetPasswordLoading());
      try {
        await authRepository.verifyResetCode(event.email, event.resetCode);
        emit(ResetCodeVerified(email: event.email, resetCode: event.resetCode));
      } catch (e) {
        emit(ResetPasswordFailure(error: e.toString()));
      }
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      emit(ResetPasswordLoading());
      try {
        final response = await authRepository.resetPassword(
          event.email,
          event.resetCode,
          event.newPassword,
        );
        emit(ResetPasswordSuccess(message: response.message));
      } catch (e) {
        emit(ResetPasswordFailure(error: e.toString()));
      }
    });
  }
}
