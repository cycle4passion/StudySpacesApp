import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/library.dart';
import '../utils/library_utils.dart';
import '../utils/color_utils.dart';

class SpacesDetailScreen extends StatefulWidget {
  final Library library;
  final VoidCallback onHomePressed;
  final Function(int)? onTabTapped;
  final int? currentIndex;

  const SpacesDetailScreen({
    super.key,
    required this.library,
    required this.onHomePressed,
    this.onTabTapped,
    this.currentIndex,
  });

  @override
  State<SpacesDetailScreen> createState() => _SpacesDetailScreenState();
}

class _SpacesDetailScreenState extends State<SpacesDetailScreen> {
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
    final isOpen = LibraryUtils.isOpen(
      widget.library.openat,
      widget.library.closeat,
    );

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
                widget.library.name,
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
                tag: 'space-image-${widget.library.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.library.image,
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
                      if (widget.library.reservationid != null)
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
                    '${widget.library.capacity} people',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    Icons.layers,
                    'Floors',
                    '${widget.library.floors} floors',
                  ),
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
              widget.library.category,
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

  Widget _buildAddressCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openDirections(widget.library.address),
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
                widget.library.address,
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
        onTap: () => _makePhoneCall(widget.library.phone),
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
                widget.library.phone,
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
    final isOpen = LibraryUtils.isOpen(
      widget.library.openat,
      widget.library.closeat,
    );

    final statusText = LibraryUtils.getTimeStatusText(
      widget.library.openat,
      widget.library.closeat,
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
        if (index >= widget.library.openat.length ||
            index >= widget.library.closeat.length) {
          return const SizedBox.shrink();
        }

        final isToday = index == currentDayIndex;
        final openTime = widget.library.openat[index];
        final closeTime = widget.library.closeat[index];

        String hoursText;
        if (openTime == 0 || closeTime == 0) {
          hoursText = 'Closed';
        } else {
          hoursText =
              '${_formatMilitaryTime(openTime)} - ${_formatMilitaryTime(closeTime)}';
        }

        // Check if space is currently open (for today's highlighting)
        final isCurrentlyOpen = LibraryUtils.isOpen(
          widget.library.openat,
          widget.library.closeat,
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

    return '${displayHours}:${minutes.toString().padLeft(2, '0')} $period';
  }
}
