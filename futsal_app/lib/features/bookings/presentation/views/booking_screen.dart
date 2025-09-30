import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/bookings/data/repository/bookings_repository.dart';
import 'package:futsalpay/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/booking_tab.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingsBloc(BookingsRepository()),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final headlineStyle =
        textTheme.headlineSmall ??
        const TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
    final subtitleStyle =
        textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
    final helperStyle =
        textTheme.bodySmall ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(20),
                vertical: Dimension.height(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bookings',
                              style: headlineStyle.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: Dimension.height(6)),
                            Text(
                              'Manage and track your futsal sessions.',
                              style: subtitleStyle.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Dimension.width(12)),
                      Container(
                        padding: EdgeInsets.all(Dimension.width(12)),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                            Dimension.width(12),
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: colorScheme.primary,
                          size: Dimension.width(22),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(18)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Dimension.width(16)),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimension.width(16)),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: Dimension.width(42),
                          height: Dimension.width(42),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(
                              Dimension.width(12),
                            ),
                          ),
                          child: Icon(
                            Icons.sports_soccer,
                            color: colorScheme.tertiary,
                            size: Dimension.width(22),
                          ),
                        ),
                        SizedBox(width: Dimension.width(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stay game-ready',
                                style:
                                    (textTheme.titleMedium ??
                                            const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ))
                                        .copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                              SizedBox(height: Dimension.height(4)),
                              Text(
                                'Check upcoming bookings or revisit past matches using the tabs below.',
                                style: helperStyle.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(Dimension.width(28)),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimension.width(20),
                    Dimension.height(20),
                    Dimension.width(20),
                    0,
                  ),
                  child: const BookingTab(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
