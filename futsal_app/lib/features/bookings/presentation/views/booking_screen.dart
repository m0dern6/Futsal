import 'package:flutter/material.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/booking_tab.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1C0D2E),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Bookings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              BookingTab(),
            ],
          ),
        ),
      ),
    );
  }
}
