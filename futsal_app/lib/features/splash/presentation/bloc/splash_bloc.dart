import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(BuildContext context) : super(SplashInitial()) {
    print('SplashBloc initialized');
    on<SplashStartedEvent>((event, emit) async {
      emit(SplashLoading());
      print('Splash screen loading...');
      await Future.delayed(const Duration(seconds: 2), () {
        emit(SplashLoaded());
        print('Splash screen loaded');
      });
    });
  }
}
