import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/past.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/upcommings.dart';

class BookingTab extends StatelessWidget {
  const BookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final tabLabelStyle =
        textTheme.titleMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimension.width(6)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimension.width(16)),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(Dimension.width(12)),
              ),
              indicatorPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
              labelStyle: tabLabelStyle.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: tabLabelStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          SizedBox(height: Dimension.height(16)),
          const Expanded(
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [Upcommings(), Past()],
            ),
          ),
        ],
      ),
    );
  }
}
