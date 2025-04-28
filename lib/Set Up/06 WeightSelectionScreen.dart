import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '07 GoalSelectionScreen.dart';

// Define color schemes for light and dark modes
class AppColors {
  // Shared colors
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
  double minWeightLb = 88;
  double maxWeightLb = 330;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Item extent for each weight unit (1kg/1lb)
  final double itemExtent = 15.0;
  final double rulerHeight = 60.0; // Height of horizontal ruler
  final double rulerWidth = 300.0; // Width of horizontal ruler
  final double selectorWidth = 4.0; // Width of the selector line
  final double selectorHeight = 60.0; // Height of the selector line

  // The step between each displayed label (5kg/5lb)
  final int labelStep = 5;

  late FixedExtentScrollController _scrollController;

  double get minWeight => isKg ? minWeightKg : minWeightLb;
  double get maxWeight => isKg ? maxWeightKg : maxWeightLb;

  @override
  void initState() {
    super.initState();

    // Set initial weight based on unit
    selectedWeight = isKg
        ? selectedWeight.clamp(minWeightKg, maxWeightKg)
        : (selectedWeight * 2.20462).roundToDouble().clamp(minWeightLb, maxWeightLb);

    // Calculate initial index based on selectedWeight
    int initialIndex = (selectedWeight - minWeight).round();
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    final newWeight = minWeight + index;
    if (newWeight >= minWeight && newWeight <= maxWeight && newWeight != selectedWeight) {
      setState(() {
        selectedWeight = newWeight;
        HapticFeedback.selectionClick();
      });
    }
  }

  void _toggleUnit(int index) {
    if ((index == 0 && isKg) || (index == 1 && !isKg)) return;

    setState(() {
      final oldWeight = selectedWeight;
      isKg = index == 0;

      // Convert weight between units
      selectedWeight = isKg
          ? (oldWeight / 2.20462).roundToDouble()
          : (oldWeight * 2.20462).roundToDouble();
      selectedWeight = selectedWeight.clamp(minWeight, maxWeight);

      // Reset scroll controller with new index
      int newIndex = (selectedWeight - minWeight).round();
      _scrollController.dispose();
      _scrollController = FixedExtentScrollController(initialItem: newIndex);
    });
  }

  Future<void> _saveWeight() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'weight': selectedWeight,
        'weightUnit': isKg ? 'kg' : 'lb',
        'gender': widget.gender,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalSelectionScreen(gender: widget.gender),
        ),
      );
    } catch (e) {
      print('Error saving weight: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save weight. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Theme-based colors
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
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.highlightColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Back",
                  style: TextStyle(color: AppColors.highlightColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        title: const Text("4.5 - B - Weight"),
        centerTitle: true,
        actions: [
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "What Is Your Weight?",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // KG/LB Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.highlightColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleUnit(0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isKg ? Colors.black12 : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          ),
                          child: const Text(
                            "KG",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.black26,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleUnit(1),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isKg ? Colors.black12 : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          ),
                          child: const Text(
                            "LB",
                            style: TextStyle(
                              color: Colors.black,
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

            // Main content with weight display and horizontal ruler
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weight value display
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          selectedWeight.toStringAsFixed(0),
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isKg ? "kg" : "lb",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal weight ruler component
                  SizedBox(
                    height: 120, // Container height for ruler and labels
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Horizontal Ruler
                        Container(
                          height: rulerHeight,
                          width: double.infinity,
                          color: AppColors.rulerColor,
                          child: RotatedBox(
                            quarterTurns: 3, // Rotate to make horizontal
                            child: ListWheelScrollView.useDelegate(
                              controller: _scrollController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: _onSelectedItemChanged,
                              physics: const FixedExtentScrollPhysics(),
                              perspective: 0.001,
                              squeeze: 1.0,
                              useMagnifier: false,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final weight = minWeight + index;
                                  if (weight < minWeight || weight > maxWeight) {
                                    return const SizedBox.shrink();
                                  }

                                  final bool isLabeledWeight = weight % 5 == 0;
                                  final lineColor = Colors.white;

                                  return Container(
                                    width: itemExtent,
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Container(
                                        width: 1.0, // Line thickness
                                        height: isLabeledWeight ? rulerHeight * 0.6 : rulerHeight * 0.3,
                                        color: lineColor.withOpacity(isLabeledWeight ? 0.8 : 0.4),
                                      ),
                                    ),
                                  );
                                },
                                childCount: (maxWeight - minWeight).round() + 1,
                              ),
                            ),
                          ),
                        ),

                        // Yellow selector line
                        Positioned(
                          left: 0,
                          right: 0,
                          child: Container(
                            height: rulerHeight,
                            width: selectorWidth,
                            alignment: Alignment.center,
                            child: Container(
                              width: 4,
                              height: rulerHeight,
                              color: AppColors.highlightColor,
                            ),
                          ),
                        ),

                        // Weight labels below the ruler
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (i) {
                              final labelWeight = selectedWeight.round() + (i - 3) * 10;
                              if (labelWeight < minWeight || labelWeight > maxWeight) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                labelWeight.toString(),
                                style: TextStyle(
                                  color: labelWeight == selectedWeight.round()
                                      ? primaryTextColor
                                      : secondaryTextColor,
                                  fontSize: labelWeight == selectedWeight.round() ? 16 : 12,
                                  fontWeight: labelWeight == selectedWeight.round()
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 24.0, right: 24.0),
              child: ElevatedButton(
                onPressed: _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: primaryTextColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: buttonBorderColor,
                      width: 1,
                    ),
                  ),
                  elevation: 0,
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