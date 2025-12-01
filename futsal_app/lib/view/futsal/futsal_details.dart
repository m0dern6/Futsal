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
      backgroundColor: const Color(0xFFF5F5F5),
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
                  color: Colors.white,
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
                    color: Colors.black,
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
                    color: Colors.white,
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
                      Icons.favorite_outline,
                      color: Colors.black,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Rating Section
                Padding(
                  padding: EdgeInsets.all(Dimension.width(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.futsalData['name'] ?? 'Futsal Court',
                              style: TextStyle(
                                fontSize: Dimension.font(22),
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimension.height(8)),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: Dimension.width(18),
                            color: const Color(0xFFFFA500),
                          ),
                          SizedBox(width: Dimension.width(6)),
                          Text(
                            widget.futsalData['averageRating']?.toString() ??
                                '0.0',
                            style: TextStyle(
                              fontSize: Dimension.font(15),
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: Dimension.width(8)),
                          Text(
                            '(${widget.futsalData['ratingCount'] ?? 0} reviews)',
                            style: TextStyle(
                              fontSize: Dimension.font(13),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: Dimension.width(16)),
                          Icon(
                            Icons.verified_outlined,
                            size: Dimension.width(16),
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: Dimension.width(6)),
                          Text(
                            '${widget.futsalData['bookingCount'] ?? 0} bookings',
                            style: TextStyle(
                              fontSize: Dimension.font(13),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimension.height(10)),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: Dimension.width(18),
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: Dimension.width(8)),
                          Expanded(
                            child: Text(
                              widget.futsalData['location'] ?? 'Location',
                              style: TextStyle(
                                fontSize: Dimension.font(14),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (widget.futsalData['distanceKm'] != null) ...[
                            Text(
                              '${widget.futsalData['distanceKm'].toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: Dimension.font(13),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: Colors.grey[200],
                  thickness: Dimension.height(8),
                  height: Dimension.height(8),
                ),

                // Price Section
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(Dimension.width(16)),
                  child: Container(
                    margin: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimension.width(12),
                        vertical: Dimension.height(10),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00A843)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimension.width(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price per hour',
                                style: TextStyle(
                                  fontSize: Dimension.font(11),
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Dimension.height(2)),
                              Text(
                                'NPR ${((widget.futsalData['pricePerHour'] ?? 0) is num) ? (widget.futsalData['pricePerHour'] as num).truncate() : widget.futsalData['pricePerHour'] ?? 0}',
                                style: TextStyle(
                                  fontSize: Dimension.font(18),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: Dimension.width(24),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              SizedBox(width: Dimension.width(8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimension.width(8),
                                  vertical: Dimension.height(5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    Dimension.width(16),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Per Hour',
                                  style: TextStyle(
                                    fontSize: Dimension.font(11),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Dimension.height(12)),

                // Operating Hours
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimension.width(16),
                    vertical: Dimension.height(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimension.width(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Operating Hours',
                              style: TextStyle(
                                fontSize: Dimension.font(16),
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: Dimension.height(10)),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: Dimension.width(18),
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: Dimension.width(12)),
                                Text(
                                  '${_fmtTime(widget.futsalData['openTime'])} - ${_fmtTime(widget.futsalData['closeTime'])}',
                                  style: TextStyle(
                                    fontSize: Dimension.font(15),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ], // Close children array
                  ), // Close Column
                ), // Close Container

                SizedBox(height: Dimension.height(24)),

                // Description
                if (widget.futsalData['description'] != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: Dimension.font(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: Dimension.height(12)),
                        Text(
                          widget.futsalData['description'],
                          style: TextStyle(
                            fontSize: Dimension.font(15),
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimension.height(24)),
                ],

                // Owner Information
                if (widget.futsalData['ownerName'] != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: Dimension.font(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: Dimension.height(12)),
                        Row(
                          children: [
                            Container(
                              width: Dimension.width(48),
                              height: Dimension.width(48),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: Dimension.width(24),
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: Dimension.width(12)),
                            Text(
                              widget.futsalData['ownerName'],
                              style: TextStyle(
                                fontSize: Dimension.font(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimension.height(24)),
                ],

                // Booked Time Slots
                if (widget.futsalData['bookedTimeSlots'] != null &&
                    (widget.futsalData['bookedTimeSlots'] as List)
                        .isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booked Time Slots',
                          style: TextStyle(
                            fontSize: Dimension.font(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: Dimension.height(12)),
                        ...(widget.futsalData['bookedTimeSlots'] as List).map((
                          slot,
                        ) {
                          DateTime? bookingDate;
                          String formattedDate = 'N/A';

                          try {
                            if (slot['bookingDate'] != null) {
                              bookingDate = DateTime.parse(slot['bookingDate']);
                              formattedDate = DateFormat(
                                'MMM dd, yyyy',
                              ).format(bookingDate);
                            }
                          } catch (e) {
                            formattedDate =
                                slot['bookingDate']?.toString() ?? 'N/A';
                          }

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: Dimension.height(10),
                            ),
                            padding: EdgeInsets.all(Dimension.width(14)),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(
                                Dimension.width(12),
                              ),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: Dimension.width(20),
                                  color: Colors.red[700],
                                ),
                                SizedBox(width: Dimension.width(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: Dimension.font(14),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: Dimension.height(2)),
                                      Text(
                                        '${slot['startTime'] ?? 'N/A'} - ${slot['endTime'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: Dimension.font(13),
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimension.height(24)),
                ],

                // Location Coordinates
                if (widget.futsalData['latitude'] != null &&
                    widget.futsalData['longitude'] != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(Dimension.width(14)),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          Dimension.width(12),
                        ),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: Dimension.width(20),
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: Dimension.width(12)),
                          Expanded(
                            child: Text(
                              'Lat: ${widget.futsalData['latitude']}, Lng: ${widget.futsalData['longitude']}',
                              style: TextStyle(
                                fontSize: Dimension.font(13),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.map_outlined,
                            size: Dimension.width(20),
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Dimension.height(24)),
                ],

                // Created At
                if (widget.futsalData['createdAt'] != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: Dimension.width(16),
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: Dimension.width(8)),
                        Text(
                          _getFormattedCreatedDate(
                            widget.futsalData['createdAt'],
                          ),
                          style: TextStyle(
                            fontSize: Dimension.font(13),
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimension.height(24)),
                ],

                SizedBox(height: Dimension.height(100)),
              ],
            ),
          ),
        ],
      ), // Close CustomScrollView

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(Dimension.width(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.06)),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: Dimension.height(54),
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
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFF00C853).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
              ),
              child: Text(
                'Book Now',
                style: TextStyle(
                  fontSize: Dimension.font(16),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
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
