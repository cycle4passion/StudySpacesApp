import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/space.dart';
import '../utils/spaces_utils.dart';

class SpaceDetailsScreen extends StatefulWidget {
  final Space space;
  final VoidCallback onHomePressed;
  final Function(int)? onTabTapped;
  final int? currentIndex;

  const SpaceDetailsScreen({
    super.key,
    required this.space,
    required this.onHomePressed,
    this.onTabTapped,
    this.currentIndex,
  });

  @override
  State<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen> {
  bool isExpanded = false;

  void _showReservationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Reserve Study Space',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Reservation system coming soon!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Check if we can pop (meaning this screen was pushed)
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fall back to tab navigation
                  widget.onHomePressed();
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.space.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Hero(
                tag: 'space-image-${widget.space.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.space.image,
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
                            Icons.school,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Space Details',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // Show Reserve Space button only if space has reservationid
                      if (widget.space.reservationid != null)
                        ElevatedButton.icon(
                          onPressed: () => _showReservationModal(context),
                          icon: const Icon(Icons.event_seat, size: 18),
                          label: const Text('Reserve Space'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(context),
                  const SizedBox(height: 12),
                  _buildEnhancedHoursCard(context),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    Icons.people,
                    'Capacity',
                    '${widget.space.capacity} people',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    Icons.layers,
                    'Floors',
                    '${widget.space.floors} floors',
                  ),
                  const SizedBox(height: 12),
                  _buildFeaturesCard(context),
                  const SizedBox(height: 12),
                  _buildAddressCard(context),
                  const SizedBox(height: 12),
                  _buildPhoneCard(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.space.category,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    // ROYGBIV color scheme
    final List<Color> roygbivColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 24, color: Colors.green),
                const SizedBox(width: 16),
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.space.features.asMap().entries.map((entry) {
                final int index = entry.key;
                final String feature = entry.value;
                final Color backgroundColor =
                    roygbivColors[index % roygbivColors.length];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: backgroundColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: backgroundColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openDirections(widget.space.address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.directions_walk,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.space.address,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _makePhoneCall(widget.space.phone),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Phone',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.call, size: 16, color: Colors.green.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.space.phone,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDirections(String address) async {
    // Encode the address for URL
    final encodedAddress = Uri.encodeComponent(address);

    // Create Google Maps URL with walking directions as default
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress&travelmode=walking',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEnhancedHoursCard(BuildContext context) {
    final isOpen = SpacesUtils.isOpen(
      widget.space.openat,
      widget.space.closeat,
    );

    final statusText = SpacesUtils.getTimeStatusText(
      widget.space.openat,
      widget.space.closeat,
    );

    return Card(
      child: Column(
        children: [
          // Main hours display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time,
                    size: 24,
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hours',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOpen ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isOpen ? Colors.green : Colors.red,
                                  ),
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
          const SizedBox(height: 12),
          _buildWeeklyHours(context),
        ],
      ),
    );
  }

  Widget _buildWeeklyHours(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday

    return Column(
      children: List.generate(days.length, (index) {
        if (index >= widget.space.openat.length ||
            index >= widget.space.closeat.length) {
          return const SizedBox.shrink();
        }

        final isToday = index == currentDayIndex;
        final openTime = widget.space.openat[index];
        final closeTime = widget.space.closeat[index];

        String hoursText;
        if (openTime == 0 || closeTime == 0) {
          hoursText = 'Closed';
        } else {
          hoursText =
              '${_formatMilitaryTime(openTime)} - ${_formatMilitaryTime(closeTime)}';
        }

        // Check if space is currently open (for today's highlighting)
        final isCurrentlyOpen = SpacesUtils.isOpen(
          widget.space.openat,
          widget.space.closeat,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isToday
                ? (isCurrentlyOpen ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                days[index],
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? (isCurrentlyOpen ? Colors.green : Colors.red)
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                hoursText,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? (isCurrentlyOpen ? Colors.green : Colors.red)
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatMilitaryTime(int militaryTime) {
    if (militaryTime == 0) return 'Closed';

    final hours = militaryTime ~/ 100;
    final minutes = militaryTime % 100;

    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);

    return '$displayHours:${minutes.toString().padLeft(2, '0')} $period';
  }
}
