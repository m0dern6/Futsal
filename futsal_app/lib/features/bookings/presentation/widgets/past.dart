import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/booking_card.dart';

class Past extends StatelessWidget {
  const Past({super.key});

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
              ],
            ),
          );
        }

        if (state is BookingsLoaded) {
          final pastBookings = state.pastBookings;

          if (pastBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: Dimension.width(64),
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Text(
                    'No Past Bookings',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: Dimension.font(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Dimension.height(8)),
                  Text(
                    'Your booking history will appear here after you complete bookings',
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

          return ListView.builder(
            padding: EdgeInsets.all(Dimension.width(16)),
            itemCount: pastBookings.length,
            itemBuilder: (context, index) {
              return BookingCard(booking: pastBookings[index]);
            },
          );
        }

        return Center(
          child: Text(
            'Your booking history will appear here',
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
