import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'dart:convert';
import '../data/spaces_data.dart';
import '../models/space.dart';
import '../utils/color_utils.dart';
import '../utils/spaces_utils.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback onHomePressed;
  final Space? preSelectedSpace;

  const ReportScreen({
    super.key,
    required this.onHomePressed,
    this.preSelectedSpace,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Space? selectedSpace;
  double fullnessValue = 3.0;
  List<Space> spaces = [];
  bool isCheckingLocation = false;
  bool canReportAtCurrentLocation = false;
  String? locationErrorMessage;
  GeofenceErrorType? locationErrorType;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  @override
  void didUpdateWidget(ReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if preSelectedSpace changed
    if (widget.preSelectedSpace != oldWidget.preSelectedSpace) {
      setState(() {
        _updateSelectedSpace();
      });
    }
  }

  void _loadSpaces() {
    final Map<String, dynamic> data = json.decode(spacesJson);
    final List<dynamic> cornellSpaces = data['locations']['cornell'];
    setState(() {
      spaces = cornellSpaces.map((lib) => Space.fromJson(lib)).toList();
      _updateSelectedSpace();
    });
  }

  void _updateSelectedSpace() {
    // Set preselected space if provided and it's currently open
    if (widget.preSelectedSpace != null) {
      final preselected = spaces.firstWhere(
        (lib) => lib.id == widget.preSelectedSpace!.id,
        orElse: () => widget.preSelectedSpace!,
      );

      // Only set as selected if the space is currently open
      if (SpacesUtils.isOpen(preselected.openat, preselected.closeat)) {
        selectedSpace = preselected;
        // Set slider to current fullness value of the preselected space
        fullnessValue = selectedSpace!.fullness.toDouble();
        // Check location for preselected space
        _checkLocationForSpace(selectedSpace!);
      } else {
        // If preselected space is closed, selectedSpace remains null
        selectedSpace = null;
      }
    } else {
      // No preselected space, clear selection
      selectedSpace = null;
      canReportAtCurrentLocation = false;
      locationErrorMessage = null;
      locationErrorType = null;
    }
  }

  Future<void> _checkLocationForSpace(Space space) async {
    setState(() {
      isCheckingLocation = true;
      canReportAtCurrentLocation = false;
      locationErrorMessage = null;
      locationErrorType = null;
    });

    try {
      final result = await SpacesUtils.canReportAtSpaceWithDetails(
        spaceLat: space.latitude,
        spaceLon: space.longitude,
        spaceRange: space.range,
      );

      setState(() {
        canReportAtCurrentLocation = result.success;
        isCheckingLocation = false;
        locationErrorType = result.errorType;

        if (!result.success && result.errorType != null) {
          switch (result.errorType!) {
            case GeofenceErrorType.permissionDenied:
              locationErrorMessage =
                  'Location permission is required to verify you are at the study space. Please enable location access in your device settings.';
              break;
            case GeofenceErrorType.locationServicesDisabled:
              locationErrorMessage =
                  'Location services are disabled. Please enable location services in your device settings to verify your presence at the study space.';
              break;
            case GeofenceErrorType.outsideGeofence:
              locationErrorMessage =
                  'Thank you for supporting StudySpaces. However, you may only report on ${space.name} when you are physically present at that location.';
              break;
            case GeofenceErrorType.locationError:
              locationErrorMessage =
                  'Unable to determine your location. Please check your internet connection and try again.';
              break;
          }
        }
      });
    } catch (e) {
      setState(() {
        isCheckingLocation = false;
        canReportAtCurrentLocation = false;
        locationErrorType = GeofenceErrorType.locationError;
        locationErrorMessage =
            'Unable to verify your location. Please check location permissions and try again.';
      });
    }
  }

  void _showSubmitDialog() {
    if (selectedSpace == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: Text(
          '${selectedSpace!.name}\n${fullnessValue.round()} - ${SpacesUtils.getFullnessText(fullnessValue.round())}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to check if any spaces are currently open
  bool get hasOpenSpaces {
    return spaces.any(
      (space) => SpacesUtils.isOpen(space.openat, space.closeat),
    );
  }

  double _getTooltipPosition() {
    // Calculate the position of the tooltip based on slider value
    // Standard slider padding
    const double sliderPadding = 24.0;

    // Get screen width and calculate available slider width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth =
        screenWidth - 40 - (sliderPadding * 2); // 40 is body padding

    // Calculate position based on slider value (1-5 range)
    final double normalizedValue = (fullnessValue - 1) / 4; // Normalize to 0-1
    final double sliderPosition =
        sliderPadding + (normalizedValue * availableWidth);

    // Estimate tooltip width and center it on the handle (increased for larger tooltip)
    const double tooltipWidth = 140.0; // Increased tooltip width
    double tooltipLeft = sliderPosition - (tooltipWidth / 2);

    // Keep tooltip within screen bounds
    tooltipLeft = tooltipLeft.clamp(0.0, screenWidth - 40 - tooltipWidth);

    return tooltipLeft;
  }

  double _getChevronPosition() {
    // Calculate the exact position of the chevron to align with slider thumb
    const double sliderPadding = 24.0;
    const double chevronWidth =
        32.0; // Updated to match new larger chevron size
    const double tooltipWidth = 140.0;
    const double safeMargin = 16.0; // Increased margin to avoid curved areas

    // Get screen width and calculate available slider width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth =
        screenWidth - 40 - (sliderPadding * 2); // 40 is body padding

    // Calculate exact thumb position based on slider value (1-5 range)
    final double normalizedValue = (fullnessValue - 1) / 4; // Normalize to 0-1
    final double thumbPosition =
        sliderPadding + (normalizedValue * availableWidth);

    // Get tooltip position
    final double tooltipLeft = _getTooltipPosition();
    final double tooltipRight = tooltipLeft + tooltipWidth;

    // Center chevron on thumb position
    double chevronLeft = thumbPosition - (chevronWidth / 2);

    // Ensure chevron stays well within tooltip bounds (avoid rounded corners)
    final double minChevronLeft = tooltipLeft + safeMargin;
    final double maxChevronLeft = tooltipRight - safeMargin - chevronWidth;

    chevronLeft = chevronLeft.clamp(minChevronLeft, maxChevronLeft);

    return chevronLeft;
  }

  /// Builds different UI widgets based on the type of location error
  Widget _buildLocationErrorWidget() {
    // Get colors, icons, and titles based on error type
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;

    switch (locationErrorType) {
      case GeofenceErrorType.permissionDenied:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        iconColor = Colors.red.shade700;
        icon = Icons.location_disabled;
        title = 'Location Permission Required';
        break;
      case GeofenceErrorType.locationServicesDisabled:
        backgroundColor = Colors.amber.shade50;
        borderColor = Colors.amber.shade200;
        iconColor = Colors.amber.shade700;
        icon = Icons.location_off;
        title = 'Location Services Disabled';
        break;
      case GeofenceErrorType.outsideGeofence:
        backgroundColor = Colors.yellow.shade50;
        borderColor = Colors.yellow.shade200;
        iconColor = Colors.yellow.shade800;
        icon = Icons.location_searching;
        title = 'On-Site Location Verification Required';
        break;
      case GeofenceErrorType.locationError:
      default:
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
        iconColor = Colors.grey.shade700;
        icon = Icons.error_outline;
        title = 'Location Error';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            locationErrorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          // Add action buttons for permission-related errors
          if (locationErrorType == GeofenceErrorType.permissionDenied ||
              locationErrorType ==
                  GeofenceErrorType.locationServicesDisabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Retry location check
                      if (selectedSpace != null) {
                        _checkLocationForSpace(selectedSpace!);
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Open app settings (this would require additional permissions package)
                      // For now, just show instructions
                      _showLocationSettingsDialog();
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Settings'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
          // Add developer mode indicator
          if (SpacesUtils.fakeLocation) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.developer_mode,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Developer Mode: Location check bypassed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Shows a dialog with instructions for enabling location settings
  void _showLocationSettingsDialog() {
    // Get platform-specific instructions
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    List<Widget> instructions = [
      const Text(
        'To verify your presence at study spaces, please enable location access:',
      ),
      const SizedBox(height: 16),
    ];

    if (isIOS) {
      instructions.addAll([
        const Text('For iOS:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('1. Open "Settings" app'),
        const Text('2. Scroll down and tap "StudySpaces"'),
        const Text('3. Tap "Location"'),
        const Text('4. Select "While Using App" or "Always"'),
        const Text('5. Return to StudySpaces and try again'),
        const SizedBox(height: 12),
        const Text(
          'Alternative path:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const Text(
          'Settings → Privacy & Security → Location Services → StudySpaces',
        ),
      ]);
    } else if (isAndroid) {
      instructions.addAll([
        const Text(
          'For Android:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('1. Open "Settings" app'),
        const Text('2. Tap "Apps" or "Application Manager"'),
        const Text('3. Find and tap "StudySpaces"'),
        const Text('4. Tap "Permissions"'),
        const Text('5. Tap "Location" and enable it'),
        const Text('6. Return to StudySpaces and try again'),
        const SizedBox(height: 12),
        const Text(
          'Alternative path:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const Text('Settings → Location → App permissions → StudySpaces'),
      ]);
    } else {
      // Generic instructions for web/desktop
      instructions.addAll([
        const Text(
          'For Web/Desktop:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('1. Check your browser\'s location settings'),
        const Text('2. Allow location access when prompted'),
        const Text('3. Ensure location services are enabled on your device'),
        const Text('4. Refresh the page and try again'),
      ]);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Access'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: instructions,
          ),
        ),
        actions: [
          if (isIOS || isAndroid) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show additional tip about app-specific location services
                _showLocationServicesDialog();
              },
              child: const Text('Location Services Off?'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Shows additional dialog for when location services are completely disabled
  void _showLocationServicesDialog() {
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    List<Widget> instructions = [
      const Text(
        'If location services are completely disabled on your device:',
      ),
      const SizedBox(height: 16),
    ];

    if (isIOS) {
      instructions.addAll([
        const Text('For iOS:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('1. Open "Settings" app'),
        const Text('2. Tap "Privacy & Security"'),
        const Text('3. Tap "Location Services"'),
        const Text('4. Toggle "Location Services" ON'),
        const Text('5. Return to StudySpaces and try again'),
      ]);
    } else {
      instructions.addAll([
        const Text(
          'For Android:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('1. Open "Settings" app'),
        const Text('2. Tap "Location" or "Security & Location"'),
        const Text('3. Toggle "Use location" or "Location" ON'),
        const Text('4. Return to StudySpaces and try again'),
      ]);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: instructions,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text(
          'Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Space Fullness',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Check if any spaces are open
            if (!hasOpenSpaces) ...[
              // No spaces open message
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 80,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'It looks like no spaces are currently open.\nPlease try again later.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Regular form when spaces are open
              // Space Dropdown
              const Text(
                'Select Space:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Space>(
                    value: selectedSpace,
                    isExpanded: true,
                    hint: Text(
                      'Please select a space',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: spaces
                        .where(
                          (space) =>
                              SpacesUtils.isOpen(space.openat, space.closeat),
                        )
                        .map((space) {
                          return DropdownMenuItem<Space>(
                            value: space,
                            child: Container(
                              color: Colors.transparent,
                              child: Text(
                                space.name,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (Space? newValue) {
                      setState(() {
                        selectedSpace = newValue;
                      });
                      if (newValue != null) {
                        _checkLocationForSpace(newValue);
                      } else {
                        setState(() {
                          canReportAtCurrentLocation = false;
                          locationErrorMessage = null;
                          locationErrorType = null;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location checking status and restriction message
              if (selectedSpace != null) ...[
                if (isCheckingLocation) ...[
                  // Loading indicator while checking location
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Verifying your location...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else if (!canReportAtCurrentLocation &&
                    locationErrorMessage != null) ...[
                  // Location restriction message with different styling based on error type
                  _buildLocationErrorWidget(),
                  const SizedBox(height: 20),
                ],
              ],

              // Only show the form if user can report at current location or if location check hasn't been done
              if (selectedSpace == null ||
                  isCheckingLocation ||
                  canReportAtCurrentLocation) ...[
                // Fullness Slider
                const Center(
                  child: Text(
                    'Current Fullness Level:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),

                // Custom slider with following tooltip
                SizedBox(
                  height: 100, // Increased height to accommodate chevron
                  child: Stack(
                    clipBehavior:
                        Clip.none, // Allow tooltip to show outside bounds
                    children: [
                      // Tooltip that follows the handle
                      Positioned(
                        left: _getTooltipPosition(),
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            SpacesUtils.getFullnessText(fullnessValue.round()),
                            style: TextStyle(
                              color: ColorUtils.getFullnessTextColor(
                                fullnessValue.round(),
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Chevron pointing to slider thumb
                      Positioned(
                        left: _getChevronPosition(),
                        top:
                            42, // Position directly connected to tooltip bottom
                        child: CustomPaint(
                          size: const Size(
                            32,
                            20,
                          ), // Increased size from 24x15 to 32x20
                          painter: ChevronPainter(
                            color: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ),
                          ),
                        ),
                      ),
                      // Slider positioned below tooltip with more space
                      Positioned(
                        top: 70, // Moved down to accommodate chevron
                        left: 0,
                        right: 0,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ),
                            inactiveTrackColor: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.5),
                            thumbColor: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ),
                            overlayColor: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ).withValues(alpha: 0.2),
                            tickMarkShape: const RoundSliderTickMarkShape(
                              tickMarkRadius: 3,
                            ),
                            activeTickMarkColor: ColorUtils.getFullnessColor(
                              fullnessValue.round(),
                            ),
                            inactiveTickMarkColor: Theme.of(
                              context,
                            ).colorScheme.outline,
                            showValueIndicator: ShowValueIndicator.never,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: fullnessValue,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (double value) {
                              setState(() {
                                fullnessValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            // Primary shadow for depth
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                            // Secondary shadow for more depth
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            // Highlight shadow for 3D effect
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation:
                                0, // Remove default elevation to use custom shadows
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow:
                              selectedSpace != null &&
                                  canReportAtCurrentLocation &&
                                  !isCheckingLocation
                              ? [
                                  // Primary shadow for depth
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 1,
                                  ),
                                  // Secondary shadow for more depth
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                  // Highlight shadow for 3D effect
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                    spreadRadius: 0,
                                  ),
                                ]
                              : [
                                  // Disabled state shadow
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              selectedSpace != null &&
                                  canReportAtCurrentLocation &&
                                  !isCheckingLocation
                              ? _showSubmitDialog
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedSpace != null &&
                                    canReportAtCurrentLocation &&
                                    !isCheckingLocation
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            foregroundColor:
                                selectedSpace != null &&
                                    canReportAtCurrentLocation &&
                                    !isCheckingLocation
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.38),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation:
                                0, // Remove default elevation to use custom shadows
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows:
                                  selectedSpace != null &&
                                      canReportAtCurrentLocation &&
                                      !isCheckingLocation
                                  ? [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ], // Close the conditional block for location checking
            ], // Close the main conditional block for open spaces
          ],
        ),
      ),
    );
  }
}

// Custom painter for the downward pointing chevron
class ChevronPainter extends CustomPainter {
  final Color color;

  ChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Create a downward pointing chevron/triangle
    path.moveTo(size.width * 0.5, size.height); // Bottom center point
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ChevronPainter oldDelegate) => oldDelegate.color != color;
}
