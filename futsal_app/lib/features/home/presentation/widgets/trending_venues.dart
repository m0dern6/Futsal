import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/data/model/trending_ground_model.dart';
import 'package:futsalpay/features/home/presentation/bloc/trending_ground/trending_ground_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  @override
  void initState() {
    super.initState();
    context.read<TrendingGroundBloc>().add(
      const LoadTrendingGrounds(page: 1, pageSize: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        // Header provided by parent section card now; keep for standalone reuse
        // (hidden when embedded in section card) but we still show nothing here.
        SizedBox(height: Dimension.height(10)),

        // Horizontal Slider
        SizedBox(
          height: Dimension.height(204), // Fixed height for the slider
          child: BlocBuilder<TrendingGroundBloc, TrendingGroundState>(
            builder: (context, state) {
              if (state is TrendingGroundLoading) {
                return _buildShimmerEffect();
              }
              if (state is TrendingGroundLoaded) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.grounds.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: Dimension.width(15)),
                      child: _buildTrendingCard(context, state.grounds[index]),
                    );
                  },
                );
              }
              if (state is TrendingGroundError) {
                return Center(
                  child: Text(
                    'Failed to load trending venues',
                    style: TextStyle(
                      color: Color(0xff91A693),
                      fontSize: Dimension.font(12),
                    ),
                  ),
                );
              }
              return Center(
                child: Text(
                  'No trending venues available',
                  style: TextStyle(
                    color: Color(0xff91A693),
                    fontSize: Dimension.font(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(BuildContext context, TrendingGroundModel ground) {
    final theme = Theme.of(context);
    return Container(
      width: Dimension.width(170),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimension.width(18)),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(.25),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // Navigate to details screen and pass the ground id as extra (string)
          context.push('/futsal-details', extra: ground.id.toString());
        },
        child: Column(
          children: [
            // Trending Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimension.width(18)),
                    topRight: Radius.circular(Dimension.width(18)),
                  ),
                  child: Image.network(
                    ground.imageUrl,
                    width: double.infinity,
                    height: Dimension.height(110),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: Dimension.height(110),
                      color: theme.colorScheme.surfaceContainer,
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: Dimension.height(8),
                  right: Dimension.width(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(6),
                      vertical: Dimension.height(2),
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: theme.colorScheme.onSecondary,
                          size: Dimension.font(10),
                        ),
                        SizedBox(width: Dimension.width(2)),
                        Text(
                          'HOT',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                            fontSize: Dimension.font(8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(Dimension.width(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ground.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: Dimension.font(13),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rs.${ground.pricePerHour}/hr',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(.7),
                            fontSize: Dimension.font(10.5),
                          ),
                        ),
                        SizedBox(height: Dimension.height(2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRatingStars(ground.averageRating),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimension.width(4),
                                vertical: Dimension.height(1),
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  .16,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Dimension.width(10),
                                ),
                              ),
                              child: Text(
                                '${ground.bookingCount} bookings',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: Dimension.font(7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(
                          double.infinity,
                          Dimension.height(28),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimension.width(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Convert TrendingGroundModel to FutsalGroundModel or pass directly
                        context.push('/bookNow', extra: ground);
                      },
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: Dimension.font(10.5),
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int numberOfStars = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < numberOfStars ? Icons.star : Icons.star_border,
          color: Colors.yellow,
          size: Dimension.font(10),
        );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: Dimension.width(15)),
            child: Container(
              width: Dimension.width(160),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xff04340B),
                  width: Dimension.width(0.5),
                ),
                borderRadius: BorderRadius.circular(Dimension.width(8)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: Dimension.height(100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimension.width(8)),
                        topRight: Radius.circular(Dimension.width(8)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(Dimension.width(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: Dimension.height(13),
                            color: Colors.white,
                          ),
                          SizedBox(height: Dimension.height(4)),
                          Container(
                            width: Dimension.width(70),
                            height: Dimension.height(10.5),
                            color: Colors.white,
                          ),
                          SizedBox(height: Dimension.height(4)),
                          Container(
                            width: Dimension.width(60),
                            height: Dimension.height(10),
                            color: Colors.white,
                          ),
                          Spacer(),
                          Container(
                            width: double.infinity,
                            height: Dimension.height(28),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
