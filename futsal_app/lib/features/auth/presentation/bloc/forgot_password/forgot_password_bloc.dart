import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc({required this.authRepository}) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        final response = await authRepository.forgotPassword(event.email);
        emit(ForgotPasswordSuccess(message: response.message));
      } catch (e) {
        emit(ForgotPasswordFailure(error: e.toString()));
      }
    });
  }
}
