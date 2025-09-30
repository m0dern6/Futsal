import 'package:flutter/material.dart';
import 'package:futsalpay/features/auth/presentation/views/login_screen.dart';
import 'package:futsalpay/features/auth/presentation/views/register_screen.dart';
import 'package:futsalpay/features/book_now/presentation/views/book_now_screen.dart';
import 'package:futsalpay/features/bookings/presentation/views/booking_screen.dart';
import 'package:futsalpay/features/favorites/presentation/views/favorite_screen.dart';
import 'package:futsalpay/features/futsal_details/presentation/view/futsal_details_screen.dart';
import 'package:futsalpay/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:futsalpay/features/profile/presentation/views/profile_screen.dart';
import 'package:futsalpay/features/search_and_filter/presentation/view/search_filter_futsal_screen.dart';
import 'package:futsalpay/features/splash/presentation/views/splash_screen.dart';
import 'package:futsalpay/features/home/presentation/views/home_screen.dart';
import 'package:futsalpay/features/top_reviewed/presentation/view/top_reviewed_screen.dart';
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
        // Hide the shared BottomNavBar for certain full-screen pages
        final location = state.uri.toString();
        final hideFor = [
          '/search', // top-level search
          '/home/search', // nested search (if used)
          '/home/trending',
          '/trending',
          '/home/top-reviewed',
          '/topReviewed',
          // '/futsal-details',
        ];

        final shouldHide = hideFor.any((p) => location.startsWith(p));

        if (shouldHide) {
          // Return child inside plain scaffold so no bottom nav is shown
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: child,
          );
        }

        return BottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => SearchFilterFutsalScreen(),
            ),
            GoRoute(
              path: '/trending',
              builder: (context, state) => TrendingScreen(),
            ),
            GoRoute(
              path: '/top-reviewed',
              builder: (context, state) => TopReviewedScreen(),
            ),
          ],
        ),

        GoRoute(
          path: '/favorites',
          builder: (context, state) => FavoriteScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) => EditProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/bookNow',
      builder: (context, state) => BookNowScreen(ground: state.extra),
    ),
    GoRoute(path: '/bookings', builder: (context, state) => BookingScreen()),
    GoRoute(
      path: '/futsal-details',
      builder: (context, state) =>
          FutsalDetailsScreen(id: state.extra as String?),
    ),
  ],
);
