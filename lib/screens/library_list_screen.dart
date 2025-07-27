import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';
import '../models/library.dart';
import '../data/libraries_data.dart';
import 'library_detail_screen.dart';
import 'dart:convert';

Future<void> scrape() async {
  var parser = await Chaleno().load('https://example.com');
  final contents = parser?.querySelector('h1').text;
  print('Scrape result: $contents');
}

Map<String, dynamic> weightedAverageWithDetails(
  List<Map<String, dynamic>> items,
) {
  if (items.isEmpty) {
    return {'weightedavg': 0.0, 'details': []};
  }
  double weightedSum = 0;
  double totalWeight = 0;
  List<Map<String, dynamic>> details = [];

  for (var item in items) {
    final source = item['source'];
    final values = (item['value'] as List)
        .map((v) => (v as num).toDouble())
        .toList();
    double baseWeight = (item['weight'] as num).toDouble();
    double bump = (item['bump'] as num?)?.toDouble() ?? 0.0;
    double itemWeight = baseWeight;
    for (var v in values) {
      if (v > 1 && itemWeight < 1) itemWeight += bump;
    }
    double avg = values.isEmpty
        ? 0
        : values.reduce((a, b) => a + b) / values.length;
    weightedSum += avg * itemWeight;
    totalWeight += itemWeight;
    details.add({'source': source, 'avg': avg});
  }
  double avg = totalWeight == 0 ? 0 : (weightedSum / totalWeight).clamp(0, 100);
  return {'weightedavg': avg, 'details': details};
}

class LibraryListScreen extends StatefulWidget {
  const LibraryListScreen({super.key});

  @override
  State<LibraryListScreen> createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  List<Library> libraries = [];

  @override
  void initState() {
    super.initState();
    _loadLibraries();
    _loadScrapeData();
  }

  Future<void> _loadScrapeData() async {
    try {
      // Using cors-anywhere as a proxy
      var proxyUrl = 'https://cors-anywhere.herokuapp.com/';
      var targetUrl = 'https://example.com';
      var parser = await Chaleno().load(proxyUrl + targetUrl);

      if (parser == null) {
        throw Exception('Failed to load webpage');
      }

      // Get both title and any h1 content
      final title = parser.title;
      final h1Text = parser.querySelector('h1').text;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scraped - Title: $title, H1: $h1Text'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Scraping error: $e'); // For debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scraping: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
        title: const Text(
          'Cornell Study Spaces',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Show Weighted Average',
            onPressed: () {
              final result = weightedAverageWithDetails([
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
                                height: 200,
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
                                Text(
                                  library.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${library.capacity} capacity',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.layers,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${library.floors} floors',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
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
                );
              },
            ),
    );
  }
}
