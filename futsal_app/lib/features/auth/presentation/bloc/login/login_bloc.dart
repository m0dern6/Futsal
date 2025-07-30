import 'package:futsalpay/features/auth/data/models/login_model.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final result = await authRepository.login(event.email, event.password);
        emit(LoginSuccess(loginResponse: result));
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
