import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/bloc_provider.dart';
import 'package:futsalpay/core/config/repository_provider.dart';
import 'package:futsalpay/core/router/routes.dart';

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
