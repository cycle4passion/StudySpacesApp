import 'package:flutter/material.dart';
import '../models/library.dart';
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
  Library? _preselectedLibrary;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      // Clear preselected library when navigating manually
      if (index != 1) {
        _preselectedLibrary = null;
      }
    });
  }

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _goToReportWithLibrary(Library library) {
    setState(() {
      _preselectedLibrary = library;
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
        onReportPressed: _goToReportWithLibrary, // Pass the new callback
        onTabTapped: _onTabTapped,
        currentIndex: _currentIndex,
      ),
      ReportScreen(
        onHomePressed: _goToHome,
        preSelectedLibrary: _preselectedLibrary,
      ),
      LeaderboardScreen(onHomePressed: _goToHome),
      ProfileScreen(onHomePressed: _goToHome),
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
