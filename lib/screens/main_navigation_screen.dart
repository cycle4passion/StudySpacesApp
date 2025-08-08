import 'package:flutter/material.dart';
import '../models/space.dart';
import 'home_screen.dart';
import 'report_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Space? _preselectedSpace;
  final GlobalKey _leaderboardKey = GlobalKey();

  void _onTabTapped(int index, [String? leaderboardPeriod]) {
    setState(() {
      _currentIndex = index;

      // If navigating to leaderboard with a specific period, update it
      if (index == 2 && leaderboardPeriod != null) {
        // Use a post frame callback to ensure the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final leaderboardState = _leaderboardKey.currentState;
          if (leaderboardState != null) {
            (leaderboardState as dynamic).updatePeriod(leaderboardPeriod);
          }
        });
      }

      // Clear preselected space when navigating manually
      if (index != 1) {
        _preselectedSpace = null;
      }
    });
  }

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _goToReportWithSpace(Space space) {
    setState(() {
      _preselectedSpace = space;
      _currentIndex = 1; // Navigate to report tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onThemeToggle: widget.onThemeToggle,
        isDarkMode: widget.isDarkMode,
        onHomePressed: _goToHome,
        onReportPressed: _goToReportWithSpace, // Pass the new callback
        onTabTapped: _onTabTapped,
        currentIndex: _currentIndex,
      ),
      ReportScreen(
        onHomePressed: _goToHome,
        preSelectedSpace: _preselectedSpace,
      ),
      LeaderboardScreen(
        key: _leaderboardKey,
        onHomePressed: _goToHome,
        onTabTapped: _onTabTapped,
        currentIndex: _currentIndex,
      ),
      ProfileScreen(onHomePressed: _goToHome, onTabTapped: _onTabTapped),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onPrimary.withValues(alpha: 0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Report'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
