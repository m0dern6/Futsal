import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/favorites/presentation/bloc/favorite_ground_bloc.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';
import 'package:go_router/go_router.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteGroundBloc>().add(const LoadFavoriteGrounds());
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
      body: BlocBuilder<FavoriteGroundBloc, FavoriteGroundState>(
        builder: (context, state) {
          final bool isRefreshing = state is FavoriteGroundRefreshing;
          final FavoriteGroundState displayState = isRefreshing
              ? state.previous
              : state;

          final Widget content = RefreshIndicator(
            onRefresh: _refreshFavorites,
            color: theme.colorScheme.primary,
            child: _buildStateContent(context, displayState, theme),
          );

          if (!isRefreshing) {
            return content;
          }

          return Stack(
            children: [
              content,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _refreshFavorites() async {
    final bloc = context.read<FavoriteGroundBloc>();
    bloc.add(const RefreshFavoriteGrounds());
    await bloc.stream.firstWhere((state) {
      if (state is FavoriteGroundRefreshing) {
        return false;
      }
      return state is FavoriteGroundLoaded ||
          state is FavoriteGroundEmpty ||
          state is FavoriteGroundError;
    });
  }

  Widget _buildStateContent(
    BuildContext context,
    FavoriteGroundState state,
    ThemeData theme,
  ) {
    if (state is FavoriteGroundLoading || state is FavoriteGroundInitial) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: Dimension.height(300),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (state is FavoriteGroundError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Dimension.width(24)),
        children: [
          SizedBox(height: Dimension.height(120)),
          Icon(
            Icons.error_outline,
            size: Dimension.font(56),
            color: theme.colorScheme.error,
          ),
          SizedBox(height: Dimension.height(16)),
          Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: Dimension.height(8)),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Dimension.height(24)),
          FilledButton(
            onPressed: () => context.read<FavoriteGroundBloc>().add(
              const LoadFavoriteGrounds(),
            ),
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    if (state is FavoriteGroundEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: Dimension.height(160)),
          Icon(
            Icons.favorite_border,
            size: Dimension.font(64),
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: Dimension.height(16)),
          Center(
            child: Text('No favorites yet', style: theme.textTheme.titleMedium),
          ),
          SizedBox(height: Dimension.height(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimension.width(32)),
            child: Text(
              'Tap the heart icon on a futsal ground to save it here for quick access.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    if (state is FavoriteGroundLoaded) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          Dimension.width(16),
          Dimension.height(12),
          Dimension.width(16),
          Dimension.height(32),
        ),
        children: [
          Wrap(
            spacing: Dimension.width(16),
            runSpacing: Dimension.height(16),
            children: state.grounds
                .map((ground) => _FavoriteGroundCard(ground: ground))
                .toList(),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: Dimension.height(300),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _FavoriteGroundCard extends StatelessWidget {
  const _FavoriteGroundCard({required this.ground});

  final FutsalGroundModel ground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/futsal-details', extra: ground.id.toString()),
      child: Container(
        width: Dimension.width(155),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Dimension.width(18)),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(.25)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimension.width(18)),
                topRight: Radius.circular(Dimension.width(18)),
              ),
              child: Image.network(
                ground.imageUrl,
                width: double.infinity,
                height: Dimension.height(118),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(
                  height: Dimension.height(118),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimension.width(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ground.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Dimension.height(2)),
                  Text(
                    'Rs.${ground.pricePerHour}/hr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(.7),
                    ),
                  ),
                  SizedBox(height: Dimension.height(6)),
                  _RatingStars(rating: ground.averageRating),
                  SizedBox(height: Dimension.height(12)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/bookNow', extra: ground),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final displayRating = rating.isNaN ? 0.0 : rating;
    final int highlightedStars = displayRating.round().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < highlightedStars ? Icons.star : Icons.star_border,
          size: Dimension.font(12),
          color: Colors.amber,
        );
      }),
    );
  }
}
