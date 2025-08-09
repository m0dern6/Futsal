import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/repository/auth_repository_impl.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:futsalpay/features/home/data/repository/futsal_ground_repository_impl.dart';
import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';
import 'package:futsalpay/shared/user_info/data/repository/user_info_repository.dart';

class AppRepositoryProviders {
  static List<RepositoryProvider> get all => [
    //  BlocProviders here
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(ApiService()),
    ),
    RepositoryProvider<FutsalGroundRepository>(
      create: (context) =>
          FutsalGroundRepositoryImpl(context.read<ApiService>()),
    ),
    RepositoryProvider<UserInfoRepository>(
      create: (context) => UserInfoRepository(context.read<ApiService>()),
    ),
  ];
}
