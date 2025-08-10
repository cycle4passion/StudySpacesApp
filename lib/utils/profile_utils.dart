import 'dart:convert';
import '../data/spaces_data.dart';
import '../models/profile.dart';

class ProfileUtils {
  // In-memory profile data that can be modified
  static Profile? _cachedProfile;

  /// Load profile data from JSON
  static Profile loadProfile() {
    if (_cachedProfile != null) {
      return _cachedProfile!;
    }
    final data = json.decode(profileJson);
    _cachedProfile = Profile.fromJson(data['profile']);
    return _cachedProfile!;
  }

  /// Get user ID
  static String getUserId() {
    final profile = loadProfile();
    return profile.id;
  }

  /// Get favorite spaces
  static List<String> getFavoriteSpaces() {
    final profile = loadProfile();
    return profile.favoriteSpaces;
  }

  /// Update favorite space status
  static void updateFavoriteSpace(String spaceId, bool isFavorite) {
    final profile = loadProfile();
    if (isFavorite && !profile.favoriteSpaces.contains(spaceId)) {
      profile.favoriteSpaces.add(spaceId);
    } else if (!isFavorite && profile.favoriteSpaces.contains(spaceId)) {
      profile.favoriteSpaces.remove(spaceId);
    }
  }

  /// Get time period specific data
  static Map<String, Map<String, int>> getTimePeriodData() {
    final profile = loadProfile();
    return {
      'Daily': {'reports': profile.dailyReports, 'rank': profile.dailyRank},
      'Weekly': {'reports': profile.weeklyReports, 'rank': profile.weeklyRank},
      'Monthly': {
        'reports': profile.monthlyReports,
        'rank': profile.monthlyRank,
      },
      'All-Time': {
        'reports': profile.alltimeReports,
        'rank': profile.alltimeRank,
      },
    };
  }

  /// Get available filters from spaces data
  static List<String> getAvailableFilters() {
    final data = json.decode(spacesJson);
    final filters = data['locations']['cornell']['allfilters'] as List<dynamic>;
    return filters.cast<String>();
  }

  /// Get user's selected filters
  static List<String> getSelectedFilters() {
    final profile = loadProfile();
    return profile.selectedFilters;
  }

  /// Update user's selected filters
  static void updateSelectedFilters(List<String> selectedFilters) {
    final profile = loadProfile();
    // Create a new profile with updated selected filters, preserve darkMode
    _cachedProfile = Profile(
      id: profile.id,
      reports: profile.reports,
      rank: profile.rank,
      favorites: profile.favorites,
      selectedFilters: selectedFilters,
      darkMode: profile.darkMode,
    );
  }

  /// Get dark mode state from profile
  static bool getDarkMode() {
    final profile = loadProfile();
    return profile.darkMode;
  }

  /// Set dark mode state in profile
  static void setDarkMode(bool value) {
    final profile = loadProfile();
    profile.darkMode = value;
    _cachedProfile = profile;
  }
}
