import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/repository/auth_repository_impl.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';

class AppRepositoryProviders {
  static List<RepositoryProvider> get all => [
    //  BlocProviders here
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(ApiService()),
    ),
  ];
}
