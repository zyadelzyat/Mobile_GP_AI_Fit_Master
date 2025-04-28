import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '07 GoalSelectionScreen.dart';

// Define color scheme based on design
class AppColors {
  static const Color highlightColor = Color(0xFFE2F163); // Yellow
  static const Color purpleColor = Color(0xFFB3A0FF); // Purple for slider
  static const Color darkBackground = Color(0xFF232323); // Dark background
  static const Color darkPrimaryText = Colors.white; // White text
  static const Color darkSecondaryText = Colors.white54; // Light grey text
  static const Color darkButtonBackground = Color(0xFF3A3A3A); // Dark grey button
  static const Color darkButtonBorder = Colors.white24; // Subtle white border
  static const Color darkInactiveToggle = Color(0xFF2F2F2F); // Slightly lighter dark

  static const Color lightBackground = Colors.white;
  static const Color lightPrimaryText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color lightButtonBackground = Colors.white;
  static const Color lightButtonBorder = Colors.black12;
  static const Color lightInactiveToggle = Colors.white;
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
  double minWeightKg = 40;
  double maxWeightKg = 150;
  double minWeightLb = 88;
  double maxWeightLb = 330;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Item extent for each weight unit (1kg/1lb)
  final double itemExtent = 12.0;
  final double rulerHeight = 80.0;
  final double rulerWidth = 300.0;
  final double selectorWidth = 2.0;

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

    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryTextColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final buttonBackgroundColor = isDarkMode ? AppColors.darkButtonBackground : AppColors.lightButtonBackground;
    final buttonBorderColor = isDarkMode ? AppColors.darkButtonBorder : AppColors.lightButtonBorder;

    final rulerContainerWidth = MediaQuery.of(context).size.width - 48;

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
      ),
      body: Padding(
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
            const SizedBox(height: 40),

            // KG/LB Toggle Button
            Container(
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

            const Spacer(flex: 2),

            // Selected Weight Display
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    selectedWeight.toStringAsFixed(0),
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      isKg ? "Kg" : "Lb",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Weight ruler component
            Center(
              child: SizedBox(
                height: rulerHeight,
                width: rulerContainerWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Weight markers labels
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 30,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final visibleCount = 7; // Total visible markers
                          final visibleWeights = List.generate(visibleCount, (i) {
                            return selectedWeight.round() + (i - 3) * labelStep;
                          }).where((weight) => weight >= minWeight && weight <= maxWeight).toList();

                          return Stack(
                            children: visibleWeights.map((weight) {
                              final offset = (selectedWeight.round() - weight) / labelStep;
                              final position = offset * itemExtent * labelStep;
                              final left = constraints.maxWidth / 2 + position;
                              final isSelected = weight == selectedWeight.round();

                              return Positioned(
                                left: left - 15, // Adjust for text width
                                child: Text(
                                  weight.toString(),
                                  style: TextStyle(
                                    color: isSelected ? primaryTextColor : secondaryTextColor,
                                    fontSize: isSelected ? 18 : 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    // Ruler bar and selector
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ruler bar
                          Container(
                            width: rulerContainerWidth,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.purpleColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: RotatedBox(
                                quarterTurns: 3, // Rotate 90 degrees counter-clockwise
                                child: ListWheelScrollView.useDelegate(
                                  controller: _scrollController,
                                  itemExtent: itemExtent,
                                  onSelectedItemChanged: _onSelectedItemChanged,
                                  physics: const FixedExtentScrollPhysics(),
                                  perspective: 0.001,
                                  squeeze: 0.8,
                                  useMagnifier: false,
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final weight = minWeight + index;
                                      if (weight < minWeight || weight > maxWeight) {
                                        return const SizedBox.shrink();
                                      }

                                      final bool isLabeledWeight = weight % 5 == 0;
                                      final lineColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

                                      return RotatedBox(
                                        quarterTurns: 1, // Rotate back 90 degrees clockwise
                                        child: Container(
                                          width: itemExtent,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 1.0,
                                                height: isLabeledWeight ? 12.0 : 6.0,
                                                color: lineColor.withOpacity(isLabeledWeight ? 0.8 : 0.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: (maxWeight - minWeight).round() + 1,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Selector line
                          Positioned(
                            left: rulerContainerWidth / 2 - selectorWidth / 2,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: selectorWidth,
                              color: AppColors.highlightColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selector triangle
                    Positioned(
                      top: 80,
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(color: AppColors.highlightColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Continue Button
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBackgroundColor,
                    foregroundColor: primaryTextColor,
                    minimumSize: const Size(double.infinity, 52),
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
                      fontWeight: FontWeight.w500,
                    ),
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

// Custom painter for the yellow triangle indicator
class TrianglePainter extends CustomPainter {
  final Color color;

  const TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}