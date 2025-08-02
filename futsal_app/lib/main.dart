import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/bloc_provider.dart';
import 'package:futsalpay/core/config/repository_provider.dart';
import 'package:futsalpay/core/router/routes.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 2. Provide dependencies in the correct order
        // Level 1: Core services (no dependencies)
        Provider<ApiService>(create: (_) => ApiService()),

        ...AppRepositoryProviders.all,

        ...AppBlocProviders.all,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
