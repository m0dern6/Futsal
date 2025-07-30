import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/bloc_provider.dart';
import 'package:futsalpay/core/config/repository_provider.dart';
import 'package:futsalpay/core/router/routes.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/repository/auth_repository_impl.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: AppRepositoryProviders.all,
      child: MultiBlocProvider(
        providers: AppBlocProviders.all,
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
