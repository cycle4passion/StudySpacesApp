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
                Navigator.of(context).pop();
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

  // Helper method to check if any libraries are currently open
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
                height: 90, // Increased height to accommodate more space
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
                    // Slider positioned below tooltip with more space
                    Positioned(
                      top: 60,
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
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
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
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
