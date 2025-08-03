import 'dart:convert';
import '../data/libraries_data.dart';
import '../models/profile.dart';

class ProfileUtils {
  /// Load profile data from JSON
  static Profile loadProfile() {
    final data = json.decode(profileJson);
    return Profile.fromJson(data['profile']);
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
}
