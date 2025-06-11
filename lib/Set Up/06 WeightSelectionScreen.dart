import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '07 GoalSelectionScreen.dart';

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
  final double itemExtent = 30.0;
  final double rulerHeight = 50.0;
  final double rulerWidth = 360.0;
  final double selectorLineHeight = 40.0;
  final double selectorLineWidth = 2.5;
  final double selectorTriangleSize = 26.0;

  late FixedExtentScrollController _scrollController;

  double get minWeight => isKg ? minWeightKg : minWeightLb;
  double get maxWeight => isKg ? maxWeightKg : maxWeightLb;

  @override
  void initState() {
    super.initState();
    selectedWeight = isKg
        ? selectedWeight.clamp(minWeightKg, maxWeightKg)
        : (selectedWeight * 2.20462).roundToDouble().clamp(minWeightLb, maxWeightLb);
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
      selectedWeight = isKg
          ? (oldWeight / 2.20462).roundToDouble()
          : (oldWeight * 2.20462).roundToDouble();
      selectedWeight = selectedWeight.clamp(minWeight, maxWeight);
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

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalSelectionScreen(gender: widget.gender),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save weight. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        print('Error saving weight: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: const Color(0xFFE2F163), size: 16),
                const SizedBox(width: 4),
                const Text("Back", style: TextStyle(color: Color(0xFFE2F163), fontSize: 16)),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: const Color(0xFFE2F163),
              size: 20,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "What Is Your Weight?",
                  style: TextStyle(
                    color: theme.textTheme.headlineLarge?.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F163),
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
                            color: isKg ? Colors.black.withOpacity(0.15) : Colors.transparent,
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
                            color: !isKg ? Colors.black.withOpacity(0.15) : Colors.transparent,
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
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: rulerWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) {
                          int labelValue = selectedWeight.round() + (i - 2);
                          if (labelValue < minWeight || labelValue > maxWeight) {
                            return const SizedBox(width: 40);
                          }

                          bool isCenterLabel = labelValue == selectedWeight.round();
                          return Text(
                            labelValue.toString(),
                            style: TextStyle(
                              color: isCenterLabel ? const Color(0xFFE2F163) : theme.textTheme.bodyMedium?.color,
                              fontSize: isCenterLabel ? 20 : 16,
                              fontWeight: isCenterLabel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        width: rulerWidth,
                        height: rulerHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: rulerWidth,
                              height: rulerHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB3A0FF).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            RotatedBox(
                              quarterTurns: -1,
                              child: SizedBox(
                                width: rulerHeight,
                                height: rulerWidth,
                                child: ListWheelScrollView.useDelegate(
                                  controller: _scrollController,
                                  itemExtent: itemExtent,
                                  onSelectedItemChanged: _onSelectedItemChanged,
                                  physics: const FixedExtentScrollPhysics(),
                                  perspective: 0.001,
                                  squeeze: 0.9,
                                  useMagnifier: false,
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final weight = minWeight + index;
                                      if (weight < minWeight || weight > maxWeight) {
                                        return const SizedBox.shrink();
                                      }

                                      final bool isMajor = weight % 5 == 0;
                                      return RotatedBox(
                                        quarterTurns: 1,
                                        child: Container(
                                          width: itemExtent,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: isMajor ? 2.0 : 1.2,
                                                height: isMajor ? rulerHeight * 0.6 : rulerHeight * 0.35,
                                                color: isMajor
                                                    ? Colors.white.withOpacity(0.9)
                                                    : Colors.white.withOpacity(0.5),
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
                            Center(
                              child: Container(
                                width: selectorLineWidth,
                                height: selectorLineHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F163),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      Icons.arrow_drop_up,
                      color: const Color(0xFFE2F163),
                      size: selectorTriangleSize,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            selectedWeight.toStringAsFixed(0),
                            style: TextStyle(
                              color: theme.textTheme.headlineLarge?.color,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isKg ? "Kg" : "Lb",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 24.0, right: 24.0),
              child: ElevatedButton(
                onPressed: _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : const Color(0xFF232323), // Your requested dark mode color
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: theme.brightness == Brightness.light
                          ? Colors.black12
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: theme.brightness == Brightness.light
                        ? Colors.black
                        : Colors.white, // White text on dark background
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
