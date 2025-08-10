// Example integration file showing how to use the API services in your StudySpaces app

import 'package:flutter/material.dart';
import '../services/studyspaces_api_service.dart';
import '../models/space.dart';
import '../models/profile.dart';

/// Example widget showing how to integrate API calls
class ApiIntegrationExample extends StatefulWidget {
  const ApiIntegrationExample({super.key});

  @override
  State<ApiIntegrationExample> createState() => _ApiIntegrationExampleState();
}

class _ApiIntegrationExampleState extends State<ApiIntegrationExample> {
  final StudySpacesApiService _apiService = StudySpacesApiService();
  bool _isLoading = false;
  List<Space> _spaces = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _apiService.initialize();
  }

  // =============================================================================
  // EXAMPLE 1: FETCH SPACES FROM API
  // =============================================================================

  Future<void> _fetchSpacesFromApi() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching spaces...';
    });

    try {
      final spaces = await _apiService.getSpaces();
      setState(() {
        _spaces = spaces;
        _statusMessage = 'Loaded ${spaces.length} spaces from API';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching spaces: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================================
  // EXAMPLE 2: SUBMIT FULLNESS REPORT TO API
  // =============================================================================

  Future<void> _submitFullnessReport(String spaceId, int fullness) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Submitting fullness report...';
    });

    try {
      final success = await _apiService.submitFullnessReport(
        spaceId: spaceId,
        fullness: fullness,
        latitude: 42.4477741, // Example coordinates (Olin Library)
        longitude: -76.4841596,
      );

      setState(() {
        _statusMessage = success
            ? 'Fullness report submitted successfully!'
            : 'Failed to submit fullness report';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error submitting report: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================================
  // EXAMPLE 3: UPDATE USER PROFILE
  // =============================================================================

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating profile...';
    });

    try {
      // Create a sample profile update
      final profile = Profile(
        id: 'user123',
        reports: [5, 8, 12, 6],
        rank: [15, 12, 8, 10],
        favorites: ['olin', 'mann'],
        selectedFilters: ['24/7', 'Printers'],
      );

      final success = await _apiService.updateUserProfile(profile);

      setState(() {
        _statusMessage = success
            ? 'Profile updated successfully!'
            : 'Failed to update profile';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================================
  // EXAMPLE 4: FETCH LEADERBOARD DATA
  // =============================================================================

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching leaderboard...';
    });

    try {
      final leaderboard = await _apiService.getLeaderboard(
        period: 'weekly',
        limit: 10,
      );

      setState(() {
        _statusMessage =
            'Loaded leaderboard with ${leaderboard.length} entries';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching leaderboard: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage.isEmpty
                    ? 'Ready to test API calls'
                    : _statusMessage,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Example buttons
                  ElevatedButton(
                    onPressed: _fetchSpacesFromApi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Fetch Spaces from API'),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () => _submitFullnessReport('olin', 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit Fullness Report'),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update User Profile'),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _fetchLeaderboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Fetch Leaderboard'),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Spaces list
            if (_spaces.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fetched Spaces:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _spaces.length,
                        itemBuilder: (context, index) {
                          final space = _spaces[index];
                          return Card(
                            child: ListTile(
                              title: Text(space.name),
                              subtitle: Text(space.category),
                              trailing: Text('${space.capacity} people'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// INTEGRATION INTO EXISTING SPACES_UTILS.dart
// =============================================================================

/// Example of how to modify your existing SpacesUtils to use API calls
class SpacesUtilsWithApi {
  static final StudySpacesApiService _apiService = StudySpacesApiService();

  /// Updated method to fetch spaces from API instead of local JSON
  static Future<List<Space>> getSpacesFromApi() async {
    try {
      return await _apiService.getSpaces();
    } catch (e) {
      // Fallback to local data if API fails
      debugPrint('API failed, falling back to local data: $e');
      return getSpacesFromLocalData(); // Your existing method
    }
  }

  /// Updated method to submit fullness report to API
  static Future<bool> updateSpaceFullnessApi(
    String spaceId,
    int fullness, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      return await _apiService.submitFullnessReport(
        spaceId: spaceId,
        fullness: fullness,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
      );
    } catch (e) {
      debugPrint('Failed to update fullness via API: $e');
      return false;
    }
  }

  /// Placeholder for your existing local data method
  static List<Space> getSpacesFromLocalData() {
    // Your existing implementation
    return [];
  }
}

// =============================================================================
// INTEGRATION INTO EXISTING HOME_SCREEN.dart
// =============================================================================

/// Example of how to modify your existing home screen to use API data
class HomeScreenWithApi extends StatefulWidget {
  const HomeScreenWithApi({super.key});

  @override
  State<HomeScreenWithApi> createState() => _HomeScreenWithApiState();
}

class _HomeScreenWithApiState extends State<HomeScreenWithApi> {
  final StudySpacesApiService _apiService = StudySpacesApiService();
  List<Space> spaces = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService.initialize();
    _loadSpaces();
  }

  /// Load spaces from API with fallback to local data
  Future<void> _loadSpaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Try to fetch from API first
      final apiSpaces = await _apiService.getSpaces();
      setState(() {
        spaces = apiSpaces;
      });
    } catch (e) {
      debugPrint('API failed, using local data: $e');
      // Fallback to your existing local data loading
      _loadLocalSpaces();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Your existing local data loading method
  void _loadLocalSpaces() {
    // Your existing implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Spaces')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                final space = spaces[index];
                return ListTile(
                  title: Text(space.name),
                  subtitle: Text(space.category),
                );
              },
            ),
    );
  }
}
