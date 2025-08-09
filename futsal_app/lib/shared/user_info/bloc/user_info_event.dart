part of 'user_info_bloc.dart';

@immutable
sealed class UserInfoEvent {}

class LoadUserInfo extends UserInfoEvent {}
