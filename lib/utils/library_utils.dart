class LibraryUtils {
  /// Checks if a library is currently open based on openat/closeat arrays
  /// Returns true if open, false if closed
  static bool isOpen(List<int> openat, List<int> closeat) {
    final now = DateTime.now();

    // Get current day of week (0 = Monday, 6 = Sunday)
    int dayIndex = now.weekday - 1; // DateTime.weekday: 1=Monday, 7=Sunday

    // Get current time in military format (e.g., 1430 for 2:30 PM)
    int currentTime = now.hour * 100 + now.minute;

    // Check if arrays are valid and day exists
    if (dayIndex < 0 ||
        dayIndex >= openat.length ||
        dayIndex >= closeat.length) {
      return false;
    }

    int openTime = openat[dayIndex];
    int closeTime = closeat[dayIndex];

    // If either time is 0, the library is closed that day
    if (openTime == 0 || closeTime == 0) {
      return false;
    }

    // Handle overnight hours (e.g., open until 2am next day)
    if (closeTime < openTime) {
      // Library closes after midnight
      // Open if current time is after opening OR before closing (next day)
      return currentTime >= openTime || currentTime <= closeTime;
    } else {
      // Normal hours (same day)
      // Open if current time is between opening and closing
      return currentTime >= openTime && currentTime <= closeTime;
    }
  }

  /// Returns human-readable text for library fullness level
  static String getFullnessText(int fullness) {
    switch (fullness) {
      case 0:
        return 'Empty';
      case 1:
        return 'Very Quiet';
      case 2:
        return 'Light Usage';
      case 3:
        return 'Moderately Busy';
      case 4:
        return 'Quite Busy';
      case 5:
        return 'Very Busy/Full';
      default:
        return 'Unknown';
    }
  }

  /// Calculates weighted average with details for multiple data sources
  static Map<String, dynamic> weightedAverageWithDetails(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) {
      return {'weightedavg': 0.0, 'details': []};
    }

    double weightedSum = 0;
    double totalWeight = 0;
    List<Map<String, dynamic>> details = [];

    for (var item in items) {
      final source = item['source'];
      final values = (item['value'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      double baseWeight = (item['weight'] as num).toDouble();
      double bump = (item['bump'] as num?)?.toDouble() ?? 0.0;
      double itemWeight = baseWeight;

      for (var v in values) {
        if (v > 1 && itemWeight < 1) itemWeight += bump;
      }

      double avg = values.isEmpty
          ? 0
          : values.reduce((a, b) => a + b) / values.length;
      weightedSum += avg * itemWeight;
      totalWeight += itemWeight;
      details.add({'source': source, 'avg': avg});
    }

    double avg = totalWeight == 0
        ? 0
        : (weightedSum / totalWeight).clamp(0, 100);
    return {'weightedavg': avg, 'details': details};
  }

  /// Formats floor count with proper pluralization
  static String formatFloorCount(int floors) {
    return '$floors Floor${floors == 1 ? '' : 's'}';
  }

  /// Formats capacity with label
  static String formatCapacity(int capacity) {
    return 'Capacity $capacity';
  }

  /// Formats openat/closeat arrays into human-readable hours string
  static String formatHours(List<int> openat, List<int> closeat) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> hoursStrings = [];

    for (int i = 0; i < days.length; i++) {
      if (i >= openat.length || i >= closeat.length) continue;

      int open = openat[i];
      int close = closeat[i];

      if (open == 0 || close == 0) {
        hoursStrings.add('${days[i]}: Closed');
      } else {
        String openTime = _formatMilitaryTime(open);
        String closeTime = _formatMilitaryTime(close);
        hoursStrings.add('${days[i]}: $openTime - $closeTime');
      }
    }

    return hoursStrings.join('\n');
  }

  /// Helper function to convert military time to readable format
  static String _formatMilitaryTime(int militaryTime) {
    if (militaryTime == 0) return 'Closed';
    if (militaryTime == 2400) return '12:00 AM';

    int hours = militaryTime ~/ 100;
    int minutes = militaryTime % 100;

    if (hours == 0) {
      return '12:${minutes.toString().padLeft(2, '0')} AM';
    } else if (hours < 12) {
      return '$hours:${minutes.toString().padLeft(2, '0')} AM';
    } else if (hours == 12) {
      return '12:${minutes.toString().padLeft(2, '0')} PM';
    } else {
      return '${hours - 12}:${minutes.toString().padLeft(2, '0')} PM';
    }
  }

  /// Gets the status text for display (e.g., "Closes at 9PM" or "Opens at 8AM")
  static String getStatusText(List<int> openat, List<int> closeat) {
    final now = DateTime.now();
    int dayIndex = now.weekday - 1;

    if (dayIndex < 0 ||
        dayIndex >= openat.length ||
        dayIndex >= closeat.length) {
      return '';
    }

    bool libraryIsOpen = isOpen(openat, closeat);

    if (libraryIsOpen) {
      // Library is open, show when it closes
      int closeTime = closeat[dayIndex];
      if (closeTime == 0) return '';
      return 'Closes at ${_formatMilitaryTime(closeTime)}';
    } else {
      // Library is closed, show when it opens
      int openTime = openat[dayIndex];
      if (openTime == 0) return 'Closed today';
      return 'Opens at ${_formatMilitaryTime(openTime)}';
    }
  }

  /// Gets detailed closed status text with hours until opening
  static String getClosedStatusWithHours(List<int> openat, List<int> closeat) {
    final now = DateTime.now();
    int currentDayIndex = now.weekday - 1;

    // Find the next opening time
    for (int i = 0; i < 7; i++) {
      int dayIndex = (currentDayIndex + i) % 7;

      if (dayIndex >= openat.length || dayIndex >= closeat.length) continue;

      int openTime = openat[dayIndex];
      if (openTime == 0) continue; // Closed this day

      DateTime nextOpen;
      if (i == 0) {
        // Same day - check if opening time hasn't passed yet
        int currentTime = now.hour * 100 + now.minute;
        if (currentTime < openTime) {
          // Opens later today
          int openHour = openTime ~/ 100;
          int openMinute = openTime % 100;
          nextOpen = DateTime(
            now.year,
            now.month,
            now.day,
            openHour,
            openMinute,
          );
        } else {
          // Already passed today's opening time, check next day
          continue;
        }
      } else {
        // Future day
        int openHour = openTime ~/ 100;
        int openMinute = openTime % 100;
        DateTime futureDate = now.add(Duration(days: i));
        nextOpen = DateTime(
          futureDate.year,
          futureDate.month,
          futureDate.day,
          openHour,
          openMinute,
        );
      }

      Duration difference = nextOpen.difference(now);
      int hoursUntilOpen = difference.inHours;

      if (hoursUntilOpen < 1) {
        return 'Currently Closed - Opens in less than 1 hour';
      } else if (hoursUntilOpen == 1) {
        return 'Currently Closed - Opens in about 1 hour';
      } else {
        return 'Currently Closed - Opens in about $hoursUntilOpen hours';
      }
    }

    return 'Currently Closed';
  }

  /// Returns time status text like "Closes in about 2 hrs" or "Opens in about 6 hrs"
  static String getTimeStatusText(List<int> openat, List<int> closeat) {
    final now = DateTime.now();
    int dayIndex = now.weekday - 1;
    int currentTime = now.hour * 100 + now.minute;

    // Check if arrays are valid and day exists
    if (dayIndex < 0 ||
        dayIndex >= openat.length ||
        dayIndex >= closeat.length) {
      return 'Closed';
    }

    int openTime = openat[dayIndex];
    int closeTime = closeat[dayIndex];

    // If either time is 0, the library is closed that day
    if (openTime == 0 || closeTime == 0) {
      // Find next opening day
      for (int i = 1; i <= 7; i++) {
        int nextDayIndex = (dayIndex + i) % 7;
        if (nextDayIndex < openat.length &&
            nextDayIndex < closeat.length &&
            openat[nextDayIndex] != 0 &&
            closeat[nextDayIndex] != 0) {
          // Calculate the exact time until opening
          int openHour = openat[nextDayIndex] ~/ 100;
          int openMinute = openat[nextDayIndex] % 100;
          
          // Create the target opening datetime
          DateTime nextOpenDateTime = DateTime(
            now.year,
            now.month,
            now.day + i,
            openHour,
            openMinute,
          );
          
          // Calculate the difference
          Duration timeUntilOpen = nextOpenDateTime.difference(now);
          int hoursUntilOpen = timeUntilOpen.inHours;
          
          if (hoursUntilOpen < 24) {
            return 'Opens in about ${hoursUntilOpen} hrs';
          } else {
            int days = hoursUntilOpen ~/ 24;
            return 'Opens in ${days} day${days == 1 ? '' : 's'}';
          }
        }
      }
      return 'Closed';
    }

    bool isCurrentlyOpen = isOpen(openat, closeat);

    if (isCurrentlyOpen) {
      // Calculate time until closing
      int closeHour = closeTime ~/ 100;
      int closeMinute = closeTime % 100;

      DateTime closeDateTime;
      if (closeTime < openTime) {
        // Closes after midnight (next day)
        closeDateTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          closeHour,
          closeMinute,
        );
      } else {
        // Closes same day
        closeDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          closeHour,
          closeMinute,
        );
      }

      Duration timeUntilClose = closeDateTime.difference(now);
      int hoursUntilClose = timeUntilClose.inHours;
      int minutesUntilClose = timeUntilClose.inMinutes % 60;

      if (hoursUntilClose < 1) {
        if (minutesUntilClose < 10) {
          return 'Closes soon';
        } else {
          return 'Closes in ${minutesUntilClose} min';
        }
      } else if (hoursUntilClose < 2) {
        return 'Closes in about 1 hr';
      } else {
        return 'Closes in about ${hoursUntilClose} hrs';
      }
    } else {
      // Library is closed, calculate time until opening
      int openHour = openTime ~/ 100;
      int openMinute = openTime % 100;

      DateTime openDateTime;
      
      // Handle different scenarios for overnight schedules
      if (closeTime < openTime) {
        // This is an overnight schedule (e.g., 10am-2am)
        if (currentTime <= closeTime) {
          // We're in the early morning, still part of "yesterday's" session
          // But we should calculate when it opens "today" 
          openDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            openHour,
            openMinute,
          );
        } else if (currentTime >= openTime) {
          // We're after opening time but before closing time - this shouldn't happen as isOpen would be true
          // But just in case, open tomorrow
          openDateTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            openHour,
            openMinute,
          );
        } else {
          // We're between closing time and opening time (e.g., 3am-9am on a 10am-2am schedule)
          openDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            openHour,
            openMinute,
          );
        }
      } else {
        // Normal same-day schedule (e.g., 8am-10pm)
        if (currentTime < openTime) {
          // Before opening time today
          openDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            openHour,
            openMinute,
          );
        } else {
          // After closing time today, opens tomorrow
          openDateTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            openHour,
            openMinute,
          );
        }
      }

      Duration timeUntilOpen = openDateTime.difference(now);
      int hoursUntilOpen = timeUntilOpen.inHours;

      if (hoursUntilOpen < 1) {
        int minutesUntilOpen = timeUntilOpen.inMinutes;
        if (minutesUntilOpen < 10) {
          return 'Opens soon';
        } else {
          return 'Opens in ${minutesUntilOpen} min';
        }
      } else if (hoursUntilOpen < 2) {
        return 'Opens in about 1 hr';
      } else if (hoursUntilOpen < 24) {
        return 'Opens in about ${hoursUntilOpen} hrs';
      } else {
        int days = hoursUntilOpen ~/ 24;
        return 'Opens in ${days} day${days == 1 ? '' : 's'}';
      }
    }
  }
}

/* import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

Future<bool> geofence({
  required double centerLat,
  required double centerLon,
  required double radiusMeters,
}) async {
  // Request permissions
  var permission = await Permission.location.request();
  if (!permission.isGranted) {
    return false;
  }

  // Check if location services are enabled
  if (!await Geolocator.isLocationServiceEnabled()) {
    return false;
  }

  // Get current location
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  double userLat = position.latitude;
  double userLon = position.longitude;

  // Haversine formula
  const R = 6371000; // Earth radius in meters
  double toRadians(double deg) => deg * (pi / 180);

  final dLat = toRadians(userLat - centerLat);
  final dLon = toRadians(userLon - centerLon);

  final a = pow(sin(dLat / 2), 2) +
      cos(toRadians(centerLat)) * cos(toRadians(userLat)) * pow(sin(dLon / 2), 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = R * c;

  return distance <= radiusMeters;
}
 */
