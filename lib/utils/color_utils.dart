import 'package:flutter/material.dart';

class ColorUtils {
  /// Returns appropriate color based on library fullness level
  /// Uses green to red spectrum for intuitive understanding
  static Color getFullnessColor(int fullness) {
    switch (fullness) {
      case 0:
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns appropriate text color for fullness tooltip based on background
  /// Uses a single dark color that provides good contrast on all backgrounds
  static Color getFullnessTextColor(int fullness) {
    // Use black/very dark gray that provides good contrast on all colored backgrounds
    // This works well on yellow, light green, orange, and provides acceptable contrast on green and red
    return Colors
        .black87; // Dark color that works reasonably well on all backgrounds
  }

  /// Returns theme-appropriate card background color
  static Color getCardBackgroundColor(BuildContext context, bool isDarkMode) {
    return isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  }

  /// Returns theme-appropriate text color for titles
  static Color getTitleTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : Colors.black;
  }

  /// Returns theme-appropriate subtitle text color
  static Color getSubtitleTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Returns shadow color based on theme
  static Color getShadowColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.2);
  }
}
