import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '06 WeightSelectionScreen.dart'; // Assuming this is the correct path to the next screen [1]
import 'package:untitled/theme_provider.dart'; // Ensure this path is correct [2]

// Define color constants, separating light and dark theme colors
class AppColors {
  // Theme-agnostic colors
  static const Color selectorColor = Color(0xFFE2F163); // Yellow highlight [2]
  static const Color rulerColor = Color(0xFFB3A0FF); // Purple for ruler [2]

  // Dark mode colors
  static const Color darkBackground = Color(0xFF232323); // [2]
  static const Color darkPrimaryText = Colors.white; // [2]
  static const Color darkSecondaryText = Colors.white54; // [2]
  static const Color darkButtonBackground = Color(0xFF3A3A3A); // Darker button [1]
  static const Color darkButtonText = Colors.white; // [2]
  static const Color darkButtonBorder = Colors.white24; // Subtle border for dark button [1]

  // Light mode colors
  static const Color lightBackground = Colors.white; // [2]
  static const Color lightPrimaryText = Colors.black; // [2]
  static const Color lightSecondaryText = Colors.black54; // [2]
  static const Color lightButtonBackground = Colors.white; // White button [2]
  static const Color lightButtonText = Colors.black; // [2]
  static const Color lightButtonBorder = Colors.black12; // Subtle border for light button [1]
}

class HeightSelectionScreen extends StatefulWidget {
  // Added required gender field
  final String gender; // [2]

  // Updated constructor to require gender
  const HeightSelectionScreen({super.key, required this.gender}); // [2]

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165; // Default height in cm [2]
  final FirebaseAuth _auth = FirebaseAuth.instance; // [2]
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // [2]

  // Ruler configuration constants
  final int minHeight = 140; // cm [2]
  final int maxHeight = 200; // cm [2]
  final double itemExtent = 16.0; // Height of each item in the wheel [2]
  final double rulerWidth = 60.0; // Width of the vertical ruler bar [2]
  final double labelWidth = 60.0; // Width allocated for labels next to the ruler [2]
  final double selectorHeight = 2.0; // Height of the horizontal selector line [2]
  final double selectorTriangleSize = 18.0; // Size of the selector arrow [2]
  final int labelStep = 5; // Show labels every 5 cm [2]
  final double rulerContainerHeight = 320.0; // Fixed height for the ruler area [2]

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Ensure the initial selected height is within bounds
    selectedHeight = selectedHeight.clamp(minHeight, maxHeight);
    // Calculate the initial index based on the clamped height
    int initialIndex = selectedHeight - minHeight; // [2]
    _scrollController = FixedExtentScrollController(initialItem: initialIndex); // [2]
  }

  @override
  void dispose() {
    _scrollController.dispose(); // [2]
    super.dispose();
  }

  // Called when the user scrolls the height ruler
  void _onSelectedItemChanged(int index) {
    final newHeight = minHeight + index; // [2]
    // Update state only if the height changes and is within bounds
    if (newHeight >= minHeight && newHeight <= maxHeight && newHeight != selectedHeight) { // [2]
      setState(() {
        selectedHeight = newHeight; // [2]
        // Consider adding HapticFeedback.selectionClick() here if desired
      });
    }
  }

  // Save the selected height to Firestore and navigate
  Future<void> _saveHeight() async {
    try {
      final user = _auth.currentUser; // [2]
      if (user == null) throw Exception('User not authenticated'); // [2]

      // Save height and timestamp
      await _firestore.collection('users').doc(user.uid).set({ // [2]
        'height': selectedHeight, // [2]
        'lastUpdated': FieldValue.serverTimestamp(), // [2]
      }, SetOptions(merge: true)); // Merge to keep other user data [2]

      // Navigate to the next screen (Weight Selection) if successful
      if (mounted) { // [2]
        Navigator.push( // [2]
          context,
          MaterialPageRoute(
            // Pass the gender along, accessed via widget.gender [1, 2]
            builder: (context) => WeightSelectionScreen(gender: widget.gender), // [1]
          ),
        );
      }
    } catch (e) {
      // Show error message if saving fails
      if (mounted) { // [2]
        ScaffoldMessenger.of(context).showSnackBar( // [2]
          SnackBar(content: Text('Error saving height: ${e.toString()}')), // [2]
        );
        print('Error saving height: $e'); // Log for debugging
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context); // [2]
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark; // [2]

    // Determine colors based on the current theme
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground; // [2]
    final primaryTextColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText; // [2]
    final secondaryTextColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText; // [2]
    final buttonBackgroundColor = isDarkMode ? AppColors.darkButtonBackground : AppColors.lightButtonBackground; // [2]
    final buttonTextColor = isDarkMode ? AppColors.darkButtonText : AppColors.lightButtonText; // [2]
    final buttonBorderColor = isDarkMode ? AppColors.darkButtonBorder : AppColors.lightButtonBorder; // Using button border colors [1]

    // Access MediaQuery only once if needed multiple times
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor, // [2]
      appBar: AppBar(
        backgroundColor: backgroundColor, // [2]
        elevation: 0, // [2]
        automaticallyImplyLeading: false, // Remove default back button
        leadingWidth: 80, // Custom width for the back button area
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell( // Custom back button using InkWell for tap effect [2]
            onTap: () => Navigator.pop(context), // [2]
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.selectorColor, size: 16), // [2]
                const SizedBox(width: 4),
                Text("Back", style: TextStyle(color: AppColors.selectorColor, fontSize: 16)), // [2]
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(), // No title in the app bar center
        centerTitle: true,
        actions: [ // Add theme toggle button to actions
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode, // Icon changes based on theme [1]
              color: AppColors.selectorColor, // Use highlight color for the icon [2]
              size: 20,
            ),
            // Call toggleTheme method from the provider
            onPressed: () => themeProvider.toggleTheme(), // [1]
          ),
          const SizedBox(width: 8), // Add some padding to the right
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Screen Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // [2]
              child: Center(
                child: Text(
                  "What Is Your Height?", // [2]
                  style: TextStyle(
                    color: primaryTextColor, // [2]
                    fontSize: 24, // [2]
                    fontWeight: FontWeight.bold, // [2]
                  ),
                  textAlign: TextAlign.center, // [2]
                ),
              ),
            ),
            const SizedBox(height: 10), // [2]

            // Screen Subtitle/Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // [2]
              child: Center(
                child: Text(
                  // Updated placeholder text
                  "Select your height using the ruler below. This helps in personalizing your experience.",
                  style: TextStyle(
                    color: secondaryTextColor, // [2]
                    fontSize: 12, // [2]
                  ),
                  textAlign: TextAlign.center, // [2]
                ),
              ),
            ),
            const SizedBox(height: 24), // [2]

            // Selected Height Value Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // [2]
              crossAxisAlignment: CrossAxisAlignment.baseline, // Align text baselines [2]
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  selectedHeight.toString(), // [2]
                  style: TextStyle(
                    color: primaryTextColor, // [2]
                    fontSize: 64, // Large font for the value [2]
                    fontWeight: FontWeight.bold, // [2]
                  ),
                ),
                const SizedBox(width: 6), // [2]
                Text(
                  "Cm", // Unit display [2]
                  style: TextStyle(
                    color: primaryTextColor, // Use primary color for unit as well [2]
                    fontSize: 22, // [2]
                    fontWeight: FontWeight.w500, // Slightly less bold than the value
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // [2]

            // Ruler Section (takes remaining space)
            Expanded( // [2]
              child: Center(
                child: SizedBox(
                  height: rulerContainerHeight, // Use constant height [2]
                  child: Stack(
                    alignment: Alignment.center, // [2]
                    children: [
                      // Height labels on the left side of the ruler
                      Positioned(
                        // Calculate position to be left of the ruler
                          left: screenWidth / 2 - (rulerWidth / 2 + labelWidth + 8), // Position left of ruler with padding [2]
                          top: 0, // [2]
                          bottom: 0, // [2]
                          width: labelWidth, // [2]
                          child: Center( // Center the labels vertically
                            child: TickerHeightLabels(
                              minHeight: minHeight, // [2]
                              maxHeight: maxHeight, // [2]
                              selectedHeight: selectedHeight, // [2]
                              itemExtent: itemExtent, // [2]
                              labelStep: labelStep, // [2]
                              primaryColor: primaryTextColor, // Pass theme-aware color
                              secondaryColor: secondaryTextColor, // Pass theme-aware color
                            ),
                          )
                      ),

                      // Vertical Ruler Bar and Scroll Wheel
                      Positioned(
                        // Center the ruler horizontally
                        left: screenWidth / 2 - rulerWidth / 2, // [2]
                        top: 0, // [2]
                        bottom: 0, // [2]
                        width: rulerWidth, // [2]
                        child: Stack(
                          alignment: Alignment.center, // [2]
                          children: [
                            // Ruler background
                            Container(
                              width: rulerWidth, // [2]
                              height: rulerContainerHeight, // [2]
                              decoration: BoxDecoration(
                                color: AppColors.rulerColor, // Use the defined ruler color [2]
                                borderRadius: BorderRadius.circular(14), // [2]
                              ),
                              child: ClipRRect( // Clip the scroll view to the rounded corners
                                borderRadius: BorderRadius.circular(14), // [2]
                                child: ListWheelScrollView.useDelegate(
                                  controller: _scrollController, // [2]
                                  itemExtent: itemExtent, // Height of each tick/item [2]
                                  onSelectedItemChanged: _onSelectedItemChanged, // [2]
                                  physics: const FixedExtentScrollPhysics(), // Snapping effect [2]
                                  perspective: 0.001, // Minimal 3D effect [2]
                                  squeeze: 0.9, // How much items compress vertically [2]
                                  useMagnifier: false, // No magnifier effect [2]
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final height = minHeight + index; // [2]
                                      // Don't build items outside the valid range
                                      if (height < minHeight || height > maxHeight) { // [2]
                                        return const SizedBox.shrink(); // [2]
                                      }

                                      // Determine if it's a major tick (every 5 units)
                                      final bool isMajorTick = height % labelStep == 0; // [2]
                                      // Use white for ticks, with different opacity
                                      final tickColor = Colors.white; // [2]

                                      // Return a container representing the tick mark
                                      return Container(
                                        height: itemExtent, // [2]
                                        alignment: Alignment.center, // Center the tick horizontally [2]
                                        child: Container(
                                          height: 1.5, // Thickness of the tick [2]
                                          // Width depends on whether it's a major tick
                                          width: isMajorTick ? rulerWidth * 0.7 : rulerWidth * 0.4, // [2]
                                          // Opacity depends on whether it's a major tick
                                          color: tickColor.withOpacity(isMajorTick ? 0.8 : 0.4), // [2]
                                        ),
                                      );
                                    },
                                    // Total number of items based on height range
                                    childCount: maxHeight - minHeight + 1, // [2]
                                  ),
                                ),
                              ),
                            ),

                            // Static Selector Line (Yellow) - Overlays the center
                            Positioned(
                              // Position exactly in the vertical center
                              top: rulerContainerHeight / 2 - selectorHeight / 2, // [2]
                              left: 0, // [2]
                              right: 0, // [2]
                              child: Container(
                                height: selectorHeight, // [2]
                                color: AppColors.selectorColor, // Use highlight color [2]
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selector Triangle/Arrow (pointing from the right)
                      Positioned(
                        // Position to the right of the ruler bar
                        left: screenWidth / 2 + rulerWidth / 2 + 8, // Ruler center + half width + padding [2]
                        // Align vertically with the selector line
                        top: rulerContainerHeight / 2 - selectorTriangleSize / 2, // [2]
                        child: Icon(
                          Icons.play_arrow, // Right-pointing arrow [2]
                          color: AppColors.selectorColor, // Use highlight color [2]
                          size: selectorTriangleSize, // [2]
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Continue Button (at the bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10.0, left: 24.0, right: 24.0), // Added top padding [2]
              child: ElevatedButton(
                onPressed: _saveHeight, // Call save function on press [2]
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor, // Theme-dependent background [2]
                  foregroundColor: buttonTextColor, // Theme-dependent text/icon color [2]
                  minimumSize: const Size(double.infinity, 48), // Full width, standard height [2]
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // [2]
                    // Apply theme-dependent border
                    side: BorderSide(color: buttonBorderColor, width: 1), // [1]
                  ),
                  elevation: 0, // No shadow [2]
                ),
                child: Text(
                  "Continue", // [2]
                  style: TextStyle(
                    color: buttonTextColor, // Use theme-dependent text color [2]
                    fontSize: 16, // [2]
                    fontWeight: FontWeight.bold, // [2]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Helper widget for rendering height labels dynamically next to the ruler
class TickerHeightLabels extends StatelessWidget {
  final int minHeight;
  final int maxHeight;
  final int selectedHeight;
  final double itemExtent;
  final int labelStep;
  final Color primaryColor; // Expecting theme-aware color
  final Color secondaryColor; // Expecting theme-aware color
  // Assuming the same fixed height as used in the main build method
  final double rulerContainerHeight = 320.0;

  const TickerHeightLabels({
    super.key,
    required this.minHeight,
    required this.maxHeight,
    required this.selectedHeight,
    required this.itemExtent,
    required this.labelStep,
    required this.primaryColor, // Receive primary text color
    required this.secondaryColor, // Receive secondary text color
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder( // Use LayoutBuilder to get constraints [2]
      builder: (context, constraints) {
        // Use constraints.maxHeight which reflects the actual height available
        final double actualContainerHeight = constraints.maxHeight;
        List<Widget> labels = [];

        // Generate labels around the selected height
        for (int height = minHeight; height <= maxHeight; height += labelStep) { // [2]
          // Calculate vertical offset relative to the center based on height difference
          final offsetFromSelected = selectedHeight - height; // [2]
          // Pixels away from the center line
          final position = offsetFromSelected * itemExtent; // [2]
          // Calculate the top position: center - offset - half label height (approx 10-12)
          final labelTopPosition = actualContainerHeight / 2 - position - 10; // Adjusted for center [2]

          // Check if the label is within the visible bounds of the container
          // Allow slight overflow for smoother appearance during scroll
          if (labelTopPosition >= -20 && labelTopPosition <= actualContainerHeight + 20) {
            final bool isSelectedLabel = height == selectedHeight; // [2]
            labels.add(
              Positioned( // [2]
                right: 0, // Align labels to the right edge of their container [2]
                top: labelTopPosition, // [2]
                child: Text(
                  height.toString(), // [2]
                  style: TextStyle(
                    // Use passed-in theme-aware colors
                    color: isSelectedLabel ? primaryColor : secondaryColor, // [2]
                    fontSize: isSelectedLabel ? 18 : 14, // Highlight selected label [2]
                    fontWeight: isSelectedLabel ? FontWeight.bold : FontWeight.normal, // [2]
                  ),
                ),
              ),
            );
          }
        }
        // Use a Stack to allow Positioned widgets
        return Stack(children: labels); // [2]
      },
    );
  }
}
