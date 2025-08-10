import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/profile_utils.dart';

void main() {
  runApp(const StudySpacesApp());
}

class StudySpacesApp extends StatefulWidget {
  const StudySpacesApp({super.key});

  @override
  State<StudySpacesApp> createState() => _StudySpacesAppState();
}

class _StudySpacesAppState extends State<StudySpacesApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = _getProfileDarkMode();
  }

  bool _getProfileDarkMode() {
    try {
      return ProfileUtils.getDarkMode();
    } catch (_) {
      return false;
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      ProfileUtils.setDarkMode(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySpaces',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        // Let Material 3 handle text colors automatically for better contrast
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: const CardThemeData(
          elevation: 4,
          color: Color(0xFF2D2D2D), // Custom grey background for dark mode
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        // Let Material 3 handle text colors automatically for better contrast
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
