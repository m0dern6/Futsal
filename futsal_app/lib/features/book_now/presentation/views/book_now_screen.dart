import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/book_now/presentation/bloc/booking_bloc.dart';
import 'package:futsalpay/features/book_now/presentation/widgets/timeline_slot_picker.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';

class BookNowScreen extends StatefulWidget {
  final dynamic ground;
  const BookNowScreen({super.key, this.ground});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  int selectedDateIndex = 0;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool isBookingInProgress = false; // Add this to prevent double booking

  // Get opening and closing hours from ground data
  TimeOfDay _getOpeningHour() {
    try {
      return widget.ground?.openingHour ?? const TimeOfDay(hour: 6, minute: 0);
    } catch (e) {
      return const TimeOfDay(hour: 6, minute: 0); // Default 6 AM
    }
  }

  TimeOfDay _getClosingHour() {
    try {
      return widget.ground?.closingHour ?? const TimeOfDay(hour: 20, minute: 0);
    } catch (e) {
      return const TimeOfDay(hour: 20, minute: 0); // Default 8 PM
    }
  }

  List<TimeOfDay> _getBookedSlots() {
    try {
      return widget.ground?.bookedSlots?.cast<TimeOfDay>() ?? [];
    } catch (e) {
      return []; // Default empty list
    }
  }

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
                    TimelineSlotPicker(
                      openingTime: _getOpeningHour(),
                      closingTime: _getClosingHour(),
                      bookedSlots: _getBookedSlots(),
                      onError: (msg) {
                        final cs = Theme.of(context).colorScheme;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: cs.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onSlotsSelected: (startSlot, endSlot) {
                        setState(() {
                          selectedStartTime = startSlot.time;
                          selectedEndTime = endSlot.time;
                        });
                      },
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
                  onPressed: () {
                    if (_validateSelectionOrNotify(context)) {
                      _showBookingConfirmation(context);
                    }
                  },
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
    if (selectedStartTime == null || selectedEndTime == null) return 0;

    int startMinutes = selectedStartTime!.hour * 60 + selectedStartTime!.minute;
    int endMinutes = selectedEndTime!.hour * 60 + selectedEndTime!.minute;

    // Handle case where end time might be less than start time (next day)
    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours
    }

    return ((endMinutes - startMinutes) / 60).ceil();
  }

  bool _validateSelectionOrNotify(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (selectedStartTime == null || selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a start and end time.'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Duration must be 1 or 2 hours only
    final duration = _calculateDuration();
    if (duration < 1 || duration > 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select 1 or 2 hours maximum.'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Prevent overlap with booked slots
    final booked = _getBookedSlots();
    // Iterate each 1-hour segment between [start, end)
    int startMinutes = selectedStartTime!.hour * 60 + selectedStartTime!.minute;
    int endMinutes = selectedEndTime!.hour * 60 + selectedEndTime!.minute;
    if (endMinutes <= startMinutes) endMinutes += 24 * 60; // normalize

    for (int m = startMinutes; m < endMinutes; m += 60) {
      final t = TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
      if (booked.any((b) => b.hour == t.hour && b.minute == t.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Selected time overlaps an already booked slot.',
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }

    return true;
  }

  Widget _buildQuickTimeButton(String label, int duration) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        if (selectedStartTime != null) {
          setState(() {
            final startMinutes =
                selectedStartTime!.hour * 60 + selectedStartTime!.minute;
            final endMinutes = startMinutes + (duration * 60);
            selectedEndTime = TimeOfDay(
              hour: (endMinutes ~/ 60) % 24,
              minute: endMinutes % 60,
            );
          });
        }
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
    if (selectedStartTime == null || selectedEndTime == null) return;

    final startTime = _formatTimeOfDay(selectedStartTime!);
    final endTime = _formatTimeOfDay(selectedEndTime!);
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
            startTime: _convertTo24HourFormat(selectedStartTime!),
            endTime: _convertTo24HourFormat(selectedEndTime!),
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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _convertTo24HourFormat(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }
}
