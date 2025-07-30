import 'package:flutter/material.dart';
import 'package:futsalpay/features/trending/presentation/widgets/top_banner.dart';
import 'package:futsalpay/features/trending/presentation/widgets/trending_list.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              TopBanner(),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trending Venues',
                  style: TextStyle(
                    color: Color(0xffCFCACF),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TrendingList(),
            ],
          ),
        ),
      ),
    );
  }
}
