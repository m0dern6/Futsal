import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:futsalpay/core/config/dimension.dart';

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
  @override
  Widget build(BuildContext context) {
    // Initialize responsive dimensions
    Dimension.init(context);
    final today = DateTime.now();
    final List<DateTime> weekDates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1B2B),
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
                    onPressed: () {},
                  ),
                  Text(
                    'Select a Date',
                    style: TextStyle(
                      color: Colors.white,
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
                                    ? const Color(0xFF7CFF6B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  Dimension.width(12),
                                ),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimension.font(16),
                                ),
                              ),
                            ),
                            SizedBox(height: Dimension.height(2)),
                            Text(
                              dayName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
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
                  color: Colors.white.withOpacity(0.05),
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
                              color: Colors.white70,
                              fontSize: Dimension.font(10),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: Dimension.height(5)),
                          Text(
                            widget.ground.name ?? 'ByteWise Futsal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Dimension.font(16.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Dimension.height(5)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white54,
                                size: Dimension.width(13),
                              ),
                              SizedBox(width: Dimension.width(3)),
                              Text(
                                '123 Example St',
                                style: TextStyle(
                                  color: Colors.white70,
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
                                  color: Colors.white70,
                                  fontSize: Dimension.font(10.5),
                                ),
                              ),
                              SizedBox(width: Dimension.width(3)),
                              Text(
                                '${widget.ground.pricePerHour} / hour',
                                style: TextStyle(
                                  color: Colors.white70,
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
                            color: Colors.white,
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
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimension.width(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT TIME SLOT',
                      style: TextStyle(
                        color: Colors.white70,
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
                                  color: Colors.white,
                                  fontSize: Dimension.font(11.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Dimension.height(5)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: const Color(0xFF1A2B3D),
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
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
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
                                              color: Colors.white,
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
                                        selectedStartTimeIndex < times.length
                                            ? times[selectedStartTimeIndex]
                                            : '${12 + selectedStartTimeIndex}:00 PM',
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

                        // Separator
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: Dimension.width(10),
                            vertical: Dimension.height(5),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white54,
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
                                  color: Colors.white,
                                  fontSize: Dimension.font(11.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Dimension.height(5)),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: const Color(0xFF1A2B3D),
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
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
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
                                              color: Colors.white,
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
                                '\Rs.${_calculateDuration() * widget.ground.pricePerHour}',
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
                    backgroundColor: const Color(0xFF7CFF6B),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimension.height(18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimension.width(12)),
                    ),
                  ),
                  onPressed: () {},
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
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimension.width(14)),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: Dimension.font(9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
