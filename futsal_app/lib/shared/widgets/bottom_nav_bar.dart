import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  final Widget child;
  const BottomNavBar({super.key, required this.child});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static const tabs = ['/home', '/favorites', '/bookings', '/profile'];

  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((path) => location.startsWith(path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _locationToTabIndex(location);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          height: Dimension.height(65),
          padding: EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: Color(0xff03340d),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.center,
            child: BottomNavigationBar(
              elevation: 100,
              backgroundColor: Colors.transparent,
              selectedItemColor: Color(0xff1a8931),
              unselectedItemColor: Colors.white,
              iconSize: Dimension.height(30),
              unselectedLabelStyle: TextStyle(fontSize: Dimension.font(14)),
              selectedLabelStyle: TextStyle(fontSize: Dimension.font(14)),
              currentIndex: currentIndex,
              onTap: (index) {
                if (index != currentIndex) {
                  context.go(tabs[index]);
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.article_outlined),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }
}
