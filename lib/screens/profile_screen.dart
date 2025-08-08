import 'package:flutter/material.dart';
import '../utils/profile_utils.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onHomePressed;
  final Function(int, [String?])? onTabTapped;

  const ProfileScreen({
    super.key,
    required this.onHomePressed,
    this.onTabTapped,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggedIn = true;
  String? userId;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    if (isLoggedIn) {
      try {
        userId = ProfileUtils.getUserId();
        stats = ProfileUtils.getProfileStats();
      } catch (e) {
        isLoggedIn = false;
        userId = null;
        stats = {};
      }
    }
  }

  void _handleLogin() {
    setState(() {
      isLoggedIn = true;
      _loadProfileData();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged in successfully!')));
  }

  void _handleLogout() {
    setState(() {
      isLoggedIn = false;
      userId = null;
      stats = {};
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully!')));
  }

  void _navigateToLeaderboard(String period) {
    // Navigate to leaderboard tab with the specified period
    if (widget.onTabTapped != null) {
      widget.onTabTapped!(
        2,
        _convertPeriodName(period),
      ); // Index 2 is leaderboard tab
    }
  }

  String _convertPeriodName(String period) {
    // Convert period names to match leaderboard screen format
    switch (period) {
      case 'Daily':
        return 'Day';
      case 'Weekly':
        return 'Week';
      case 'Monthly':
        return 'Month';
      case 'All-Time':
        return 'All Time';
      default:
        return 'Week';
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Profile Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Text(
                  isLoggedIn ? 'User: $userId' : 'Guest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              // Login/Logout Button
              ElevatedButton.icon(
                onPressed: isLoggedIn ? _handleLogout : _handleLogin,
                icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
                label: Text(isLoggedIn ? 'Logout' : 'Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (!isLoggedIn || stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final timePeriodData = ProfileUtils.getTimePeriodData();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildPeriodCard(
                      'Daily',
                      timePeriodData['Daily']!['reports']!,
                      timePeriodData['Daily']!['rank']!,
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPeriodCard(
                      'Weekly',
                      timePeriodData['Weekly']!['reports']!,
                      timePeriodData['Weekly']!['rank']!,
                      Icons.date_range,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildPeriodCard(
                      'Monthly',
                      timePeriodData['Monthly']!['reports']!,
                      timePeriodData['Monthly']!['rank']!,
                      Icons.calendar_month,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPeriodCard(
                      'All-Time',
                      timePeriodData['All-Time']!['reports']!,
                      timePeriodData['All-Time']!['rank']!,
                      Icons.all_inclusive,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodCard(
    String period,
    int reports,
    int rank,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToLeaderboard(period),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  Text(
                    period,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reports: $reports',
                style: TextStyle(fontSize: 14, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                'Rank: #$rank',
                style: TextStyle(
                  fontSize: 14,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.leaderboard,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view leaderboard',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Please login to view your profile',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Track your study space reports and rankings',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: widget.onHomePressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.green.shade700, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            if (isLoggedIn && stats.isNotEmpty) ...[
              _buildStatsOverview(),
            ] else
              _buildEmptyState(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
