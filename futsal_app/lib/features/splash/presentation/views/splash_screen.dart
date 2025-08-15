import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/home/presentation/bloc/futsal_ground/futsal_ground_bloc.dart';
import 'package:futsalpay/features/home/presentation/bloc/top_review_ground/top_review_ground_bloc.dart';
import 'package:futsalpay/features/home/presentation/bloc/trending_ground/trending_ground_bloc.dart';
import 'package:futsalpay/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Change the status bar color
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    // Initialize the SplashBloc
    BlocProvider.of<SplashBloc>(context).add(SplashStartedEvent());
    context.read<UserInfoBloc>().add(LoadUserInfo());
    context.read<TrendingGroundBloc>().add(LoadTrendingGrounds());
    context.read<TopReviewGroundBloc>().add(LoadTopReviewGrounds());
    context.read<FutsalGroundBloc>().add(LoadFutsalGrounds());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          if (state is SplashLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Check for in-app update before navigation
              try {
                final updateInfo = await InAppUpdate.checkForUpdate();
                if (updateInfo.updateAvailability ==
                    UpdateAvailability.updateAvailable) {
                  // Show dialog to user
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Update Available'),
                      content: const Text(
                        'A new version of the app is available. Please update to continue.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await InAppUpdate.performImmediateUpdate();
                            } catch (e) {
                              // Optionally handle update error
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              } catch (e) {
                // Optionally handle check error
              }
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token != null) {
                context.go('/home');
              } else {
                context.go('/login');
              }
            });
          }
          return Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightGreenAccent.withOpacity(0.9),
                        Colors.greenAccent.withOpacity(0.8),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/logo/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
