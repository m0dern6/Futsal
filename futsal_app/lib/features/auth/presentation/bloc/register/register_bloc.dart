import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/data/models/register_model.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterLoading());
      try {
        final result = await authRepository.register(event.userData);
        emit(RegisterSuccess(registerResponse: result));
      } catch (e) {
        emit(RegisterFailure(error: e.toString()));
      }
    });
  }
}
