import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/dimension.dart';
import '../bookings/data/repository/booking_repository.dart';
import '../bookings/bookings.dart';
import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_state.dart';

class BookNow extends StatefulWidget {
  final Map<String, dynamic> futsalData;

  const BookNow({super.key, required this.futsalData});

  @override
  State<BookNow> createState() => _BookNowState();
}

class _BookNowState extends State<BookNow> {
  final _bookingRepo = BookingRepository();
  int _selectedDateIndex = 0;
  String? _selectedTimeSlot;
  bool _showConfirmation = false;
  bool _isBooking = false;

  List<DateTime> _generateNext7Days() {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  List<String> _generateTimeSlots() {
    final openTime = widget.futsalData['openTime'] ?? '06:00 AM';
    final closeTime = widget.futsalData['closeTime'] ?? '10:00 PM';

    // Parse times (assuming format like "06:00 AM")
    final openHour = _parseTime(openTime);
    final closeHour = _parseTime(closeTime);

    List<String> slots = [];
    for (int hour = openHour; hour < closeHour; hour++) {
      final startTime = _formatTimeSlot(hour);
      final endTime = _formatTimeSlot(hour + 1);
      slots.add('$startTime - $endTime');
    }
    return slots;
  }

  int _parseTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final isPM = time.toUpperCase().contains('PM');
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return hour;
    } catch (e) {
      return 6; // Default to 6 AM
    }
  }

  String _formatTimeSlot(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:00 $period';
  }

  String _convertTo24HourFormat(String time12h) {
    // Convert "02:00 PM" to "14:00:00"
    final parts = time12h.split(':');
    if (parts.length < 2) return '00:00:00';

    int hour = int.tryParse(parts[0].trim()) ?? 0;
    final minutePart = parts[1].split(' ');
    final minute = minutePart[0].trim();
    final period = minutePart.length > 1
        ? minutePart[1].trim().toUpperCase()
        : 'AM';

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }

  bool _isTimeSlotBooked(DateTime selectedDate, String timeSlot) {
    final bookedSlots = widget.futsalData['bookedTimeSlots'] as List? ?? [];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    for (var slot in bookedSlots) {
      try {
        final bookingDate = DateTime.parse(slot['bookingDate']);
        final bookingDateStr = DateFormat('yyyy-MM-dd').format(bookingDate);

        if (bookingDateStr == selectedDateStr) {
          final bookedTime = '${slot['startTime']} - ${slot['endTime']}';
          if (bookedTime == timeSlot) {
            return true;
          }
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  void _showConfirmationDialog() {
    setState(() {
      _showConfirmation = true;
    });
  }

  Future<void> _confirmBooking() async {
    if (_isBooking) return;

    setState(() => _isBooking = true);

    try {
      // Get user ID from ProfileBloc
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is! ProfileLoaded) {
        throw Exception('User not logged in');
      }

      final userId = profileState.userInfo.id;
      final groundId = widget.futsalData['id'] as int;
      final dates = _generateNext7Days();
      final selectedDate = dates[_selectedDateIndex];

      // Parse time slot (format: "HH:MM AM/PM - HH:MM AM/PM")
      final times = _selectedTimeSlot!.split(' - ');
      final startTimeStr = times[0].trim();
      final endTimeStr = times[1].trim();

      // Convert "02:00 PM" to "14:00:00" format
      final startTime = _convertTo24HourFormat(startTimeStr);
      final endTime = _convertTo24HourFormat(endTimeStr);

      // Format booking date to start of day in UTC (midnight)
      final bookingDateUtc = DateTime.utc(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        0,
        0,
        0,
      );

      // Create booking
      await _bookingRepo.createBooking(
        userId: userId,
        groundId: groundId,
        bookingDate: bookingDateUtc,
        startTime: startTime,
        endTime: endTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking confirmed successfully!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to bookings screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BookingsScreen()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to book: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final dates = _generateNext7Days();
    final timeSlots = _generateTimeSlots();
    final selectedDate = dates[_selectedDateIndex];

    if (_showConfirmation) {
      return _buildConfirmationScreen(selectedDate);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: Dimension.width(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Court',
          style: TextStyle(
            fontSize: Dimension.font(20),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Futsal Name
            Container(
              padding: EdgeInsets.all(Dimension.width(20)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: Dimension.width(24),
                    color: Colors.black,
                  ),
                  SizedBox(width: Dimension.width(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.futsalData['name'] ?? 'Futsal Court',
                          style: TextStyle(
                            fontSize: Dimension.font(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: Dimension.height(2)),
                        Text(
                          widget.futsalData['location'] ?? '',
                          style: TextStyle(
                            fontSize: Dimension.font(13),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFF00A843)],
                      ),
                      borderRadius: BorderRadius.circular(Dimension.width(8)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Rs ${widget.futsalData['pricePerHour']}/hr',
                      style: TextStyle(
                        fontSize: Dimension.font(12),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(12)),

            // Date Selection
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(Dimension.width(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: Dimension.font(18),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: Dimension.height(14)),
                  SizedBox(
                    height: Dimension.height(85),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final isSelected = index == _selectedDateIndex;
                        final dayName = DateFormat('EEE').format(date);
                        final dayNumber = DateFormat('dd').format(date);
                        final monthName = DateFormat('MMM').format(date);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateIndex = index;
                              _selectedTimeSlot = null; // Reset time selection
                            });
                          },
                          child: Container(
                            width: Dimension.width(70),
                            margin: EdgeInsets.only(right: Dimension.width(12)),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00C853),
                                        Color(0xFF00A843),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey[50],
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00C853)
                                    : Colors.black.withOpacity(0.08),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: Dimension.font(11),
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: Dimension.height(6)),
                                Text(
                                  dayNumber,
                                  style: TextStyle(
                                    fontSize: Dimension.font(24),
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(height: Dimension.height(2)),
                                Text(
                                  monthName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: Dimension.font(10),
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(12)),

            // Time Slot Selection
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(Dimension.width(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Time Slot',
                        style: TextStyle(
                          fontSize: Dimension.font(18),
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: Dimension.width(8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimension.width(8),
                          vertical: Dimension.height(4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            Dimension.width(6),
                          ),
                        ),
                        child: Text(
                          '1 hour',
                          style: TextStyle(
                            fontSize: Dimension.font(11),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimension.height(14)),
                  Wrap(
                    spacing: Dimension.width(10),
                    runSpacing: Dimension.height(10),
                    children: timeSlots.map((slot) {
                      final isBooked = _isTimeSlotBooked(selectedDate, slot);
                      final isSelected = slot == _selectedTimeSlot;

                      return GestureDetector(
                        onTap: isBooked
                            ? null
                            : () {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimension.width(12),
                            vertical: Dimension.height(10),
                          ),
                          decoration: BoxDecoration(
                            gradient: isBooked
                                ? null
                                : isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00C853),
                                      Color(0xFF00A843),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isBooked
                                ? Colors.red[50]
                                : isSelected
                                ? null
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(
                              Dimension.width(10),
                            ),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.red[200]!
                                  : isSelected
                                  ? const Color(0xFF00C853)
                                  : Colors.black.withOpacity(0.08),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected && !isBooked
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00C853,
                                      ).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isBooked) ...[
                                Icon(
                                  Icons.block,
                                  size: Dimension.width(12),
                                  color: Colors.red[700],
                                ),
                                SizedBox(width: Dimension.width(4)),
                              ],
                              Text(
                                slot,
                                style: TextStyle(
                                  fontSize: Dimension.font(11.5),
                                  fontWeight: FontWeight.w600,
                                  color: isBooked
                                      ? Colors.red[700]
                                      : isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(100)),
          ],
        ),
      ),

      // Continue Button
      bottomNavigationBar: _selectedTimeSlot != null
          ? SafeArea(
              child: Container(
                padding: EdgeInsets.all(Dimension.width(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.06)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: Dimension.width(10),
                      offset: Offset(0, -Dimension.height(2)),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: Dimension.height(54),
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF00C853).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimension.width(14),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: Dimension.width(8)),
                        Icon(Icons.arrow_forward, size: Dimension.width(20)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildConfirmationScreen(DateTime selectedDate) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: Dimension.width(24),
          ),
          onPressed: () {
            setState(() {
              _showConfirmation = false;
            });
          },
        ),
        title: Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: Dimension.font(20),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Dimension.height(20)),

            // Success Icon
            Container(
              width: Dimension.width(80),
              height: Dimension.width(80),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green[200]!, width: 2),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: Dimension.width(48),
                color: Colors.green[700],
              ),
            ),

            SizedBox(height: Dimension.height(24)),

            Text(
              'Review Your Booking',
              style: TextStyle(
                fontSize: Dimension.font(24),
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            SizedBox(height: Dimension.height(8)),

            Text(
              'Please review the details before confirming',
              style: TextStyle(
                fontSize: Dimension.font(14),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: Dimension.height(32)),

            // Booking Details Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              padding: EdgeInsets.all(Dimension.width(20)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimension.width(20)),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: Dimension.width(20),
                    offset: Offset(0, Dimension.height(4)),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.sports_soccer,
                    'Futsal Court',
                    widget.futsalData['name'] ?? '',
                  ),
                  Divider(
                    height: Dimension.height(32),
                    color: Colors.grey[200],
                  ),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Location',
                    widget.futsalData['location'] ?? '',
                  ),
                  Divider(
                    height: Dimension.height(32),
                    color: Colors.grey[200],
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate),
                  ),
                  Divider(
                    height: Dimension.height(32),
                    color: Colors.grey[200],
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Time Slot',
                    _selectedTimeSlot ?? '',
                  ),
                  Divider(
                    height: Dimension.height(32),
                    color: Colors.grey[200],
                  ),
                  _buildDetailRow(
                    Icons.monetization_on_outlined,
                    'Total Amount',
                    'Rs ${widget.futsalData['pricePerHour'] ?? 0}',
                    isHighlighted: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(32)),

            // Terms Notice
            Container(
              margin: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
              padding: EdgeInsets.all(Dimension.width(16)),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(Dimension.width(12)),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Dimension.width(20),
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: Dimension.width(12)),
                  Expanded(
                    child: Text(
                      'Cancellation allowed up to 2 hours before booking time',
                      style: TextStyle(
                        fontSize: Dimension.font(12),
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: Dimension.height(100)),
          ],
        ),
      ),

      // Confirm Button
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
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFF00C853).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
              ),
              child: _isBooking
                  ? SizedBox(
                      width: Dimension.width(22),
                      height: Dimension.width(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: Dimension.width(22)),
                        SizedBox(width: Dimension.width(10)),
                        Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          width: Dimension.width(40),
          height: Dimension.width(40),
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(Dimension.width(10)),
          ),
          child: Icon(
            icon,
            size: Dimension.width(20),
            color: isHighlighted ? Colors.green[700] : Colors.grey[700],
          ),
        ),
        SizedBox(width: Dimension.width(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Dimension.font(12),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimension.height(2)),
              Text(
                value,
                style: TextStyle(
                  fontSize: Dimension.font(15),
                  fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                  color: isHighlighted ? Colors.green[700] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
