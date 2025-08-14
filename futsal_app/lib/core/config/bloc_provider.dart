import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:futsalpay/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:futsalpay/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:futsalpay/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';
import 'package:futsalpay/features/home/domain/top_review_ground_repository.dart';
import 'package:futsalpay/features/home/domain/trending_ground_repository.dart';
import 'package:futsalpay/features/home/presentation/bloc/futsal_ground/futsal_ground_bloc.dart';
import 'package:futsalpay/features/home/presentation/bloc/top_review_ground/top_review_ground_bloc.dart';
import 'package:futsalpay/features/home/presentation/bloc/trending_ground/trending_ground_bloc.dart';
import 'package:futsalpay/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';
import 'package:futsalpay/shared/user_info/data/repository/user_info_repository.dart';

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
    BlocProvider<FutsalGroundBloc>(
      create: (context) =>
          FutsalGroundBloc(context.read<FutsalGroundRepository>()),
    ),
    BlocProvider<TopReviewGroundBloc>(
      create: (context) =>
          TopReviewGroundBloc(context.read<TopReviewGroundRepository>()),
    ),
    BlocProvider<TrendingGroundBloc>(
      create: (context) =>
          TrendingGroundBloc(context.read<TrendingGroundRepository>()),
    ),
    BlocProvider<UserInfoBloc>(
      create: (context) =>
          UserInfoBloc(context.read<UserInfoRepository>())..add(LoadUserInfo()),
    ),
  ];
}
