import 'package:flutter/material.dart';
import 'package:ui/view/favorite/favorite.dart';
import 'package:ui/view/profile/profile.dart';
import 'dart:ui';
import 'home_screen.dart';
import '../../core/dimension.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<_NavData> _items = const [
    _NavData(label: 'Home', assetPath: 'assets/icons/home.png'),
    _NavData(label: 'Favorite', assetPath: 'assets/icons/favorite.png'),
    _NavData(label: 'Profile', assetPath: 'assets/icons/profile.png'),
  ];

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentIndex == 0
          ? const HomeScreen()
          : _currentIndex == 1
          ? Favorite()
          : _currentIndex == 2
          ? Profile()
          : Center(
              child: Text(
                _items[_currentIndex].label,
                style: TextStyle(
                  fontSize: Dimension.font(24),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      bottomNavigationBar: _BottomNavBar(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavData {
  final String label;
  final String assetPath;
  const _NavData({required this.label, required this.assetPath});
}

class _BottomNavBar extends StatelessWidget {
  final List<_NavData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          // The bar itself
          Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimension.height(10),
              horizontal: Dimension.width(10),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                final selected = index == currentIndex;
                final item = items[index];
                return _NavItem(
                  label: item.label,
                  assetPath: item.assetPath,
                  selected: selected,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
          // Top-only soft shadow as gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: Dimension.height(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseWidth = Dimension.width(56);
    final expandedWidth = Dimension.width(140);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: selected ? expandedWidth : baseWidth,
      height: Dimension.height(56),
      decoration: BoxDecoration(
        color: selected ? Colors.black.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimension.width(18)),
        border: Border.all(
          color: Colors.black.withOpacity(selected ? 0.10 : 0.05),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimension.width(18)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimension.width(14)),
          child: Row(
            mainAxisAlignment: selected
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: Dimension.width(22),
                height: Dimension.width(22),
                color: Colors.black,
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: selected
                    ? Padding(
                        key: const ValueKey('label'),
                        padding: EdgeInsets.only(left: Dimension.width(10)),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: Dimension.font(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
