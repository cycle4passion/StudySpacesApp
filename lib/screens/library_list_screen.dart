import 'package:flutter/material.dart';
import '../models/library.dart';
import '../data/libraries_data.dart';
import 'library_detail_screen.dart';
import '../utils/color_utils.dart';
import '../utils/library_utils.dart';
import 'dart:convert';

class LibraryListScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const LibraryListScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<LibraryListScreen> createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  List<Library> libraries = [];

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LibraryDetailScreen(library: library),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'library-image-${library.id}',
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: SizedBox(
                                height: 133,
                                width: double.infinity,
                                child: Image.asset(
                                  library.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.blue.shade300,
                                            Colors.purple.shade300,
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.local_library,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  library.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
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
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side - Fullness indicator
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: ColorUtils.getFullnessColor(
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
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Right side - Capacity and floors
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Capacity ${library.capacity}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.layers,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${library.floors} Floor${library.floors == 1 ? '' : 's'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
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
                );
              },
            ),
    );
  }
}
