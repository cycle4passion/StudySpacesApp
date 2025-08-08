import 'package:flutter/material.dart';
import '../models/space.dart';
import '../data/spaces_data.dart';
import 'space_details_screen.dart';
import 'add_space_screen.dart';
import '../utils/color_utils.dart';
import '../utils/spaces_utils.dart';
import '../utils/profile_utils.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback onHomePressed;
  final Function(Space)? onReportPressed; // Changed to accept Space parameter
  final Function(int)? onTabTapped;
  final int? currentIndex;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onHomePressed,
    this.onReportPressed, // Add this parameter
    this.onTabTapped,
    this.currentIndex,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Space> spaces = [];
  List<Space> filteredSpaces = [];
  Map<String, bool> favoriteStates = {};

  // Filter states
  Map<String, bool> filterStates = {
    '24/7': false,
    'Open 2+ hrs': false,
    'Reservations': false,
    'Printers': false,
    'Staffed': false,
    'Silent': false,
  };

  // ROYGBIV pastel colors for filters
  Map<String, Color> filterColors = {
    '24/7': Color(0xFFFFE5E5), // Pastel Red
    'Open 2+ hrs': Color(0xFFFFE5CC), // Pastel Orange
    'Reservations': Color(0xFFFFFCE5), // Pastel Yellow
    'Printers': Color(0xFFE5FFE5), // Pastel Green
    'Staffed': Color(0xFFE5F3FF), // Pastel Blue
    'Silent': Color(0xFFEDE5FF), // Pastel Violet
  };

  // Corresponding full opacity border colors for filters
  Map<String, Color> filterBorderColors = {
    '24/7': Color(
      0xFFFF0000,
    ).withValues(alpha: 0.5), // Full Red with 50% opacity
    'Open 2+ hrs': Color(
      0xFFFF8000,
    ).withValues(alpha: 0.5), // Full Orange with 50% opacity
    'Reservations': Color(
      0xFFFFD700,
    ).withValues(alpha: 0.5), // Full Yellow/Gold with 50% opacity
    'Printers': Color(
      0xFF00C000,
    ).withValues(alpha: 0.5), // Full Green with 50% opacity
    'Staffed': Color(
      0xFF0080FF,
    ).withValues(alpha: 0.5), // Full Blue with 50% opacity
    'Silent': Color(
      0xFF8000FF,
    ).withValues(alpha: 0.5), // Full Violet with 50% opacity
  };

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  void _loadSpaces() {
    final data = json.decode(spacesJson);
    final cornellSpaces = data['locations']['cornell'] as List;
    setState(() {
      spaces = cornellSpaces.map((lib) => Space.fromJson(lib)).toList();
      // Initialize favorite states from profile data
      final favoriteSpaceIds = ProfileUtils.getFavoriteSpaces();
      favoriteStates = {
        for (var space in spaces) space.id: favoriteSpaceIds.contains(space.id),
      };

      _applyFilters();
    });
  }

  Future<void> _refreshSpaces() async {
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 1000));

    // Reload the spaces data
    _loadSpaces();
  }

  void _sortSpaces() {
    filteredSpaces.sort((a, b) {
      final aFav = favoriteStates[a.id] ?? false;
      final bFav = favoriteStates[b.id] ?? false;
      final aOpen = SpacesUtils.isOpen(a.openat, a.closeat);
      final bOpen = SpacesUtils.isOpen(b.openat, b.closeat);

      // Create priority scores for each space
      // Higher score = higher priority (appears first)
      int aPriority = 0;
      int bPriority = 0;

      // Base priority: Open = 2000, Closed = 1000
      if (aOpen) aPriority += 2000;
      if (bOpen) bPriority += 2000;

      // Favorite bonus: +500 points
      if (aFav) aPriority += 500;
      if (bFav) bPriority += 500;

      // Less busy bonus: invert fullness (5-fullness) so lower fullness = higher priority
      // This gives 0-5 points with 0 being busiest and 5 being least busy
      aPriority += (5 - a.fullness);
      bPriority += (5 - b.fullness);

      // Sort by priority (higher priority first)
      int priorityComparison = bPriority.compareTo(aPriority);

      // If priorities are equal, sort by name as tiebreaker
      if (priorityComparison == 0) {
        return a.name.compareTo(b.name);
      }

      return priorityComparison;
    });
  }

  void _applyFilters() {
    filteredSpaces = spaces.where((space) {
      // Check each active filter
      for (String filterName in filterStates.keys) {
        if (filterStates[filterName] == true) {
          if (!_spaceMatchesFilter(space, filterName)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    _sortSpaces();
  }

  bool _spaceMatchesFilter(Space space, String filterName) {
    switch (filterName) {
      case 'Printers':
        return space.features.any(
          (feature) => feature.toLowerCase().contains('print'),
        );
      case '24/7':
        return space.features.any(
          (feature) => feature.toLowerCase().contains('24-hour access'),
        );
      case 'Open 2+ hrs':
        return _spaceOpenForHours(space, 2);
      case 'Reservations':
        return space.reservationid != null;
      case 'Staffed':
        return space.features.any(
          (feature) => feature.toLowerCase().contains('research assistance'),
        );
      case 'Silent':
        return space.features.any(
          (feature) => feature.toLowerCase().contains('silent study floors'),
        );
      default:
        return true;
    }
  }

  bool _spaceOpenForHours(Space space, int hours) {
    if (!SpacesUtils.isOpen(space.openat, space.closeat)) {
      return false;
    }

    final now = DateTime.now();
    int dayIndex = now.weekday - 1;

    if (dayIndex < 0 || dayIndex >= space.closeat.length) {
      return false;
    }

    int closeTime = space.closeat[dayIndex];
    if (closeTime == 0) return false;

    // Handle overnight closing (closes after midnight)
    if (closeTime < space.openat[dayIndex]) {
      // Add 24 hours to closing time for comparison
      closeTime += 2400;
    }

    int currentTime = now.hour * 100 + now.minute;
    int futureTime = currentTime + (hours * 100);

    return futureTime <= closeTime;
  }

  Widget _buildFilterRow() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 8.0),
            child: Text(
              'Filters:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          // Clear filters button - only shows when filters are active
          if (filterStates.values.any((isActive) => isActive == true))
            Container(
              width: 20, // Fixed width
              height: 20,
              margin: const EdgeInsets.only(right: 8.0),
              child: Tooltip(
                message: 'Clear Filters',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      hoverColor: Colors.red.withValues(alpha: 0.1),
                      onTap: () {
                        setState(() {
                          // Clear all filters
                          for (String key in filterStates.keys) {
                            filterStates[key] = false;
                          }
                          _applyFilters();
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2.0), // Much smaller padding
                        child: Icon(Icons.close, color: Colors.red, size: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: filterStates.keys.map((filterName) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          filterName,
                          style: TextStyle(
                            color: filterStates[filterName] == true
                                ? Colors.black87
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors.black87
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: filterStates[filterName] ?? false,
                        onSelected: (bool selected) {
                          setState(() {
                            filterStates[filterName] = selected;
                            _applyFilters();
                          });
                        },
                        backgroundColor: filterColors[filterName],
                        selectedColor: filterColors[filterName]?.withValues(
                          alpha: 0.8,
                        ),
                        checkmarkColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: filterStates[filterName] == true
                                ? filterBorderColors[filterName] ??
                                      Colors.black54
                                : (filterBorderColors[filterName] ??
                                          Colors.grey.shade400)
                                      .withValues(alpha: 0.3),
                            width: filterStates[filterName] == true ? 2.0 : 1.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSpaceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddSpaceScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green,
                      width: 4, // Reduced from 8 to 4 for better balance
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 40, // Increased from 32 to 40
                    color: Colors.green,
                    weight: 900, // Maximum weight for thickest lines
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Space',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Suggest a new Study Space!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Study Spaces',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: widget.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: spaces.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshSpaces,
              color: Colors.green,
              backgroundColor: Colors.white,
              child: filteredSpaces.isEmpty
                  ? CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildFilterRow()),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Spaces Found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters to see more results.',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.grey.shade500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets
                          .zero, // Remove top padding to be flush with app bar
                      itemCount:
                          filteredSpaces.length +
                          2, // +1 for the filter accordion, +1 for add space card
                      itemBuilder: (context, index) {
                        // First item is the filter row
                        if (index == 0) {
                          return _buildFilterRow();
                        }

                        // Last item is the add space card
                        if (index == filteredSpaces.length + 1) {
                          return _buildAddSpaceCard();
                        }

                        // Adjust index for space items
                        final spaceIndex = index - 1;
                        final space = filteredSpaces[spaceIndex];
                        final bool isSpaceOpen = SpacesUtils.isOpen(
                          space.openat,
                          space.closeat,
                        );

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0,
                            16.0,
                            16.0,
                          ), // No top padding for first space item
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SpaceDetailsScreen(
                                              space: space,
                                              onHomePressed:
                                                  widget.onHomePressed,
                                              onTabTapped: widget.onTabTapped,
                                              currentIndex: widget.currentIndex,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Opacity(
                                    opacity: isSpaceOpen ? 1.0 : 0.3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Hero(
                                              tag: 'space-image-${space.id}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(16),
                                                    ),
                                                child: SizedBox(
                                                  height: 133,
                                                  width: double.infinity,
                                                  child: Image.asset(
                                                    space.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Colors
                                                                      .blue
                                                                      .shade300,
                                                                  Colors
                                                                      .purple
                                                                      .shade300,
                                                                ],
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .local_library,
                                                              size: 80,
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Tooltip(
                                                message:
                                                    (favoriteStates[space.id] ??
                                                        false)
                                                    ? "Unfavorite"
                                                    : "Favorite",
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      favoriteStates[space.id] =
                                                          !(favoriteStates[space
                                                                  .id] ??
                                                              false);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      (favoriteStates[space
                                                                  .id] ??
                                                              false)
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color:
                                                          (favoriteStates[space
                                                                  .id] ??
                                                              false)
                                                          ? Colors.yellow[600]
                                                          : Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // First row: Space name and report button
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      space.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (isSpaceOpen)
                                                    Tooltip(
                                                      message:
                                                          'Report capacity for ${space.name}',
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          widget.onReportPressed
                                                              ?.call(space);
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: [
                                                                Colors
                                                                    .green
                                                                    .shade400,
                                                                Colors
                                                                    .green
                                                                    .shade600,
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            boxShadow: [
                                                              // Primary shadow for depth
                                                              BoxShadow(
                                                                color: Colors
                                                                    .green
                                                                    .shade800
                                                                    .withValues(
                                                                      alpha:
                                                                          0.4,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      4,
                                                                    ),
                                                                spreadRadius: 0,
                                                              ),
                                                              // Secondary shadow for more depth
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    ),
                                                                blurRadius: 12,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      6,
                                                                    ),
                                                                spreadRadius: 1,
                                                              ),
                                                              // Inner highlight for 3D effect
                                                              BoxShadow(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      -1,
                                                                    ),
                                                                spreadRadius: 0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons.campaign,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Left side - Fullness indicator (only if space is open)
                                                  if (isSpaceOpen)
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 12,
                                                            height: 12,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  ColorUtils.getFullnessColor(
                                                                    space
                                                                        .fullness,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              SpacesUtils.getFullnessText(
                                                                space.fullness,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onSurface
                                                                        .withValues(
                                                                          alpha:
                                                                              0.8,
                                                                        ),
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  // If space is closed, use a spacer to push content right
                                                  if (!isSpaceOpen)
                                                    const Spacer(),
                                                  // Right side - Time status
                                                  Text(
                                                    SpacesUtils.getTimeStatusText(
                                                      space.openat,
                                                      space.closeat,
                                                    ),
                                                    style: TextStyle(
                                                      color: isSpaceOpen
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
