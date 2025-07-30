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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Library> libraries = [];
  Map<String, bool> favoriteStates = {};

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
    });
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
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            tooltip: 'Show Weighted Average',
            onPressed: () {
              final result = LibraryUtils.weightedAverageWithDetails([
                {
                  'source': 'user',
                  'value': [5, 3, 3],
                  'weight': 0.9,
                  'bump': 0.1,
                },
                {
                  'source': 'reservations',
                  'value': [12],
                  'weight': 0.75,
                  'bump': 0.2,
                },
                {
                  'source': 'history',
                  'value': [5],
                  'weight': 0.45,
                  'bump': 0.05,
                },
              ]);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Weighted Average Result'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weighted Average: '
                        '${(result['weightedavg'] * 100).toStringAsFixed(2)}%',
                      ),
                      const SizedBox(height: 12),
                      const Text('Details:'),
                      ...List.generate(result['details'].length, (i) {
                        final d = result['details'][i];
                        return Text(
                          '${d['source']}: ${(d['avg'] * 100).toStringAsFixed(2)}%',
                        );
                      }),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: libraries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: libraries.length,
              itemBuilder: (context, index) {
                final library = libraries[index];
                final bool isLibraryOpen = LibraryUtils.isOpen(
                  library.openat,
                  library.closeat,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
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
