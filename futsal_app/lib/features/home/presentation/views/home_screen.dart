import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/presentation/widgets/search_box.dart';
import 'package:futsalpay/features/home/presentation/widgets/tabs.dart';
import 'package:futsalpay/features/home/presentation/widgets/top_bar.dart';
import 'package:futsalpay/features/home/presentation/widgets/venues.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: const Color(0xff03340d).withOpacity(0.6),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
        child: Column(
          children: [
            SizedBox(height: Dimension.height(40)),
            const TopBar(),
            SizedBox(height: Dimension.height(20)),
            SearchBox(),
            SizedBox(height: Dimension.height(20)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Futsal Venues',
                style: TextStyle(
                  color: Color(0xff91A693),
                  fontSize: Dimension.font(14),
                ),
              ),
            ),
            SizedBox(height: Dimension.height(10)),
            const Expanded(child: Venues()),
            const Tabs(),
            SizedBox(height: Dimension.height(100)),
          ],
        ),
      ),
    );
  }
}
