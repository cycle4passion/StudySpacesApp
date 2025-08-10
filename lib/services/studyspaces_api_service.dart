import 'package:flutter/foundation.dart';
import '../models/space.dart';
import '../models/profile.dart';
import 'api_service.dart';

/// StudySpaces specific API service
/// This class provides methods for interacting with the StudySpaces backend API
class StudySpacesApiService {
  static final StudySpacesApiService _instance =
      StudySpacesApiService._internal();
  factory StudySpacesApiService() => _instance;
  StudySpacesApiService._internal();

  final ApiService _apiService = ApiService();

  /// Initialize the service
  void initialize() {
    _apiService.initialize();
  }

  // =============================================================================
  // SPACES API ENDPOINTS
  // =============================================================================

  /// Fetch all study spaces
  Future<List<Space>> getSpaces() async {
    try {
      final response = await _apiService.get('/api/spaces');

      if (response.data != null) {
        final List<dynamic> spacesJson = response.data['spaces'] ?? [];
        return spacesJson.map((json) => Space.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching spaces: $e');
      rethrow;
    }
  }

  /// Fetch a specific space by ID
  Future<Space?> getSpace(String spaceId) async {
    try {
      final response = await _apiService.get('/api/spaces/$spaceId');

      if (response.data != null) {
        return Space.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching space $spaceId: $e');
      rethrow;
    }
  }

  /// Search spaces by query
  Future<List<Space>> searchSpaces(String query) async {
    try {
      final response = await _apiService.get(
        '/api/spaces/search',
        queryParameters: {'q': query},
      );

      if (response.data != null) {
        final List<dynamic> spacesJson = response.data['spaces'] ?? [];
        return spacesJson.map((json) => Space.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error searching spaces: $e');
      rethrow;
    }
  }

  // =============================================================================
  // FULLNESS REPORTING API ENDPOINTS
  // =============================================================================

  /// Submit a fullness report for a space
  Future<bool> submitFullnessReport({
    required String spaceId,
    required int fullness,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/spaces/$spaceId/fullness',
        data: {
          'fullness': fullness,
          'location': {'latitude': latitude, 'longitude': longitude},
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting fullness report: $e');
      rethrow;
    }
  }

  /// Get current fullness data for all spaces
  Future<Map<String, int>> getFullnessData() async {
    try {
      final response = await _apiService.get('/api/fullness');

      if (response.data != null) {
        final Map<String, dynamic> fullnessData = response.data;
        return fullnessData.map((key, value) => MapEntry(key, value as int));
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching fullness data: $e');
      rethrow;
    }
  }

  /// Get fullness history for a specific space
  Future<List<Map<String, dynamic>>> getFullnessHistory(String spaceId) async {
    try {
      final response = await _apiService.get(
        '/api/spaces/$spaceId/fullness/history',
      );

      if (response.data != null) {
        return List<Map<String, dynamic>>.from(response.data['history'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching fullness history: $e');
      rethrow;
    }
  }

  // =============================================================================
  // USER PROFILE API ENDPOINTS
  // =============================================================================

  /// Get user profile
  Future<Profile?> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/api/users/$userId/profile');

      if (response.data != null) {
        return Profile.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Profile profile) async {
    try {
      final response = await _apiService.put(
        '/api/users/${profile.id}/profile',
        data: profile.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update user's favorite spaces
  Future<bool> updateFavoriteSpaces(
    String userId,
    List<String> favoriteSpaces,
  ) async {
    try {
      final response = await _apiService.put(
        '/api/users/$userId/favorites',
        data: {'favoriteSpaces': favoriteSpaces},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating favorite spaces: $e');
      rethrow;
    }
  }

  /// Update user's selected filters
  Future<bool> updateSelectedFilters(
    String userId,
    List<String> selectedFilters,
  ) async {
    try {
      final response = await _apiService.put(
        '/api/users/$userId/filters',
        data: {'selectedFilters': selectedFilters},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating selected filters: $e');
      rethrow;
    }
  }

  // =============================================================================
  // LEADERBOARD API ENDPOINTS
  // =============================================================================

  /// Get leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String period = 'all-time',
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/leaderboard',
        queryParameters: {'period': period, 'limit': limit},
      );

      if (response.data != null) {
        return List<Map<String, dynamic>>.from(
          response.data['leaderboard'] ?? [],
        );
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      rethrow;
    }
  }

  /// Get user's rank in leaderboard
  Future<Map<String, dynamic>?> getUserRank(
    String userId, {
    String period = 'all-time',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/users/$userId/rank',
        queryParameters: {'period': period},
      );

      if (response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user rank: $e');
      rethrow;
    }
  }

  // =============================================================================
  // SPACE SUGGESTIONS API ENDPOINTS
  // =============================================================================

  /// Submit a new space suggestion
  Future<bool> submitSpaceSuggestion({
    required String name,
    required String address,
    String? otherInfo,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/spaces/suggestions',
        data: {
          'name': name,
          'address': address,
          'otherInfo': otherInfo,
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting space suggestion: $e');
      rethrow;
    }
  }

  // =============================================================================
  // AUTHENTICATION API ENDPOINTS (if needed)
  // =============================================================================

  /// Login user
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data != null && response.data['token'] != null) {
        // Store the token
        await _apiService.setAuthToken(response.data['token']);
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      if (response.data != null && response.data['token'] != null) {
        // Store the token
        await _apiService.setAuthToken(response.data['token']);
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      await _apiService.post('/api/auth/logout');
      await _apiService.clearAuthToken();
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Clear token anyway
      await _apiService.clearAuthToken();
      return false;
    }
  }

  // =============================================================================
  // FILTERS API ENDPOINTS
  // =============================================================================

  /// Get available filters for a location
  Future<List<String>> getAvailableFilters({
    String location = 'cornell',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/locations/$location/filters',
      );

      if (response.data != null) {
        return List<String>.from(response.data['filters'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching available filters: $e');
      rethrow;
    }
  }
}
