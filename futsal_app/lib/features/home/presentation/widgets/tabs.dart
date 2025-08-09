import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:go_router/go_router.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Column(
      children: [
        SizedBox(height: Dimension.height(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(15),
                vertical: Dimension.height(6),
              ),
              decoration: BoxDecoration(
                color: Color(0xff1A8931),
                borderRadius: BorderRadius.circular(Dimension.width(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_sharp,
                    color: Colors.white,
                    size: Dimension.font(30),
                  ),
                  Text(
                    'Nearby',
                    style: TextStyle(
                      color: Color(0xff98CC9E),
                      fontSize: Dimension.font(12),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/home/trending');
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(10),
                  vertical: Dimension.height(6),
                ),
                decoration: BoxDecoration(
                  color: Color(0xffB65938),
                  borderRadius: BorderRadius.circular(Dimension.width(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: Dimension.font(30),
                    ),
                    Text(
                      'Trending',
                      style: TextStyle(
                        color: Color(0xff98CC9E),
                        fontSize: Dimension.font(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(18),
                vertical: Dimension.height(6),
              ),
              decoration: BoxDecoration(
                color: Color(0xff0F7687),
                borderRadius: BorderRadius.circular(Dimension.width(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_filled,
                    color: Colors.white,
                    size: Dimension.font(30),
                  ),
                  Text(
                    'Indoor',
                    style: TextStyle(
                      color: Color(0xff98CC9E),
                      fontSize: Dimension.font(12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimension.width(10),
                vertical: Dimension.height(6),
              ),
              decoration: BoxDecoration(
                color: Color(0xff17861D),
                borderRadius: BorderRadius.circular(Dimension.width(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.all_inbox_sharp,
                    color: Colors.white,
                    size: Dimension.font(30),
                  ),
                  Text(
                    'All Venues',
                    style: TextStyle(
                      color: Color(0xff98CC9E),
                      fontSize: Dimension.font(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
