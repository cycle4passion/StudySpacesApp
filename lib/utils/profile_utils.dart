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

  /// Get profile statistics
  static Map<String, dynamic> getProfileStats() {
    final profile = loadProfile();
    return {
      'totalReports': profile.totalReports,
      'averageReports': profile.averageReports,
      'highestReports': profile.highestReports,
      'lowestReports': profile.lowestReports,
      'reportCount': profile.reports.length,
      'currentRank': profile.currentRank,
      'bestRank': profile.bestRank,
      'worstRank': profile.worstRank,
      'averageRank': profile.averageRank,
      'isRankImproving': profile.isRankImproving,
    };
  }

  /// Get reports history as a list
  static List<int> getReportsHistory() {
    final profile = loadProfile();
    return profile.reports;
  }

  /// Get rank history as a list
  static List<int> getRankHistory() {
    final profile = loadProfile();
    return profile.rank;
  }

  /// Get current rank
  static int getCurrentRank() {
    final profile = loadProfile();
    return profile.currentRank;
  }

  /// Get best rank (lowest number)
  static int getBestRank() {
    final profile = loadProfile();
    return profile.bestRank;
  }

  /// Check if rank is improving
  static bool isRankImproving() {
    final profile = loadProfile();
    return profile.isRankImproving;
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

  /// Check if a space is favorite
  static bool isSpaceFavorite(String spaceId) {
    final profile = loadProfile();
    return profile.isFavorite(spaceId);
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
    final filters = data['locations']['cornell']['allFilters'] as List<dynamic>;
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
    // Create a new profile with updated selected filters
    _cachedProfile = Profile(
      id: profile.id,
      reports: profile.reports,
      rank: profile.rank,
      favorites: profile.favorites,
      selectedFilters: selectedFilters,
    );
  }
}
