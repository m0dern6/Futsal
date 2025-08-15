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
  static const tabs = ['/home', '/favorites', '/profile'];

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface.withOpacity(.95),
                  theme.colorScheme.surfaceContainerHighest.withOpacity(.98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: Dimension.height(54), // reduced height
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: currentIndex,
                  onTap: (index) {
                    if (index != currentIndex) context.go(tabs[index]);
                  },
                  selectedFontSize: Dimension.font(10.5),
                  unselectedFontSize: Dimension.font(10.0),
                  items: [
                    _buildItem(
                      theme,
                      Icons.home_filled,
                      'Home',
                      0,
                      currentIndex,
                    ),
                    _buildItem(
                      theme,
                      Icons.favorite,
                      'Favorites',
                      1,
                      currentIndex,
                    ),
                    _buildItem(theme, Icons.person, 'Profile', 2, currentIndex),
                  ],
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

BottomNavigationBarItem _buildItem(
  ThemeData theme,
  IconData icon,
  String label,
  int index,
  int current,
) {
  final bool active = index == current;
  return BottomNavigationBarItem(
    icon: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary.withOpacity(.12)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 22,
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(.65),
      ),
    ),
    label: label,
  );
}
