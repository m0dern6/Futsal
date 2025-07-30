import 'package:flutter/material.dart';
import 'package:futsalpay/features/auth/presentation/views/login_screen.dart';
import 'package:futsalpay/features/auth/presentation/views/register_screen.dart';
import 'package:futsalpay/features/book_now/presentation/views/book_now_screen.dart';
import 'package:futsalpay/features/bookings/presentation/views/booking_screen.dart';
import 'package:futsalpay/features/favorites/presentation/views/favorite_screen.dart';
import 'package:futsalpay/features/profile/presentation/views/profile_screen.dart';
import 'package:futsalpay/features/splash/presentation/views/splash_screen.dart';
import 'package:futsalpay/features/home/presentation/views/home_screen.dart';
import 'package:futsalpay/features/trending/presentation/views/trending_screen.dart';
import 'package:futsalpay/shared/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => LoginScreen(),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (BuildContext context, GoRouterState state) =>
              RegisterScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: '/trending',
              builder: (context, state) => TrendingScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => FavoriteScreen(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => BookingScreen(),
        ),
        GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      ],
    ),
    GoRoute(path: '/bookNow', builder: (context, state) => BookNowScreen()),
  ],
);
