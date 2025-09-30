import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/booking_card.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';

class Upcommings extends StatefulWidget {
  const Upcommings({super.key});

  @override
  State<Upcommings> createState() => _UpcommingsState();
}

class _UpcommingsState extends State<Upcommings> {
  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() {
    final userInfoState = context.read<UserInfoBloc>().state;
    if (userInfoState is UserInfoLoaded) {
      context.read<BookingsBloc>().add(
        FetchBookings(userId: userInfoState.userInfo.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BookingsBloc, BookingsState>(
      builder: (context, state) {
        if (state is BookingsLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (state is BookingsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.error,
                  size: Dimension.width(48),
                ),
                SizedBox(height: Dimension.height(16)),
                Text(
                  'Error loading bookings',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: Dimension.font(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimension.height(8)),
                Text(
                  state.message,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: Dimension.font(12),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimension.height(16)),
                ElevatedButton(onPressed: _fetchBookings, child: Text('Retry')),
              ],
            ),
          );
        }

        if (state is BookingsLoaded) {
          final upcomingBookings = state.upcomingBookings;

          if (upcomingBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: Dimension.width(64),
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Text(
                    'No Upcoming Bookings',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: Dimension.font(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Dimension.height(8)),
                  Text(
                    'Book a futsal ground to see your upcoming bookings here',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: Dimension.font(14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchBookings();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(Dimension.width(16)),
              itemCount: upcomingBookings.length,
              itemBuilder: (context, index) {
                return BookingCard(booking: upcomingBookings[index]);
              },
            ),
          );
        }

        return Center(
          child: Text(
            'Start booking to see your upcoming reservations',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: Dimension.font(14),
            ),
          ),
        );
      },
    );
  }
}
