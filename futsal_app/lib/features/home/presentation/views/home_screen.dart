import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/presentation/widgets/search_box.dart';
import 'package:futsalpay/features/home/presentation/widgets/venues.dart';
import 'package:futsalpay/features/home/presentation/widgets/trending_venues.dart';
import 'package:futsalpay/features/home/presentation/widgets/top_reviewed_venues.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text('Discover', style: theme.textTheme.titleLarge),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(Dimension.height(70)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Dimension.width(16),
                  0,
                  Dimension.width(16),
                  Dimension.height(12),
                ),
                child: const SearchBox(),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimension.width(16),
              vertical: Dimension.height(8),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionCard(
                  context,
                  title: 'Trending Now',
                  subtitle: 'Hot picks players love',
                  child: const TrendingSection(),
                  onViewAll: () => context.go('/home/trending'),
                ),
                SizedBox(height: Dimension.height(16)),
                _sectionCard(
                  context,
                  title: 'Top Reviewed',
                  subtitle: 'Highest reviewed grounds',
                  child: const TopReviewSection(),
                  onViewAll: () => context.go('/home/top-reviewed'),
                ),
                SizedBox(height: Dimension.height(16)),
                _venuesSection(context),
                SizedBox(height: Dimension.height(120)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionCard(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget child,
  VoidCallback? onViewAll,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 18),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget _venuesSection(BuildContext context) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Venues',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/home/search');
              },
              child: const Text('View All'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Venues(),
    ],
  );
}
