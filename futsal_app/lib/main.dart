import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/bloc_provider.dart';
import 'package:futsalpay/core/config/repository_provider.dart';
import 'package:futsalpay/core/router/routes.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/core/theme/theme_notifier.dart';
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
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()..load()),
        ...AppRepositoryProviders.all,
        ...AppBlocProviders.all,
      ],
      child: Consumer<ThemeNotifier>(
        builder: (_, theme, __) => MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.mode,
        ),
      ),
    );
  }
}
