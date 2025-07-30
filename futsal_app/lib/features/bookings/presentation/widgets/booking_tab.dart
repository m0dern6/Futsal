import 'package:flutter/material.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/past.dart';
import 'package:futsalpay/features/bookings/presentation/widgets/upcommings.dart';

class BookingTab extends StatelessWidget {
  const BookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.green, width: 5),
                ),
              ),
              padding: EdgeInsets.only(bottom: 30),
              indicatorWeight: 5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.green, fontSize: 19),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Past',
                    style: TextStyle(color: Colors.green, fontSize: 19),
                  ),
                ),
              ],
            ),
            Expanded(child: TabBarView(children: [Upcommings(), Past()])),
          ],
        ),
      ),
    );
  }
}
