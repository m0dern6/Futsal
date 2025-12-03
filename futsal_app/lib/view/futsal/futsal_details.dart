import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/dimension.dart';
import '../book_now/book_now.dart';

class FutsalDetails extends StatefulWidget {
  final Map<String, dynamic> futsalData;

  const FutsalDetails({super.key, required this.futsalData});

  @override
  State<FutsalDetails> createState() => _FutsalDetailsState();
}

class _FutsalDetailsState extends State<FutsalDetails> {
  String _fmtTime(dynamic raw) {
    if (raw == null) return 'N/A';
    final s = raw.toString().trim();
    final sec = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(s);
    if (sec != null) {
      final h = int.parse(sec.group(1)!);
      final m = sec.group(2)!;
      final period = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return '${h12.toString().padLeft(2, '0')}:$m $period';
    }
    final noSec = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(s);
    if (noSec != null) {
      final h = int.parse(noSec.group(1)!);
      final m = noSec.group(2)!;
      final period = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return '${h12.toString().padLeft(2, '0')}:$m $period';
    }
    final ampm = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(s);
    if (ampm != null) {
      final h = int.parse(ampm.group(1)!);
      final m = ampm.group(2)!;
      final period = ampm.group(3)!.toUpperCase();
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return '${h12.toString().padLeft(2, '0')}:$m $period';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: Dimension.height(300),
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.all(Dimension.width(8)),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: Dimension.width(8),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: Dimension.width(22),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(Dimension.width(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: Dimension.width(8),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,

                      color: widget.futsalData['isFavorite']
                          ? Colors.red
                          : null,
                      size: Dimension.width(22),
                    ),
                    onPressed: () {
                      // Handle favorite
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.futsalData['imageUrl'] != null)
                    Image.network(
                      widget.futsalData['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.sports_soccer,
                            size: Dimension.width(80),
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.sports_soccer,
                        size: Dimension.width(80),
                        color: Colors.grey[400],
                      ),
                    ),
                  // subtle gradient overlay for readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color.fromARGB(120, 0, 0, 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Dimension.width(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.futsalData['name'] ?? 'Futsal Court',
                                style: TextStyle(
                                  fontSize: Dimension.font(20),
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: Dimension.height(4)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: Dimension.width(18),
                                    color: const Color(0xFFFFA500),
                                  ),
                                  SizedBox(width: Dimension.width(6)),
                                  Text(
                                    widget.futsalData['averageRating']
                                            ?.toString() ??
                                        '0.0',
                                    style: TextStyle(
                                      fontSize: Dimension.font(14),
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  SizedBox(width: Dimension.width(8)),
                                  Text(
                                    '(${widget.futsalData['ratingCount'] ?? 0} reviews)',
                                    style: TextStyle(
                                      fontSize: Dimension.font(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: Dimension.width(16)),
                                  Image.asset(
                                    'assets/icons/booking.png',
                                    width: Dimension.width(14),
                                    height: Dimension.width(14),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.6),
                                  ),
                                  SizedBox(width: Dimension.width(6)),
                                  Text(
                                    '${widget.futsalData['bookingCount'] ?? 0} bookings',
                                    style: TextStyle(
                                      fontSize: Dimension.font(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle view on map
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/icons/map.png',
                                  width: Dimension.width(20),
                                  height: Dimension.width(20),
                                ),
                                Text(
                                  'view',
                                  style: TextStyle(
                                    fontSize: Dimension.font(12),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimension.height(20)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/location.png',
                            width: Dimension.width(18),
                            height: Dimension.width(18),
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: Dimension.width(8)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: Dimension.font(15),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.futsalData['location'] ?? '',
                                    style: TextStyle(
                                      fontSize: Dimension.font(13),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${widget.futsalData['distanceKm'] ?? '  --'} km',
                                    style: TextStyle(
                                      fontSize: Dimension.font(13),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.4),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Divider(
                    height: Dimension.height(1),
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: Dimension.height(16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/clock.png',
                        width: Dimension.width(18),
                        height: Dimension.width(18),
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: Dimension.width(8)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operating Hours',
                            style: TextStyle(
                              fontSize: Dimension.font(15),
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: Dimension.height(4)),
                          Text(
                            '${_fmtTime(widget.futsalData['openTime'])} - ${_fmtTime(widget.futsalData['closeTime'])}',
                            style: TextStyle(
                              fontSize: Dimension.font(14),
                              fontWeight: FontWeight.w400,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Divider(
                    height: Dimension.height(1),
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: Dimension.height(12)),
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: Dimension.font(15),
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: Dimension.height(10)),

                  Text(
                    widget.futsalData['description'],
                    style: TextStyle(
                      fontSize: Dimension.font(14),
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Divider(
                    height: Dimension.height(1),
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: Dimension.height(12)),

                  // Booked Slots (red-styled, always visible, no icon)
                  Text(
                    'Booked Slots',
                    style: TextStyle(
                      fontSize: Dimension.font(15),
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: Dimension.height(8)),

                  Builder(
                    builder: (context) {
                      final raw = widget.futsalData['bookedTimeSlots'];
                      final slots = (raw is List) ? raw : <dynamic>[];

                      if (slots.isEmpty) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: Dimension.height(10)),
                          padding: EdgeInsets.all(Dimension.width(12)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(
                              Dimension.width(10),
                            ),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.12),
                            ),
                          ),
                          child: Text(
                            'No booked slots',
                            style: TextStyle(
                              fontSize: Dimension.font(13),
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: slots.map((slot) {
                          String formattedDate = 'N/A';
                          try {
                            if (slot['bookingDate'] != null) {
                              final bookingDate = DateTime.parse(
                                slot['bookingDate'],
                              );
                              formattedDate = DateFormat(
                                'MMM dd, yyyy',
                              ).format(bookingDate);
                            }
                          } catch (_) {
                            formattedDate =
                                slot['bookingDate']?.toString() ?? 'N/A';
                          }

                          final start = slot['startTime'] ?? 'N/A';
                          final end = slot['endTime'] ?? 'N/A';

                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              bottom: Dimension.height(10),
                            ),
                            padding: EdgeInsets.all(Dimension.width(12)),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(
                                Dimension.width(10),
                              ),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.14),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: Dimension.font(13),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red[800],
                                  ),
                                ),
                                SizedBox(height: Dimension.height(6)),
                                Text(
                                  '${_fmtTime(start)} - ${_fmtTime(end)}',
                                  style: TextStyle(
                                    fontSize: Dimension.font(13),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red[700]?.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: Dimension.height(100)),
                ],
              ),
            ),
          ),
        ],
      ), // Close CustomScrollView

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(Dimension.width(16)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: Dimension.height(54),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: Dimension.height(8)),
                        Text(
                          'Starting from',
                          style: TextStyle(
                            fontSize: Dimension.font(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w400,
                            // height: 0.2,
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              '\Rs.${widget.futsalData['pricePerHour'] ?? '0'}',
                              style: TextStyle(
                                fontSize: Dimension.font(15),
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '/hour',
                              style: TextStyle(
                                fontSize: Dimension.font(12),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: Dimension.width(16)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookNow(futsalData: widget.futsalData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Color(0xFF00C853).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimension.width(8)),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: Dimension.font(15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedCreatedDate(String? createdAt) {
    if (createdAt == null) return 'Added recently';

    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Added today';
      } else if (difference.inDays == 1) {
        return 'Added yesterday';
      } else if (difference.inDays < 7) {
        return 'Added ${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Added $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else {
        return 'Added on ${DateFormat('MMM dd, yyyy').format(date)}';
      }
    } catch (e) {
      return 'Added recently';
    }
  }
}
