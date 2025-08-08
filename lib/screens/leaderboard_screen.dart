import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/spaces_data.dart';
import '../models/profile.dart';

class LeaderboardEntry {
  final String name;
  final int reports;

  LeaderboardEntry({required this.name, required this.reports});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(name: json['name'], reports: json['reports']);
  }
}

class LeaderboardScreen extends StatefulWidget {
  final VoidCallback? onHomePressed;
  final Function(int)? onTabTapped;
  final int? currentIndex;

  const LeaderboardScreen({
    super.key,
    this.onHomePressed,
    this.onTabTapped,
    this.currentIndex,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Week';
  final List<String> periods = ['Day', 'Week', 'Month', 'All Time'];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 1; // Default to 'Week' index
  late Profile _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
  }

  void _loadUserProfile() {
    final data = json.decode(profileJson);
    _userProfile = Profile.fromJson(data['profile']);
  }

  int _getUserRankForPeriod(String period) {
    switch (period) {
      case 'Day':
        return _userProfile.rank[0]; // 934
      case 'Week':
        return _userProfile.rank[1]; // 432
      case 'Month':
        return _userProfile.rank[2]; // 453
      case 'All Time':
        return _userProfile.rank[3]; // 1233
      default:
        return _userProfile.rank[1]; // Default to week
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _animateToNewPeriod(String newPeriod) {
    final newIndex = periods.indexOf(newPeriod);
    final isMovingRight = newIndex > _previousIndex;

    // Set the starting position based on direction
    _slideAnimation =
        Tween<Offset>(
          begin: isMovingRight
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    setState(() {
      selectedPeriod = newPeriod;
      _previousIndex = newIndex;
    });

    _slideController.reset();
    _slideController.forward();
  }

  List<LeaderboardEntry> get currentLeaderboard {
    final data = json.decode(spacesJson);
    final leaderboardData = data['leaderboard'];

    List<dynamic> entries;
    switch (selectedPeriod) {
      case 'Day':
        entries = leaderboardData['day'];
        break;
      case 'Week':
        entries = leaderboardData['week'];
        break;
      case 'Month':
        entries = leaderboardData['month'];
        break;
      case 'All Time':
        entries = leaderboardData['alltime'];
        break;
      default:
        entries = leaderboardData['week'];
    }

    return entries.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onHomePressed != null) {
              widget.onHomePressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Segmented Control
          Container(
            margin: const EdgeInsets.fromLTRB(
              12, // Increased from 8 for better balance
              6, // Reduced from 8
              12, // Increased from 8 for better balance
              1, // Reduced from 3 to decrease space to leaderboard
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                padding: const EdgeInsets.all(3), // Reduced from 4
                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.1,
                  ), // Very light green instead of grey
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth /
                        periods.length; // Equal width distribution
                    final selectedIndex = periods.indexOf(selectedPeriod);

                    return SizedBox(
                      height: 40, // Reduced from 44
                      child: Stack(
                        children: [
                          // Animated background pill
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left:
                                selectedIndex * itemWidth +
                                3, // Reduced padding offset
                            top: 3, // Reduced from 4
                            bottom: 3, // Reduced from 4
                            width: itemWidth - 6, // Reduced from 8
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? [] // Remove shadows in dark mode to eliminate halo effect
                                    : [
                                        BoxShadow(
                                          color: Colors.green.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, -1),
                                        ),
                                      ],
                              ),
                            ),
                          ),
                          // Text buttons
                          Row(
                            children: periods.map((period) {
                              final isSelected = selectedPeriod == period;
                              return GestureDetector(
                                onTap: () {
                                  _animateToNewPeriod(period);
                                },
                                child: SizedBox(
                                  width:
                                      itemWidth, // Fixed width for each button
                                  height: 40, // Reduced from 44
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 14, // Increased from 12
                                          letterSpacing: 0.3,
                                        ),
                                        child: Text(
                                          period,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Leaderboard List
          Flexible(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  12, // Reduced from 16
                  2, // Reduced from 6 to decrease space from selector
                  12, // Reduced from 16
                  8, // Further reduced bottom margin from 16
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Theme.of(context).brightness == Brightness.dark
                          ? Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(
                        2,
                      ), // Further reduced from 4
                      itemCount: currentLeaderboard.length,
                      separatorBuilder: (context, index) {
                        // Check if the next item (index + 1) is the user at position 10
                        final nextIndex = index + 1;
                        final isUserAtPosition10 =
                            nextIndex < currentLeaderboard.length &&
                            currentLeaderboard[nextIndex].name == 'j9999' &&
                            nextIndex == 9; // Position 10 (0-based index 9)

                        if (isUserAtPosition10) {
                          // Dashed divider for user entry
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 0.5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 2),
                                    painter: DashedLinePainter(
                                      color: Colors.green.withValues(
                                        alpha: 0.7,
                                      ),
                                      dashWidth: 6,
                                      dashSpace: 4,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Regular divider
                          return Divider(
                            color: Colors.grey.shade200,
                            thickness: 1,
                            height: 1,
                          );
                        }
                      },
                      itemBuilder: (context, index) {
                        final entry = currentLeaderboard[index];
                        final rank = index + 1;

                        // Use actual user rank for j9999, otherwise use position
                        final displayRank = entry.name == 'j9999'
                            ? _getUserRankForPeriod(selectedPeriod)
                            : rank;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0.1,
                          ), // Further reduced from 0.2
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.green.withValues(
                                    alpha: 0.05,
                                  ) // Light green for even indices
                                : Colors.white, // White for odd indices
                            borderRadius: rank == 1
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  )
                                : rank == currentLeaderboard.length
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  )
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, // Further reduced from 6
                              vertical: 0, // Keep at 0
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28, // Reduced from 32
                                  height: 28, // Reduced from 32
                                  decoration: BoxDecoration(
                                    color: _getRankBadgeColor(rank),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getRankBadgeColor(
                                          rank,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$displayRank',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            10, // Reduced from 11 to fit smaller circle
                                      ),
                                    ),
                                  ),
                                ),
                                if (rank <= 3) ...[
                                  const SizedBox(width: 4), // Keep spacing same
                                  Icon(
                                    _getRankIcon(rank),
                                    color: _getRankIconColor(rank),
                                    size: 28, // Reduced from 32
                                  ),
                                ],
                              ],
                            ),
                            title: Text(
                              entry.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // Reduced from 16
                                color: Colors
                                    .grey
                                    .shade800, // Consistent text color
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, // Reduced from 12
                                vertical: 4, // Reduced from 6
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(
                                  alpha: 0.1,
                                ), // Consistent badge color
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${entry.reports} ${entry.reports == 1 ? 'Report' : 'Reports'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13, // Reduced from 14
                                  color: Colors.green, // Consistent text color
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.onTabTapped != null
          ? BottomNavigationBar(
              currentIndex: widget.currentIndex ?? 0,
              onTap: widget.onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.green,
              selectedItemColor: Theme.of(context).colorScheme.onPrimary,
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.7),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.campaign),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.green; // Green background for consistency
      case 2:
        return Colors.green; // Green background for consistency
      case 3:
        return Colors.green; // Green background for consistency
      default:
        return Colors.green;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Bronze medal
      default:
        return Icons.star;
    }
  }

  Color _getRankIconColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.green;
    }
  }
}

// Custom painter for dashed lines
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double currentX = 0;
    final y = size.height / 2;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, y),
        Offset(currentX + dashWidth, y),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
