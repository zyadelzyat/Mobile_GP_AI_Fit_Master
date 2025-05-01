import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart'; // Assuming this path is correct
import '07 GoalSelectionScreen.dart';

// Color scheme
class AppColors {
  static const Color highlightColor = Color(0xFFE2F163); // Yellow for selector
  static const Color rulerColor = Color(0xFFB3A0FF); // Purple for ruler

  // Dark mode colors
  static const Color darkBackground = Color(0xFF232323);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Colors.white54;
  static const Color darkButtonBackground = Color(0xFF3A3A3A);
  static const Color darkButtonBorder = Colors.white24;

  // Light mode colors
  static const Color lightBackground = Colors.white;
  static const Color lightPrimaryText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color lightButtonBackground = Colors.white;
  static const Color lightButtonBorder = Colors.black12;
}

class WeightSelectionScreen extends StatefulWidget {
  final String gender;
  const WeightSelectionScreen({super.key, required this.gender});

  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool isKg = true;
  double selectedWeight = 75;
  double minWeightKg = 30;
  double maxWeightKg = 150;
  double minWeightLb = 88; // Approx 40kg
  double maxWeightLb = 330; // Approx 150kg
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final double itemExtent = 30.0; // Width of each item/tick in the wheel
  // --- MODIFIED Constants for size ---
  final double rulerHeight = 50.0; // Reduced height
  final double rulerWidth = 360.0; // Keep width or adjust as needed
  final double selectorLineHeight = 40.0; // Adjusted selector height
  // --- END MODIFIED Constants ---
  final double selectorLineWidth = 2.5;
  final double selectorTriangleSize = 26.0; // Size of the triangle indicator
  late FixedExtentScrollController _scrollController;

  double get minWeight => isKg ? minWeightKg : minWeightLb;
  double get maxWeight => isKg ? maxWeightKg : maxWeightLb;

  @override
  void initState() {
    super.initState();
    // Initialize selected weight, ensuring it's within the default unit's bounds
    selectedWeight = isKg
        ? selectedWeight.clamp(minWeightKg, maxWeightKg)
        : (selectedWeight * 2.20462).roundToDouble().clamp(minWeightLb, maxWeightLb);
    // Calculate the initial index for the scroll controller based on the selected weight
    int initialIndex = (selectedWeight - minWeight).round();
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    // Calculate the new weight based on the index
    final newWeight = minWeight + index;
    // Update the state only if the weight is within bounds and has actually changed
    if (newWeight >= minWeight && newWeight <= maxWeight && newWeight != selectedWeight) {
      setState(() {
        selectedWeight = newWeight;
        HapticFeedback.selectionClick(); // Provide haptic feedback on change
      });
    }
  }

  void _toggleUnit(int index) {
    // 0 for KG, 1 for LB. Exit if already the selected unit.
    if ((index == 0 && isKg) || (index == 1 && !isKg)) return;

    setState(() {
      final oldWeight = selectedWeight;
      isKg = index == 0; // Update the unit flag

      // Convert the weight and clamp it to the new unit's bounds
      selectedWeight = isKg
          ? (oldWeight / 2.20462).roundToDouble() // Convert LB to KG
          : (oldWeight * 2.20462).roundToDouble(); // Convert KG to LB
      selectedWeight = selectedWeight.clamp(minWeight, maxWeight);

      // Recalculate the index for the scroll controller
      int newIndex = (selectedWeight - minWeight).round();
      // Recreate the scroll controller to jump to the new position smoothly
      _scrollController.dispose();
      _scrollController = FixedExtentScrollController(initialItem: newIndex);
    });
  }

  Future<void> _saveWeight() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Save weight, unit, gender, and timestamp to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'weight': selectedWeight,
        'weightUnit': isKg ? 'kg' : 'lb',
        'gender': widget.gender, // Save gender passed from previous screen
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields

      // Navigate to the next screen if save is successful and widget is still mounted
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalSelectionScreen(gender: widget.gender),
          ),
        );
      }
    } catch (e) {
      // Show error message if saving fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save weight. Please try again.')),
        );
        print('Error saving weight: $e'); // Log error for debugging
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Determine colors based on theme
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryTextColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final buttonBackgroundColor = isDarkMode ? AppColors.darkButtonBackground : AppColors.lightButtonBackground;
    final buttonBorderColor = isDarkMode ? AppColors.darkButtonBorder : AppColors.lightButtonBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove default back button
        leadingWidth: 80, // Custom width for the back button area
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell( // Custom back button
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.highlightColor, size: 16),
                const SizedBox(width: 4),
                Text("Back", style: TextStyle(color: AppColors.highlightColor, fontSize: 16)),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(), // No title in the app bar center
        centerTitle: true,
        actions: [ // Theme toggle button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.highlightColor,
              size: 20,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "What Is Your Weight?",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle/Description Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", // Placeholder text
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // KG/LB Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.highlightColor, // Use highlight color for background
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded( // KG button section
                      child: GestureDetector(
                        onTap: () => _toggleUnit(0), // Switch to KG
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // Highlight if KG is selected
                            color: isKg ? Colors.black.withOpacity(0.15) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          ),
                          child: const Text(
                            "KG",
                            style: TextStyle(
                              color: Colors.black, // Text color is always black on highlight background
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container( // Divider
                      height: 24,
                      width: 1,
                      color: Colors.black26,
                    ),
                    Expanded( // LB button section
                      child: GestureDetector(
                        onTap: () => _toggleUnit(1), // Switch to LB
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // Highlight if LB is selected
                            color: !isKg ? Colors.black.withOpacity(0.15) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          ),
                          child: const Text(
                            "LB",
                            style: TextStyle(
                              color: Colors.black, // Text color is always black on highlight background
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- MODIFIED Section: Ruler, Value Display ---
            Expanded(
              // Wrap the content Column in SingleChildScrollView to prevent overflow
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Prevent user scrolling this part
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Align content to the top within Expanded
                  children: [
                    // Weight labels above the ruler (Dynamic based on selected weight)
                    SizedBox(
                      width: rulerWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) {
                          int labelValue = selectedWeight.round() + (i - 2); // Center label on selected weight
                          // Hide labels outside the valid range
                          if (labelValue < minWeight || labelValue > maxWeight) {
                            return const SizedBox(width: 40); // Placeholder for spacing
                          }
                          bool isCenterLabel = labelValue == selectedWeight.round();
                          return Text(
                            labelValue.toString(),
                            style: TextStyle(
                              color: isCenterLabel ? AppColors.highlightColor : secondaryTextColor,
                              fontSize: isCenterLabel ? 20 : 16,
                              fontWeight: isCenterLabel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Horizontal ruler (using a rotated vertical ListWheelScrollView)
                    Center(
                      child: SizedBox(
                        width: rulerWidth,
                        height: rulerHeight, // Use the defined ruler height
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ruler background container
                            Container(
                              width: rulerWidth,
                              height: rulerHeight,
                              decoration: BoxDecoration(
                                color: AppColors.rulerColor.withOpacity(0.8), // Slightly transparent ruler
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // The scrollable wheel, rotated to appear horizontal
                            RotatedBox(
                              quarterTurns: -1, // Rotate 90 degrees counter-clockwise
                              child: SizedBox(
                                width: rulerHeight, // Width becomes the original height
                                height: rulerWidth, // Height becomes the original width
                                child: ListWheelScrollView.useDelegate(
                                  controller: _scrollController,
                                  itemExtent: itemExtent, // Width of each tick mark area
                                  onSelectedItemChanged: _onSelectedItemChanged,
                                  physics: const FixedExtentScrollPhysics(), // Snaps to items
                                  perspective: 0.001, // Minimal perspective effect
                                  squeeze: 0.9, // How much items squeeze together
                                  useMagnifier: false, // Don't use magnifier effect
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final weight = minWeight + index;
                                      // Don't build items outside the valid range
                                      if (weight < minWeight || weight > maxWeight) {
                                        return const SizedBox.shrink();
                                      }

                                      // Determine if it's a major tick (every 5 units)
                                      final bool isMajor = weight % 5 == 0;
                                      // Rotate the tick mark back to vertical
                                      return RotatedBox(
                                        quarterTurns: 1,
                                        child: Container(
                                          width: itemExtent,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // The tick mark line
                                              Container(
                                                width: isMajor ? 2.0 : 1.2, // Thicker for major ticks
                                                height: isMajor ? rulerHeight * 0.6 : rulerHeight * 0.35, // Taller for major ticks
                                                color: isMajor
                                                    ? Colors.white.withOpacity(0.9)
                                                    : Colors.white.withOpacity(0.5),
                                              ),
                                              // Optional: Label below major ticks
                                              // if (isMajor)
                                              //   Padding(
                                              //     padding: const EdgeInsets.only(top: 4.0),
                                              //     child: Text(
                                              //       weight.toStringAsFixed(0),
                                              //       style: const TextStyle(color: Colors.white70, fontSize: 10),
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    // Total number of items based on range
                                    childCount: (maxWeight - minWeight).round() + 1,
                                  ),
                                ),
                              ),
                            ),
                            // Center selector line (static)
                            Center(
                              child: Container(
                                width: selectorLineWidth,
                                height: selectorLineHeight, // Use defined height
                                decoration: BoxDecoration(
                                  color: AppColors.highlightColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Yellow triangle indicator below the ruler
                    const SizedBox(height: 10), // Space between ruler and triangle
                    Icon(
                      Icons.arrow_drop_up, // Pointing upwards towards the selected value
                      color: AppColors.highlightColor,
                      size: selectorTriangleSize,
                    ),

                    // Weight value display
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline, // Align baseline of text
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            selectedWeight.toStringAsFixed(0), // Display weight without decimals
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 64, // Large font for the value
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isKg ? "Kg" : "Lb", // Display the current unit
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- END MODIFIED Section ---

            // Continue Button (at the bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 24.0, right: 24.0),
              child: ElevatedButton(
                onPressed: _saveWeight, // Call save function on press
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: primaryTextColor, // Text color
                  minimumSize: const Size(double.infinity, 48), // Full width, standard height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: buttonBorderColor, // Subtle border
                      width: 1,
                    ),
                  ),
                  elevation: 0, // No shadow
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
