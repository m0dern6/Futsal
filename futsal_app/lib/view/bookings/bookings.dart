import 'package:flutter/material.dart';
import '../../core/dimension.dart';
import 'data/repository/booking_repository.dart';
import 'data/model/booking.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _repo = BookingRepository();
  late Future<List<Booking>> _future;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    _future = _repo.getBookings();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getBookings();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _FilterBar(
            showUpcoming: _showUpcoming,
            onToggle: (val) => setState(() => _showUpcoming = val),
          ),
          Expanded(
            child: FutureBuilder<List<Booking>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _LoadingList();
                }
                if (snap.hasError) {
                  return _ErrorView(
                    message: snap.error.toString(),
                    onRetry: _refresh,
                  );
                }
                final data = snap.data ?? [];
                final now = DateTime.now();
                List<Booking> filtered =
                    data.where((b) {
                        // Basic upcoming vs past using bookingDate
                        if (_showUpcoming) {
                          return b.bookingDate.isAfter(now) ||
                              _sameDay(b.bookingDate, now);
                        } else {
                          return b.bookingDate.isBefore(now) &&
                              !_sameDay(b.bookingDate, now);
                        }
                      }).toList()
                      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

                if (filtered.isEmpty) {
                  return _EmptyView(
                    upcoming: _showUpcoming,
                    onRefresh: _refresh,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      Dimension.width(16),
                      Dimension.height(12),
                      Dimension.width(16),
                      Dimension.height(24),
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: Dimension.height(12)),
                    itemBuilder: (context, i) {
                      return _BookingCard(booking: filtered[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _FilterBar extends StatelessWidget {
  final bool showUpcoming;
  final ValueChanged<bool> onToggle;
  const _FilterBar({required this.showUpcoming, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: Dimension.width(16),
        vertical: Dimension.height(10),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Upcoming',
            active: showUpcoming,
            onTap: () => onToggle(true),
          ),
          SizedBox(width: Dimension.width(10)),
          _Segment(
            label: 'Past',
            active: !showUpcoming,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: Dimension.height(10)),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00A843) : const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(Dimension.width(12)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: Dimension.font(13),
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.black87,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Color _statusColor(int s) {
    switch (s) {
      case 0:
        return Colors.amber;
      case 1:
        return const Color(0xFF00A843);
      case 2:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(int s) {
    switch (s) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Removed unused old date format (YYYY-MM-DD)
  String _prettyDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[d.month - 1];
    return '$m ${d.day}, ${d.year}';
  }
  // Removed unused helper

  @override
  Widget build(BuildContext context) {
    String _formatRange() {
      String start = _friendlyTime(booking.startTime);
      String end = _friendlyTime(booking.endTime);
      return '$start - $end';
    }

    return Container(
      padding: EdgeInsets.all(Dimension.width(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimension.width(16)),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      booking.groundName.isEmpty
                          ? 'Ground'
                          : booking.groundName,
                      style: TextStyle(
                        fontSize: Dimension.font(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Dimension.height(4)),
                    Text(
                      _prettyDate(booking.bookingDate),
                      style: TextStyle(
                        fontSize: Dimension.font(12),
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(10),
                  vertical: Dimension.height(6),
                ),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Dimension.width(20)),
                ),
                child: Text(
                  _statusLabel(booking.status),
                  style: TextStyle(
                    fontSize: Dimension.font(11),
                    fontWeight: FontWeight.w700,
                    color: _statusColor(booking.status),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimension.height(12)),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: Dimension.width(16),
                color: const Color(0xFF00A843),
              ),
              SizedBox(width: Dimension.width(6)),
              Expanded(
                child: Text(
                  _formatRange(),
                  style: TextStyle(
                    fontSize: Dimension.font(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimension.height(8)),
          Row(
            children: [
              Icon(
                Icons.payments_outlined, // money/payment style icon
                size: Dimension.width(16),
                color: Colors.green[700],
              ),
              SizedBox(width: Dimension.width(6)),
              Text(
                'NPR ${booking.totalAmount.truncate()}',
                style: TextStyle(
                  fontSize: Dimension.font(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Time formatting helper: accepts
//  - 24h with seconds: HH:mm:ss (e.g. 13:00:00)
//  - 24h without seconds: HH:mm (e.g. 13:00)
//  - 12h with period: h:mm AM/PM (e.g. 1:00 PM)
// Returns 12h format: HH:mm AM/PM (leading zero hour)
String _friendlyTime(String raw) {
  final trimmed = raw.trim();

  // 24h with seconds
  final secMatch = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(trimmed);
  if (secMatch != null) {
    final h = int.parse(secMatch.group(1)!);
    final m = secMatch.group(2)!;
    final period = h >= 12 ? 'PM' : 'AM';
    int h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '${h12.toString().padLeft(2, '0')}:$m $period';
  }

  // 24h without seconds
  final noSecMatch = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(trimmed);
  if (noSecMatch != null) {
    final h = int.parse(noSecMatch.group(1)!);
    final m = noSecMatch.group(2)!;
    final period = h >= 12 ? 'PM' : 'AM';
    int h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '${h12.toString().padLeft(2, '0')}:$m $period';
  }

  // 12h already (normalize hour padding & period case)
  final ampmMatch = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (ampmMatch != null) {
    final h = int.parse(ampmMatch.group(1)!);
    final m = ampmMatch.group(2)!;
    final period = ampmMatch.group(3)!.toUpperCase();
    int h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '${h12.toString().padLeft(2, '0')}:$m $period';
  }

  return trimmed; // fallback
}

class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        Dimension.width(16),
        Dimension.height(12),
        Dimension.width(16),
        Dimension.height(24),
      ),
      itemCount: 6,
      itemBuilder: (context, i) {
        return Container(
          margin: EdgeInsets.only(bottom: Dimension.height(12)),
          height: Dimension.height(110),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimension.width(16)),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimension.width(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: Dimension.width(48),
              color: Colors.redAccent,
            ),
            SizedBox(height: Dimension.height(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: Dimension.height(16)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool upcoming;
  final VoidCallback onRefresh;
  const _EmptyView({required this.upcoming, required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: Dimension.height(120)),
          Icon(
            Icons.event_busy,
            size: Dimension.width(64),
            color: Colors.grey[400],
          ),
          SizedBox(height: Dimension.height(16)),
          Text(
            upcoming ? 'No upcoming bookings' : 'No past bookings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimension.font(16),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Dimension.height(8)),
          Text(
            'Pull to refresh or change filter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimension.font(12),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
