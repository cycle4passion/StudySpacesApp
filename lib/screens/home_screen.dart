import 'package:flutter/material.dart';
import '../models/library.dart';
import '../data/libraries_data.dart';
import 'library_detail_screen.dart';
import 'report_screen.dart';
import '../utils/color_utils.dart';
import '../utils/library_utils.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback onHomePressed;
  final Function(int)? onTabTapped;
  final int? currentIndex;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onHomePressed,
    this.onTabTapped,
    this.currentIndex,
  });

  // TODO: darker green for darkmode?
  // remove weighted average ui/code
  // filter data as array ["24/7", "Open Now", "Favorites", "Reservations", "Open 2+hrs", "On Campus", "Off Campus"]
  // accordion for filters
  // submit space
  // Pocketbase DB, subscription to fullness (live updates)
  // backend - construction historic data, updating fullness
  // add libraries to use apis
  // load data from apis
  // login/authentication
  // leaderboard
  // UI tweaks

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Library> libraries = [];
  List<Library> filteredLibraries = [];
  Map<String, bool> favoriteStates = {};

  // Filter states
  Map<String, bool> filterStates = {
    'Printers': false,
    '24/7': false,
    'Open 2+ hrs': false,
    'Reservations': false,
    'Staffed': false,
    'Silent': false,
  };

  // ROYGBIV pastel colors for filters
  Map<String, Color> filterColors = {
    'Printers': Color(0xFFFFE5E5), // Pastel Red
    '24/7': Color(0xFFFFE5CC), // Pastel Orange
    'Open 2+ hrs': Color(0xFFFFFCE5), // Pastel Yellow
    'Reservations': Color(0xFFE5FFE5), // Pastel Green
    'Staffed': Color(0xFFE5F3FF), // Pastel Blue
    'Silent': Color(0xFFEDE5FF), // Pastel Violet
  };

  @override
  void initState() {
    super.initState();
    _loadLibraries();
  }

  void _loadLibraries() {
    final data = json.decode(librariesJson);
    final cornellLibraries = data['locations']['cornell'] as List;
    setState(() {
      libraries = cornellLibraries.map((lib) => Library.fromJson(lib)).toList();
      // Initialize favorite states from library data
      favoriteStates = {for (var lib in libraries) lib.id: lib.isFavorite};

      _applyFilters();
    });
  }

  void _sortLibraries() {
    filteredLibraries.sort((a, b) {
      final aFav = favoriteStates[a.id] ?? false;
      final bFav = favoriteStates[b.id] ?? false;
      final aOpen = LibraryUtils.isOpen(a.openat, a.closeat);
      final bOpen = LibraryUtils.isOpen(b.openat, b.closeat);

      // First priority: Favorites vs non-favorites (among open libraries)
      if (aOpen && bOpen) {
        if (aFav && !bFav) return -1;
        if (!aFav && bFav) return 1;
        // Both have same favorite status, sort by fullness
        return a.fullness.compareTo(b.fullness);
      }

      // Second priority: Open vs closed libraries
      if (aOpen && !bOpen) return -1;
      if (!aOpen && bOpen) return 1;

      // Both closed: sort by name
      return a.name.compareTo(b.name);
    });
  }

  void _applyFilters() {
    filteredLibraries = libraries.where((library) {
      // Check each active filter
      for (String filterName in filterStates.keys) {
        if (filterStates[filterName] == true) {
          if (!_libraryMatchesFilter(library, filterName)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    _sortLibraries();
  }

  bool _libraryMatchesFilter(Library library, String filterName) {
    switch (filterName) {
      case 'Printers':
        return library.features.any(
          (feature) => feature.toLowerCase().contains('print'),
        );
      case '24/7':
        return library.features.any(
          (feature) => feature.toLowerCase().contains('24-hour access'),
        );
      case 'Open 2+ hrs':
        return _libraryOpenForHours(library, 2);
      case 'Reservations':
        return library.features.any(
          (feature) =>
              feature.toLowerCase().contains('reservable rooms') ||
              feature.toLowerCase().contains('booking'),
        );
      case 'Staffed':
        return library.features.any(
          (feature) => feature.toLowerCase().contains('research assistance'),
        );
      case 'Silent':
        return library.features.any(
          (feature) => feature.toLowerCase().contains('silent study floors'),
        );
      default:
        return true;
    }
  }

  bool _libraryOpenForHours(Library library, int hours) {
    if (!LibraryUtils.isOpen(library.openat, library.closeat)) {
      return false;
    }

    final now = DateTime.now();
    int dayIndex = now.weekday - 1;

    if (dayIndex < 0 || dayIndex >= library.closeat.length) {
      return false;
    }

    int closeTime = library.closeat[dayIndex];
    if (closeTime == 0) return false;

    // Handle overnight closing (closes after midnight)
    if (closeTime < library.openat[dayIndex]) {
      // Add 24 hours to closing time for comparison
      closeTime += 2400;
    }

    int currentTime = now.hour * 100 + now.minute;
    int futureTime = currentTime + (hours * 100);

    return futureTime <= closeTime;
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
      body: filteredLibraries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets
                  .zero, // Remove top padding to be flush with app bar
              itemCount:
                  filteredLibraries.length + 1, // +1 for the filter accordion
              itemBuilder: (context, index) {
                // First item is the filter row
                if (index == 0) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
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
                          padding: EdgeInsets.only(left: 16.0, right: 12.0),
                          child: Text(
                            'Filter by',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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
                                      label: Text(filterName),
                                      selected:
                                          filterStates[filterName] ?? false,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          filterStates[filterName] = selected;
                                          _applyFilters();
                                        });
                                      },
                                      backgroundColor: filterColors[filterName],
                                      selectedColor: filterColors[filterName]
                                          ?.withOpacity(0.8),
                                      checkmarkColor: Colors.black54,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
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

                // Adjust index for library items
                final libraryIndex = index - 1;
                final library = filteredLibraries[libraryIndex];
                final bool isLibraryOpen = LibraryUtils.isOpen(
                  library.openat,
                  library.closeat,
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    0,
                    16.0,
                    16.0,
                  ), // No top padding for first library item
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
                                builder: (context) => LibraryDetailScreen(
                                  library: library,
                                  onHomePressed: widget.onHomePressed,
                                  onTabTapped: widget.onTabTapped,
                                  currentIndex: widget.currentIndex,
                                ),
                              ),
                            );
                          },
                          child: Opacity(
                            opacity: isLibraryOpen ? 1.0 : 0.3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Hero(
                                      tag: 'library-image-${library.id}',
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: SizedBox(
                                          height: 133,
                                          width: double.infinity,
                                          child: Image.asset(
                                            library.image,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Colors.blue.shade300,
                                                          Colors
                                                              .purple
                                                              .shade300,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.local_library,
                                                      size: 80,
                                                      color: Colors.white
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
                                            (favoriteStates[library.id] ??
                                                false)
                                            ? "Unfavorite"
                                            : "Favorite",
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              favoriteStates[library.id] =
                                                  !(favoriteStates[library
                                                          .id] ??
                                                      false);

                                              _applyFilters();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              (favoriteStates[library.id] ??
                                                      false)
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color:
                                                  (favoriteStates[library.id] ??
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              library.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            LibraryUtils.getStatusText(
                                              library.openat,
                                              library.closeat,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              library.category,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          // Only show report button if library is open
                                          if (isLibraryOpen)
                                            Tooltip(
                                              message: 'Report on Fullness',
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportScreen(
                                                            onHomePressed: widget
                                                                .onHomePressed,
                                                            preSelectedLibrary:
                                                                library,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/icon/report.png',
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                    isAntiAlias: true,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Icon(
                                                            Icons.report,
                                                            size: 20,
                                                            color: Colors
                                                                .green
                                                                .shade700,
                                                          );
                                                        },
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Left side - Fullness indicator (only if library is open)
                                          if (isLibraryOpen)
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ColorUtils.getFullnessColor(
                                                          library.fullness,
                                                        ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  LibraryUtils.getFullnessText(
                                                    library.fullness,
                                                  ),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.8),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          // If library is closed, use a spacer to push content right
                                          if (!isLibraryOpen) const Spacer(),
                                          // Right side - Capacity and floors
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Capacity ${library.capacity}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.layers,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${library.floors} Floor${library.floors == 1 ? '' : 's'}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
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
                        // Diagonal "CLOSED" overlay for closed libraries
                        if (!isLibraryOpen)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                                child: CustomPaint(
                                  painter: DiagonalTextPainter(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Custom painter for diagonal "CLOSED" text
class DiagonalTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate text position and rotation
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'CLOSED',
        style: TextStyle(
          color: Colors.red.withValues(alpha: 0.3),
          fontSize: 96,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Save canvas state
    canvas.save();

    // Move to center and rotate
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5); // Rotate -30 degrees

    // Draw text centered
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    // Restore canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
