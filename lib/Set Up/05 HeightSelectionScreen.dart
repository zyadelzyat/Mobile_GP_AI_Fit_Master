import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '06 WeightSelectionScreen.dart';

// Define color schemes for light and dark modes
class AppColors {
  // Shared colors
  static const Color selectorColor = Color(0xFFFFEB3B); // Yellow for selector
  static const Color rulerColor = Color(0xFFB39DDB); // Lavender for ruler

  // Dark mode colors
  static const Color darkBackground = Color(0xFF232323);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Colors.white54;
  static const Color darkButtonBackground = Colors.grey;
  static const Color darkButtonText = Colors.white;

  // Light mode colors
  static const Color lightBackground = Colors.white;
  static const Color lightPrimaryText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color lightButtonBackground = Colors.white;
  static const Color lightButtonText = Colors.black;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HeightSelectionApp());
}

class HeightSelectionApp extends StatelessWidget {
  const HeightSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          theme: ThemeData.light(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: AppColors.lightBackground,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
            ),
            textTheme: Typography.blackMountainView.apply(
              bodyColor: AppColors.lightPrimaryText,
              displayColor: AppColors.lightPrimaryText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.selectorColor),
            ),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: AppColors.darkBackground,
            textTheme: Typography.whiteMountainView.apply(
              bodyColor: AppColors.darkPrimaryText,
              displayColor: AppColors.darkPrimaryText,
            ),
            hintColor: AppColors.darkSecondaryText,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.selectorColor),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.selectorColor),
              titleTextStyle: TextStyle(color: AppColors.darkSecondaryText, fontSize: 12),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const HeightSelectionScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int minHeight = 100;
  final int maxHeight = 250;
  // Item extent for each height unit (1cm)
  final double itemExtent = 8.0;
  final double rulerWidth = 40.0;
  final double labelWidth = 60.0;
  final double selectorHeight = 2.0;
  final double selectorTriangleSize = 12.0;

  // The step between each displayed label (5cm)
  final int labelStep = 5;

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Calculate initial index based on selectedHeight
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
            builder: (context) => const WeightSelectionScreen(gender: ''),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving height: ${e.toString()}')),
        );
      }
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
    final buttonTextColor = isDarkMode ? AppColors.darkButtonText : AppColors.lightButtonText;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double rulerContainerHeight = (screenHeight * 0.4).clamp(250.0, 350.0);

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
                Icon(Icons.arrow_back_ios, color: AppColors.selectorColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Back",
                  style: TextStyle(color: AppColors.selectorColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        title: const Text("4.5 - A - Height"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.selectorColor,
              size: 20,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "What Is Your Height?",
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

            // Main content with height display, ruler, and button
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Height value display
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          selectedHeight.toString(),
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "cm",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Height ruler component
                  SizedBox(
                    height: rulerContainerHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Height markers on the left
                        Positioned(
                          left: MediaQuery.of(context).size.width / 2 - (rulerWidth + labelWidth + 24),
                          top: 0,
                          bottom: 0,
                          width: labelWidth,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final visibleCount = 9; // Total visible markers
                              final visibleHeights = List.generate(visibleCount, (i) {
                                return selectedHeight + (i - 4) * labelStep;
                              }).where((height) => height >= minHeight && height <= maxHeight).toList();

                              return Stack(
                                children: visibleHeights.map((height) {
                                  final offset = (selectedHeight - height) / labelStep;
                                  final position = offset * itemExtent * labelStep;
                                  final top = constraints.maxHeight / 2 + position;
                                  final isSelected = height == selectedHeight;

                                  return Positioned(
                                    left: 0,
                                    top: top - 14, // Adjust for text height
                                    child: Text(
                                      height.toString(),
                                      style: TextStyle(
                                        color: isSelected ? primaryTextColor : secondaryTextColor,
                                        fontSize: isSelected ? 24 : 20,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // Ruler and selector - centered
                        Positioned(
                          left: MediaQuery.of(context).size.width / 2 - rulerWidth / 2,
                          top: 0,
                          bottom: 0,
                          width: rulerWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ruler bar
                              Container(
                                width: rulerWidth,
                                height: rulerContainerHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.rulerColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
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
                                        final height = minHeight + index;
                                        if (height < minHeight || height > maxHeight) {
                                          return const SizedBox.shrink();
                                        }

                                        final bool isLabeledHeight = height % 5 == 0;
                                        final lineColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

                                        return Container(
                                          height: itemExtent,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 1.0,
                                                width: isLabeledHeight ? rulerWidth * 0.8 : rulerWidth * 0.5,
                                                color: lineColor.withOpacity(isLabeledHeight ? 0.8 : 0.4),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      childCount: maxHeight - minHeight + 1,
                                    ),
                                  ),
                                ),
                              ),

                              // Selector line
                              Positioned(
                                top: rulerContainerHeight / 2 - selectorHeight / 2,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: selectorHeight,
                                  color: AppColors.selectorColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selector triangle
                        Positioned(
                          left: MediaQuery.of(context).size.width / 2 + rulerWidth / 2 + 4,
                          top: rulerContainerHeight / 2 - selectorTriangleSize / 2,
                          child: Icon(
                            Icons.play_arrow,
                            color: AppColors.selectorColor,
                            size: selectorTriangleSize,
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
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: _saveHeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: buttonTextColor,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: buttonTextColor,
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