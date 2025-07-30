import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xff1A8931),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_sharp, color: Colors.white, size: 40),
                  Text(
                    'Nearby',
                    style: TextStyle(color: Color(0xff98CC9E), fontSize: 14),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/home/trending');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xffB65938),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    Text(
                      'Trending',
                      style: TextStyle(color: Color(0xff98CC9E), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xff0F7687),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_filled, color: Colors.white, size: 40),
                  Text(
                    'Indoor',
                    style: TextStyle(color: Color(0xff98CC9E), fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xff17861D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.all_inbox_sharp, color: Colors.white, size: 40),
                  Text(
                    'All Venues',
                    style: TextStyle(color: Color(0xff98CC9E), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
