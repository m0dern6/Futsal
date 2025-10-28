import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/services/api_service.dart';
import 'package:futsalpay/features/auth/data/repository/auth_repository_impl.dart';
import 'package:futsalpay/features/auth/domain/repository/auth_repository.dart';
import 'package:futsalpay/features/home/data/repository/futsal_ground_repository_impl.dart';
import 'package:futsalpay/features/home/data/repository/top_review_ground_repository_iml.dart';
import 'package:futsalpay/features/home/data/repository/trending_ground_repository_iml.dart';
import 'package:futsalpay/features/futsal_details/data/repository/futsal_details_repository_impl.dart';
import 'package:futsalpay/features/futsal_details/domain/futsal_details_repository.dart';
import 'package:futsalpay/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:futsalpay/features/favorites/domain/favorites_repository.dart';
import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';
import 'package:futsalpay/features/home/domain/top_review_ground_repository.dart';
import 'package:futsalpay/features/home/domain/trending_ground_repository.dart';
import 'package:futsalpay/shared/user_info/data/repository/user_info_repository.dart';
import 'package:futsalpay/features/book_now/data/repository/booking_repository.dart';

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
    RepositoryProvider<TopReviewGroundRepository>(
      create: (context) =>
          TopReviewGroundRepositoryImpl(context.read<ApiService>()),
    ),
    RepositoryProvider<TrendingGroundRepository>(
      create: (context) =>
          TrendingGroundRepositoryImpl(context.read<ApiService>()),
    ),
    RepositoryProvider<FavoritesRepository>(
      create: (context) => FavoritesRepositoryImpl(context.read<ApiService>()),
    ),
    RepositoryProvider<UserInfoRepository>(
      create: (context) => UserInfoRepository(context.read<ApiService>()),
    ),
    RepositoryProvider<FutsalDetailsRepository>(
      create: (context) =>
          FutsalDetailsRepositoryImpl(context.read<ApiService>()),
    ),
    RepositoryProvider<BookingRepository>(
      create: (context) =>
          BookingRepository(apiService: context.read<ApiService>()),
    ),
  ];
}
