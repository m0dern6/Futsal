import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRepository authRepository;

  LogoutBloc({required this.authRepository}) : super(LogoutInitial()) {
    on<LogoutButtonPressed>((event, emit) async {
      emit(LogoutLoading());
      try {
        await authRepository.logout();
        emit(LogoutSuccess(message: 'Logout successful'));
      } catch (e) {
        emit(LogoutFailure(error: e.toString()));
      }
    });
  }
}
