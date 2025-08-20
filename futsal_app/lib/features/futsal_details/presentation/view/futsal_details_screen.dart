import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:futsalpay/features/futsal_details/presentation/bloc/futsal_details_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'futsal_map_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FutsalDetailsScreen extends StatelessWidget {
  final String? id;
  const FutsalDetailsScreen({super.key, this.id});

  Future<void> _openMaps(String name, double lat, double lng) async {
    final googleUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
    final googleWeb = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl);
        return;
      }
    } catch (_) {}
    // fallback to web
    if (await canLaunchUrl(googleWeb)) {
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If id is provided, trigger load
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FutsalDetailsBloc>().add(LoadFutsalDetails(id!));
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.all(Dimension.width(8)),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(Dimension.width(8)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // Add share functionality
              },
              icon: const Icon(Icons.share, color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FutsalDetailsBloc, FutsalDetailsState>(
        builder: (context, state) {
          if (state is FutsalDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FutsalDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  SizedBox(height: Dimension.height(16)),
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: Dimension.height(8)),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }
          if (state is FutsalDetailsLoaded) {
            final d = state.data;
            return CustomScrollView(
              slivers: [
                // Hero Image Section
                SliverAppBar(
                  expandedHeight: Dimension.height(320),
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          d.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Rating badge
                        Positioned(
                          top: Dimension.height(260),
                          right: Dimension.width(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimension.width(12),
                              vertical: Dimension.height(6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: Dimension.width(4)),
                                Text(
                                  d.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Info
                        Padding(
                          padding: EdgeInsets.all(Dimension.width(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.name,
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: Dimension.height(4)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: colorScheme.primary,
                                            ),
                                            SizedBox(width: Dimension.width(4)),
                                            Expanded(
                                              child: Text(
                                                d.location,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimension.width(16),
                                      vertical: Dimension.height(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Rs.${d.pricePerHour}/hr',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: Dimension.height(16)),

                              // Stats Row
                              Row(
                                children: [
                                  _buildStatChip(
                                    context,
                                    icon: Icons.star,
                                    label:
                                        '${d.averageRating.toStringAsFixed(1)}',
                                    subtitle: '${d.ratingCount} reviews',
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: Dimension.width(12)),
                                  _buildStatChip(
                                    context,
                                    icon: Icons.event_available,
                                    label: '${d.bookingCount}',
                                    subtitle: 'bookings',
                                    color: colorScheme.secondary,
                                  ),
                                  if (d.distanceKm != null) ...[
                                    SizedBox(width: Dimension.width(12)),
                                    _buildStatChip(
                                      context,
                                      icon: Icons.directions,
                                      label:
                                          '${d.distanceKm!.toStringAsFixed(1)}km',
                                      subtitle: 'away',
                                      color: colorScheme.tertiary,
                                    ),
                                  ],
                                  Spacer(),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => FutsalMapScreen(
                                            name: d.name,
                                            latitude: d.latitude,
                                            longitude: d.longitude,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.location_on_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'View Map',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontSize: Dimension.font(12),
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Dimension.width(12),
                                        vertical: Dimension.height(8),
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: colorScheme
                                          .surfaceVariant
                                          .withOpacity(0.04),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Description Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimension.width(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Dimension.height(8)),
                              Text(
                                d.description,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: Dimension.height(24)),

                        // Details Card
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimension.width(20),
                          ),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(Dimension.width(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: Dimension.height(12)),
                                  _buildDetailRow(
                                    context,
                                    Icons.person,
                                    'Owner',
                                    '${d.ownerName}',
                                  ),
                                  _buildDetailRow(
                                    context,
                                    Icons.access_time,
                                    'Hours',
                                    '${d.openTime} - ${d.closeTime}',
                                  ),
                                  // _buildDetailRow(
                                  //   context,
                                  //   Icons.calendar_today,
                                  //   'Created',
                                  //   d.createdAt,
                                  // ),
                                  if (d.imageId != null)
                                    _buildDetailRow(
                                      context,
                                      Icons.image,
                                      'Image ID',
                                      d.imageId!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: Dimension.height(24)),

                        // Booked Slots Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimension.width(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booked Time Slots',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Dimension.height(12)),
                              if (d.bookedTimeSlots == null ||
                                  (d.bookedTimeSlots is List &&
                                      d.bookedTimeSlots.isEmpty))
                                Container(
                                  padding: EdgeInsets.all(Dimension.width(16)),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: Dimension.width(8)),
                                      Text(
                                        'No booked slots - Available now!',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: Dimension.width(8),
                                  runSpacing: Dimension.height(8),
                                  children: (d.bookedTimeSlots as List<dynamic>)
                                      .map<Widget>((slot) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Dimension.width(12),
                                            vertical: Dimension.height(6),
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.errorContainer,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            slot?.toString() ?? 'Unknown',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onErrorContainer,
                                                ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: Dimension.height(24)),

                        // Map Section
                        if (d.latitude != null && d.longitude != null) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimension.width(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: Dimension.height(12)),

                                // SizedBox(height: Dimension.height(12)),
                                Container(
                                  padding: EdgeInsets.all(Dimension.width(12)),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.place,
                                        size: 18,
                                        color: colorScheme.primary,
                                      ),
                                      SizedBox(width: Dimension.width(8)),
                                      Expanded(
                                        child: Text(
                                          'Lat: ${d.latitude.toStringAsFixed(4)}, Lng: ${d.longitude.toStringAsFixed(4)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          await _openMaps(
                                            d.name,
                                            d.latitude,
                                            d.longitude,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                        ),
                                        label: const Text('Maps'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Dimension.width(12),
                                            vertical: Dimension.height(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Bottom padding for FAB
                        SizedBox(height: Dimension.height(100)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No details to show.'));
        },
      ),
      floatingActionButton: BlocBuilder<FutsalDetailsBloc, FutsalDetailsState>(
        builder: (context, state) {
          if (state is FutsalDetailsLoaded) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.push('/bookNow', extra: state.data);
              },
              icon: const Icon(Icons.event_available),
              label: const Text('Book Now'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimension.width(12),
        vertical: Dimension.height(8),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: Dimension.width(6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: Dimension.height(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: Dimension.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
