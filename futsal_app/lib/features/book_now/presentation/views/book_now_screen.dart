import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/book_now/presentation/bloc/booking_bloc.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';

class BookNowScreen extends StatefulWidget {
  final dynamic ground;
  const BookNowScreen({super.key, this.ground});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  int selectedDateIndex = 0;
  int selectedStartTimeIndex = 0;
  int selectedEndTimeIndex = 1;
  bool isBookingInProgress = false; // Add this to prevent double booking
  final List<String> times = [
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
  ];

  // Helper methods to safely extract properties from dynamic ground object
  String _getGroundName() {
    try {
      return widget.ground?.name?.toString() ?? 'ByteWise Futsal';
    } catch (e) {
      return 'ByteWise Futsal';
    }
  }

  int _getGroundId() {
    try {
      final groundId = widget.ground?.id as int?;
      if (groundId == null || groundId == 0) {
        throw Exception('Invalid ground ID: Ground not properly loaded');
      }
      return groundId;
    } catch (e) {
      throw Exception('Failed to get ground ID: $e');
    }
  }

  int _getPricePerHour() {
    try {
      return widget.ground?.pricePerHour as int? ?? 1000;
    } catch (e) {
      return 1000;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive dimensions
    Dimension.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final today = DateTime.now();
    final List<DateTime> weekDates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimension.width(18), // was 24
            vertical: Dimension.height(10), // was 16
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimension.height(6)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Select a Date',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: Dimension.font(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimension.height(8)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(weekDates.length, (index) {
                    final isSelected = selectedDateIndex == index;
                    final date = weekDates[index];
                    final dayName = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][date.weekday - 1];
                    return Padding(
                      padding: EdgeInsets.only(right: Dimension.width(10)),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedDateIndex = index),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimension.width(12),
                                vertical: Dimension.height(6),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  Dimension.width(12),
                                ),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimension.font(16),
                                ),
                              ),
                            ),
                            SizedBox(height: Dimension.height(2)),
                            Text(
                              dayName,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: Dimension.font(11.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: Dimension.height(20)),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimension.width(14)),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GROUND',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: Dimension.font(10),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: Dimension.height(5)),
                          Text(
                            _getGroundName(),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: Dimension.font(16.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Dimension.height(5)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: colorScheme.onSurface.withOpacity(0.6),
                                size: Dimension.width(13),
                              ),
                              SizedBox(width: Dimension.width(3)),
                              Text(
                                '123 Example St',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: Dimension.font(10.5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimension.height(2)),
                          Row(
                            children: [
                              Text(
                                'Rs.',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: Dimension.font(10.5),
                                ),
                              ),
                              SizedBox(width: Dimension.width(3)),
                              Text(
                                '${_getPricePerHour()} / hour',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: Dimension.font(10.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/logo/inapplogo1.png',
                          width: Dimension.width(54),
                          height: Dimension.width(54),
                        ),
                        SizedBox(height: Dimension.height(5)),
                        Text(
                          'BOOKSAL',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimension.font(10.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimension.height(20)),

              // Time Selection Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimension.width(14)),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT TIME SLOT',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: Dimension.font(10),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimension.height(12)),

                    // Start and End Time Row
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: Dimension.font(11.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Dimension.height(5)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: colorScheme.surface,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (ctx) => Container(
                                      height: Dimension.height(210),
                                      padding: EdgeInsets.all(
                                        Dimension.width(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: Dimension.width(28),
                                            height: Dimension.height(3),
                                            decoration: BoxDecoration(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimension.width(1.5),
                                                  ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimension.height(10),
                                          ),
                                          Text(
                                            'Select Start Time',
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontSize: Dimension.font(13.5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimension.height(10),
                                          ),
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode:
                                                  CupertinoDatePickerMode.time,
                                              initialDateTime: DateTime(
                                                today.year,
                                                today.month,
                                                today.day,
                                                12 + selectedStartTimeIndex,
                                              ),
                                              use24hFormat: false,
                                              onDateTimeChanged: (date) {
                                                setState(() {
                                                  selectedStartTimeIndex =
                                                      date.hour >= 12
                                                      ? date.hour - 12
                                                      : date.hour;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimension.width(16),
                                    vertical: Dimension.height(14),
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(
                                      0.15,
                                    ),
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Dimension.width(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedStartTimeIndex < times.length
                                            ? times[selectedStartTimeIndex]
                                            : '${12 + selectedStartTimeIndex}:00 PM',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: Dimension.font(12),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: colorScheme.primary,
                                        size: Dimension.width(14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Separator
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: Dimension.width(10),
                            vertical: Dimension.height(5),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: colorScheme.onSurface.withOpacity(0.6),
                            size: Dimension.width(16),
                          ),
                        ),

                        // End Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: Dimension.font(11.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Dimension.height(5)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: colorScheme.surface,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (ctx) => Container(
                                      height: Dimension.height(210),
                                      padding: EdgeInsets.all(
                                        Dimension.width(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: Dimension.width(28),
                                            height: Dimension.height(3),
                                            decoration: BoxDecoration(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimension.width(1.5),
                                                  ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimension.height(10),
                                          ),
                                          Text(
                                            'Select End Time',
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontSize: Dimension.font(13.5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimension.height(10),
                                          ),
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode:
                                                  CupertinoDatePickerMode.time,
                                              initialDateTime: DateTime(
                                                today.year,
                                                today.month,
                                                today.day,
                                                12 + selectedEndTimeIndex,
                                              ),
                                              use24hFormat: false,
                                              onDateTimeChanged: (date) {
                                                setState(() {
                                                  selectedEndTimeIndex =
                                                      date.hour >= 12
                                                      ? date.hour - 12
                                                      : date.hour;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimension.width(16),
                                    vertical: Dimension.height(14),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF7CFF6B,
                                    ).withOpacity(0.15),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF7CFF6B,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Dimension.width(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedEndTimeIndex < times.length
                                            ? times[selectedEndTimeIndex]
                                            : '${12 + selectedEndTimeIndex}:00 PM',
                                        style: TextStyle(
                                          color: const Color(0xFF7CFF6B),
                                          fontSize: Dimension.font(12),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: const Color(0xFF7CFF6B),
                                        size: Dimension.width(14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimension.height(12)),

                    // Duration Display
                    Container(
                      padding: EdgeInsets.all(Dimension.width(10)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(Dimension.width(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white70,
                            size: Dimension.width(13),
                          ),
                          SizedBox(width: Dimension.width(7)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Dimension.font(9),
                                ),
                              ),
                              SizedBox(height: Dimension.height(1)),
                              Text(
                                '${_calculateDuration()} hour${_calculateDuration() > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Dimension.font(12),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Cost',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Dimension.font(9),
                                ),
                              ),
                              SizedBox(height: Dimension.height(1)),
                              Text(
                                '\Rs.${_calculateDuration() * _getPricePerHour()}',
                                style: TextStyle(
                                  color: const Color(0xFF7CFF6B),
                                  fontSize: Dimension.font(13),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimension.height(16)),

                    // Quick Time Options
                    Text(
                      'Quick Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimension.font(10.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Dimension.height(5)),
                    Wrap(
                      spacing: Dimension.width(5),
                      runSpacing: Dimension.height(5),
                      children: [
                        _buildQuickTimeButton('1 Hour', 1),
                        _buildQuickTimeButton('2 Hours', 2),
                        _buildQuickTimeButton('3 Hours', 3),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimension.height(18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                    ),
                  ),
                  onPressed: () => _showBookingConfirmation(context),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: Dimension.font(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimension.height(7)),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateDuration() {
    int startHour = selectedStartTimeIndex;
    int endHour = selectedEndTimeIndex;

    // Handle case where end time might be less than start time
    if (endHour <= startHour) {
      endHour += times.length;
    }

    return endHour - startHour;
  }

  Widget _buildQuickTimeButton(String label, int duration) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEndTimeIndex =
              (selectedStartTimeIndex + duration) % times.length;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(10),
          vertical: Dimension.height(5),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Dimension.width(14)),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontSize: Dimension.font(9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now();
    final selectedDate = DateTime(
      today.year,
      today.month,
      today.day + selectedDateIndex,
    );
    final startTime = times[selectedStartTimeIndex];
    final endTime = times[selectedEndTimeIndex];
    final duration = _calculateDuration();
    final totalCost = (duration * _getPricePerHour()).toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimension.width(16)),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.3),
              width: Dimension.width(1),
            ),
          ),
          title: Text(
            'Confirm Booking',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: Dimension.font(18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Ground:', _getGroundName()),
              SizedBox(height: Dimension.height(8)),
              _buildDetailRow(
                'Date:',
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              SizedBox(height: Dimension.height(8)),
              _buildDetailRow('Time:', '$startTime - $endTime'),
              SizedBox(height: Dimension.height(8)),
              _buildDetailRow(
                'Duration:',
                '$duration hour${duration > 1 ? "s" : ""}',
              ),
              SizedBox(height: Dimension.height(8)),
              _buildDetailRow('Total Cost:', 'Rs. $totalCost'),
              SizedBox(height: Dimension.height(16)),
              Text(
                'Are you sure you want to book this slot?',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: Dimension.font(14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: Dimension.font(14),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBookingInProgress
                    ? colorScheme.primary.withOpacity(0.5)
                    : colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(8)),
                ),
              ),
              onPressed: isBookingInProgress
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      _handleBookingConfirm(
                        context,
                        selectedDate,
                        startTime,
                        endTime,
                        totalCost,
                      );
                    },
              child: Text(
                isBookingInProgress ? 'Booking...' : 'Confirm Booking',
                style: TextStyle(
                  fontSize: Dimension.font(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Dimension.width(80),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: Dimension.font(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: Dimension.font(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleBookingConfirm(
    BuildContext context,
    DateTime date,
    String startTime,
    String endTime,
    int totalCost,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get user info and trigger booking
    final userInfoState = context.read<UserInfoBloc>().state;
    if (userInfoState is UserInfoLoaded) {
      // Prevent double booking
      if (isBookingInProgress) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking already in progress, please wait...'),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        isBookingInProgress = true;
      });

      try {
        final groundId = _getGroundId();
        context.read<BookingBloc>().add(
          CreateBooking(
            userId: userInfoState.userInfo.id,
            groundId: groundId,
            bookingDate: date,
            startTime: _convertTo24HourFormat(startTime),
            endTime: _convertTo24HourFormat(endTime),
          ),
        );
      } catch (e) {
        setState(() {
          isBookingInProgress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Show loading and listen for booking results
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              if (state is BookingSuccess) {
                setState(() {
                  isBookingInProgress = false;
                });
                Navigator.of(dialogContext).pop(); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Navigate back or to bookings page
                Navigator.of(context).pop();
              } else if (state is BookingError) {
                setState(() {
                  isBookingInProgress = false;
                });
                Navigator.of(dialogContext).pop(); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                return AlertDialog(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimension.width(16)),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      SizedBox(height: Dimension.height(16)),
                      Text(
                        'Creating your booking...',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: Dimension.font(16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to make a booking'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _convertTo24HourFormat(String time12Hour) {
    // Convert time format from "12:00 PM" to "12:00:00"
    final parts = time12Hour.split(' ');
    final timePart = parts[0];
    final amPm = parts[1];

    final timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    final minute = timeComponents[1];

    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }
}
