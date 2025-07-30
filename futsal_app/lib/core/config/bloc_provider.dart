import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:futsalpay/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:futsalpay/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:futsalpay/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:futsalpay/features/splash/presentation/bloc/splash_bloc.dart';

class AppBlocProviders {
  static List<BlocProvider> get all => [
    //  BlocProviders here
    BlocProvider<SplashBloc>(create: (context) => SplashBloc(context)),

    BlocProvider<RegisterBloc>(
      create: (context) =>
          RegisterBloc(authRepository: context.read<AuthRepository>()),
    ),
    BlocProvider<LoginBloc>(
      create: (context) =>
          LoginBloc(authRepository: context.read<AuthRepository>()),
    ),
    BlocProvider<LogoutBloc>(
      create: (context) =>
          LogoutBloc(authRepository: context.read<AuthRepository>()),
    ),
  ];
}
