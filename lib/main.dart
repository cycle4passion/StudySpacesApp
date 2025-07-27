import 'package:flutter/material.dart';
import 'screens/library_list_screen.dart';

void main() {
  runApp(const StudySpacesApp());
}

class StudySpacesApp extends StatelessWidget {
  const StudySpacesApp({super.key});

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
      ),
      home: const LibraryListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
