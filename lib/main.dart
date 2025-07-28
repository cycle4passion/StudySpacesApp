import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/library_list_screen.dart';

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
  static const String _darkModeKey = 'dark_mode_preference';

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Load the dark mode preference from SharedPreferences
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    });
  }

  // Save the dark mode preference to SharedPreferences
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveDarkModePreference(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySpaces',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // Cornell blue
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
          seedColor: const Color(0xFF1976D2), // Cornell blue
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
      home: LibraryListScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
