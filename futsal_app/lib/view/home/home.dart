import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/view/bookings/bookings.dart';
import 'package:ui/view/favorite/favorite.dart';
import 'package:ui/view/profile/profile.dart';
import 'dart:ui';
import 'home_screen.dart';
import '../../core/dimension.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<_NavData> _items = const [
    _NavData(
      label: 'Home',
      assetPath: 'assets/icons/home.png',
      selectedAssetPath: 'assets/icons/selected_home.png',
    ),
    _NavData(
      label: 'Favorite',
      assetPath: 'assets/icons/favorite.png',
      selectedAssetPath: 'assets/icons/selected_favorite.png',
    ),
    _NavData(
      label: 'Booking',
      assetPath: 'assets/icons/booking.png',
      selectedAssetPath: 'assets/icons/selected_booking.png',
    ),
    _NavData(
      label: 'Profile',
      assetPath: 'assets/icons/profile.png',
      selectedAssetPath: 'assets/icons/selected_profile.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),
            child: BottomNavigationBar(
              selectedFontSize: Dimension.font(12),
              unselectedFontSize: Dimension.font(12),
              backgroundColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.backgroundColor,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: _items.map((e) {
                return BottomNavigationBarItem(
                  icon: Image.asset(
                    e.assetPath,
                    color: Theme.of(
                      context,
                    ).bottomNavigationBarTheme.unselectedItemColor,
                    width: Dimension.width(16),
                    height: Dimension.width(16),
                  ),
                  activeIcon: Image.asset(
                    e.selectedAssetPath ?? e.assetPath,
                    color: Theme.of(
                      context,
                    ).bottomNavigationBarTheme.selectedItemColor,
                    width: Dimension.width(16),
                    height: Dimension.width(16),
                  ),
                  label: e.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final screens = [HomeScreen(), Favorite(), BookingsScreen(), Profile()];

    if (_currentIndex >= 0 && _currentIndex < screens.length) {
      return screens[_currentIndex];
    }

    return Center(
      child: Text(
        _items[_currentIndex].label,
        style: TextStyle(
          fontSize: Dimension.font(16),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NavData {
  final String label;
  final String assetPath;
  final String? selectedAssetPath;
  const _NavData({
    required this.label,
    required this.assetPath,
    this.selectedAssetPath,
  });
}
