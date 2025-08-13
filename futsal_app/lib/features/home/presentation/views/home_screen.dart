import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/home/presentation/widgets/search_box.dart';
import 'package:futsalpay/features/home/presentation/widgets/tabs.dart';
import 'package:futsalpay/features/home/presentation/widgets/top_bar.dart';
import 'package:futsalpay/features/home/presentation/widgets/venues.dart';
import 'package:futsalpay/features/home/presentation/widgets/trending_venues.dart';
import 'package:futsalpay/features/home/presentation/widgets/top_reviewed_venues.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: const Color(0xff03340d).withOpacity(0.6),
      body: Column(
        children: [
          // Fixed header section (doesn't scroll)
          Container(
            padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
            child: Column(
              children: [
                SizedBox(height: Dimension.height(20)),
                // const TopBar(),
                SizedBox(height: Dimension.height(20)),
                SearchBox(),
              ],
            ),
          ),

          // Scrollable content section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
                child: Column(
                  children: [
                    SizedBox(height: Dimension.height(20)),

                    // Trending Section
                    const TrendingSection(),
                    SizedBox(height: Dimension.height(10)),

                    // Top Review Section
                    const TopReviewSection(),
                    SizedBox(height: Dimension.height(10)),

                    // All Venues Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '  Futsal Venues',
                          style: TextStyle(
                            color: Color(0xff91A693),
                            fontSize: Dimension.font(14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to all venues page
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xff1A8931),
                              fontSize: Dimension.font(12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimension.height(10)),
                    const Venues(),
                    SizedBox(height: Dimension.height(100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
