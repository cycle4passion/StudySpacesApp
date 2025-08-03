import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/libraries_data.dart';
import '../models/library.dart';
import '../utils/color_utils.dart';
import '../utils/library_utils.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback onHomePressed;
  final Library? preSelectedLibrary;

  const ReportScreen({
    super.key,
    required this.onHomePressed,
    this.preSelectedLibrary,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Library? selectedLibrary;
  double fullnessValue = 3.0;
  List<Library> libraries = [];

  @override
  void initState() {
    super.initState();
    _loadLibraries();
  }

  void _loadLibraries() {
    final Map<String, dynamic> data = json.decode(librariesJson);
    final List<dynamic> cornellLibraries = data['locations']['cornell'];
    setState(() {
      libraries = cornellLibraries.map((lib) => Library.fromJson(lib)).toList();
      // Set preselected library if provided and it's currently open
      if (widget.preSelectedLibrary != null) {
        final preselected = libraries.firstWhere(
          (lib) => lib.id == widget.preSelectedLibrary!.id,
          orElse: () => widget.preSelectedLibrary!,
        );

        // Only set as selected if the library is currently open
        if (LibraryUtils.isOpen(preselected.openat, preselected.closeat)) {
          selectedLibrary = preselected;
          // Set slider to current fullness value of the preselected library
          fullnessValue = selectedLibrary!.fullness.toDouble();
        }
        // If preselected library is closed, selectedLibrary remains null
      }
    });
  }

  void _showSubmitDialog() {
    if (selectedLibrary == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Submitted'),
          content: Text(
            '${selectedLibrary!.name}\n${fullnessValue.round()} - ${LibraryUtils.getFullnessText(fullnessValue.round())}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to home screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
  } // Helper method to check if any libraries are currently open

  bool get hasOpenLibraries {
    return libraries.any(
      (library) => LibraryUtils.isOpen(library.openat, library.closeat),
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
              'Report Library Fullness',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Check if any libraries are open
            if (!hasOpenLibraries) ...[
              // No libraries open message
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
                        'It looks like no libraries are currently open.\nPlease try again later.',
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
              // Regular form when libraries are open
              // Library Dropdown
              const Text(
                'Select Library:',
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
                  child: DropdownButton<Library>(
                    value: selectedLibrary,
                    isExpanded: true,
                    hint: Text(
                      'Please select a library',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: libraries
                        .where(
                          (library) => LibraryUtils.isOpen(
                            library.openat,
                            library.closeat,
                          ),
                        )
                        .map((library) {
                          return DropdownMenuItem<Library>(
                            value: library,
                            child: Container(
                              color: Colors.transparent,
                              child: Text(
                                library.name,
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
                    onChanged: (Library? newValue) {
                      setState(() {
                        selectedLibrary = newValue;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                          LibraryUtils.getFullnessText(fullnessValue.round()),
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
                      top: 42, // Position directly connected to tooltip bottom
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
                        boxShadow: selectedLibrary != null
                            ? [
                                // Primary shadow for depth
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.4),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: selectedLibrary != null
                            ? _showSubmitDialog
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedLibrary != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          foregroundColor: selectedLibrary != null
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.38),
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
                            shadows: selectedLibrary != null
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
            ],
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
