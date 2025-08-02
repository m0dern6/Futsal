import 'package:flutter/material.dart';
import 'package:futsalpay/features/home/presentation/widgets/search_box.dart';
import 'package:futsalpay/features/home/presentation/widgets/tabs.dart';
import 'package:futsalpay/features/home/presentation/widgets/top_bar.dart';
import 'package:futsalpay/features/home/presentation/widgets/venues.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff03340d).withOpacity(0.6),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ), // Reduced padding slightly for better fit
        child: Column(
          children: [
            const SizedBox(height: 40),
            const TopBar(),
            const SizedBox(height: 20),
            SearchBox(), // Will be updated for search functionality
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Futsal Venues',
                style: TextStyle(color: Color(0xff91A693), fontSize: 18),
              ),
            ),
            const SizedBox(height: 10), // Added a small gap
            // 1. Wrap the Venues widget in Expanded to make it fill the remaining space
            const Expanded(child: Venues()),

            // The Tabs widget is now at the bottom
            const Tabs(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
