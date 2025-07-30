part of 'splash_bloc.dart';

@immutable
sealed class SplashEvent {}

final class SplashStartedEvent extends SplashEvent {
  SplashStartedEvent();
}
