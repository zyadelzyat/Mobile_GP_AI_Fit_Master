import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '06 WeightSelectionScreen.dart';
import 'package:untitled/theme_provider.dart';

class HeightSelectionScreen extends StatefulWidget {
  final String gender;
  const HeightSelectionScreen({super.key, required this.gender});

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int minHeight = 140;
  final int maxHeight = 200;
  final double itemExtent = 16.0;
  final double rulerWidth = 60.0;
  final double labelWidth = 60.0;
  final double selectorHeight = 2.0;
  final double selectorTriangleSize = 18.0;
  final int labelStep = 5;
  final double rulerContainerHeight = 320.0;

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedHeight = selectedHeight.clamp(minHeight, maxHeight);
    int initialIndex = selectedHeight - minHeight;
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    final newHeight = minHeight + index;
    if (newHeight >= minHeight && newHeight <= maxHeight && newHeight != selectedHeight) {
      setState(() {
        selectedHeight = newHeight;
      });
    }
  }

  Future<void> _saveHeight() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'height': selectedHeight,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeightSelectionScreen(gender: widget.gender),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving height: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        print('Error saving height: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;

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
              mainAxisAlignment: MainAxisAlignment.start,
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
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "What Is Your Height?",
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
                  "Select your height using the ruler below. This helps in personalizing your experience.",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  selectedHeight.toString(),
                  style: TextStyle(
                    color: theme.textTheme.headlineLarge?.color,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Cm",
                  style: TextStyle(
                    color: theme.textTheme.headlineLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: rulerContainerHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: screenWidth / 2 - (rulerWidth / 2 + labelWidth + 8),
                        top: 0,
                        bottom: 0,
                        width: labelWidth,
                        child: Center(
                          child: TickerHeightLabels(
                            minHeight: minHeight,
                            maxHeight: maxHeight,
                            selectedHeight: selectedHeight,
                            itemExtent: itemExtent,
                            labelStep: labelStep,
                            primaryColor: theme.textTheme.headlineLarge?.color ?? Colors.black,
                            secondaryColor: theme.textTheme.bodyMedium?.color ?? Colors.grey,
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth / 2 - rulerWidth / 2,
                        top: 0,
                        bottom: 0,
                        width: rulerWidth,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: rulerWidth,
                              height: rulerContainerHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB3A0FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
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
                                      final height = minHeight + index;
                                      if (height < minHeight || height > maxHeight) {
                                        return const SizedBox.shrink();
                                      }

                                      final bool isMajorTick = height % labelStep == 0;
                                      const tickColor = Colors.white;

                                      return Container(
                                        height: itemExtent,
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 1.5,
                                          width: isMajorTick ? rulerWidth * 0.7 : rulerWidth * 0.4,
                                          color: tickColor.withOpacity(isMajorTick ? 0.8 : 0.4),
                                        ),
                                      );
                                    },
                                    childCount: maxHeight - minHeight + 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: rulerContainerHeight / 2 - selectorHeight / 2,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: selectorHeight,
                                color: const Color(0xFFE2F163),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: screenWidth / 2 + rulerWidth / 2 + 8,
                        top: rulerContainerHeight / 2 - selectorTriangleSize / 2,
                        child: Icon(
                          Icons.play_arrow,
                          color: const Color(0xFFE2F163),
                          size: selectorTriangleSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 30.0, top: 10.0, left: 24.0, right: 24.0),
                child: ElevatedButton(
                  onPressed: _saveHeight,
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

class TickerHeightLabels extends StatelessWidget {
  final int minHeight;
  final int maxHeight;
  final int selectedHeight;
  final double itemExtent;
  final int labelStep;
  final Color primaryColor;
  final Color secondaryColor;
  final double rulerContainerHeight = 320.0;

  const TickerHeightLabels({
    super.key,
    required this.minHeight,
    required this.maxHeight,
    required this.selectedHeight,
    required this.itemExtent,
    required this.labelStep,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double actualContainerHeight = constraints.maxHeight;
        List<Widget> labels = [];

        for (int height = minHeight; height <= maxHeight; height += labelStep) {
          final offsetFromSelected = selectedHeight - height;
          final position = offsetFromSelected * itemExtent;
          final labelTopPosition = actualContainerHeight / 2 - position - 10;

          if (labelTopPosition >= -20 && labelTopPosition <= actualContainerHeight + 20) {
            final bool isSelectedLabel = height == selectedHeight;

            labels.add(
              Positioned(
                right: 0,
                top: labelTopPosition,
                child: Text(
                  height.toString(),
                  style: TextStyle(
                    color: isSelectedLabel ? primaryColor : secondaryColor,
                    fontSize: isSelectedLabel ? 18 : 14,
                    fontWeight: isSelectedLabel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }
        }

        return Stack(children: labels);
      },
    );
  }
}