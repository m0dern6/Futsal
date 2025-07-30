import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookNowScreen extends StatefulWidget {
  const BookNowScreen({super.key});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;
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
    final today = DateTime.now();
    final List<DateTime> weekDates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Select a Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // const Spacer(),
                  // IconButton(
                  //   icon: const Icon(Icons.calendar_today, color: Colors.white),
                  //   onPressed: () async {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       builder: (ctx) => SizedBox(
                  //         height: 250,
                  //         child: CupertinoDatePicker(
                  //           mode: CupertinoDatePickerMode.date,
                  //           initialDateTime: weekDates[selectedDateIndex],
                  //           minimumDate: today,
                  //           maximumDate: weekDates.last,
                  //           onDateTimeChanged: (date) {
                  //             final idx = weekDates.indexWhere(
                  //               (d) =>
                  //                   d.year == date.year &&
                  //                   d.month == date.month &&
                  //                   d.day == date.day,
                  //             );
                  //             if (idx != -1) {
                  //               setState(() => selectedDateIndex = idx);
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 12),
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
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedDateIndex = index),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7CFF6B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TIMESLOT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'City Futsal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Colors.white54,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '123 Example St',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.attach_money,
                                color: Colors.white54,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '40/hour',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
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
                          width: 75,
                          height: 75,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'BOOKSAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Text(
                    'Select a Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.access_time, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: DateTime(
                              today.year,
                              today.month,
                              today.day,
                              12 +
                                  selectedTimeIndex, // Example: 12:00 PM, 1:00 PM, etc.
                            ),
                            use24hFormat: false,
                            onDateTimeChanged: (date) {
                              // Find the closest time index
                              final hour = date.hour;
                              int idx = hour - 12;
                              if (idx < 0) idx = 0;
                              if (idx >= 4) idx = 3;
                              setState(() => selectedTimeIndex = idx);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                children: List.generate(times.length, (index) {
                  final isSelected = selectedTimeIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTimeIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF7CFF6B)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          times[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CFF6B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
