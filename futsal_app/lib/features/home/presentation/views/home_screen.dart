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
      backgroundColor: Color(0xff03340d).withOpacity(0.6),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            SizedBox(height: 40),
            TopBar(),
            SizedBox(height: 20),
            SearchBox(),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Futsal Venues',
                style: TextStyle(color: Color(0xff91A693), fontSize: 18),
              ),
            ),
            Venues(),
            SizedBox(height: 20),
            Tabs(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
