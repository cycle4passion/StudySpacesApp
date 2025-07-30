class TextUtils {
  /// Converts text to title case (e.g., "hello world" -> "Hello World")
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  /// Capitalizes first letter of text
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Truncates text with ellipsis if it exceeds maxLength
  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Formats hours text for display
  static String formatHours(String hours) {
    // You can add specific formatting logic here if needed
    return hours;
  }
}
