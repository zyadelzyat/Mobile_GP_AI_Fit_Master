import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '06 WeightSelectionScreen.dart';

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
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
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

class _HeightSelectionScreenState extends State<HeightSelectionScreen> with SingleTickerProviderStateMixin {
  int selectedHeight = 165;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Scrollable ruler settings
  final double rulerWidth = 70.0;
  final double rulerHeight = 350.0;
  final int minHeight = 140;
  final int maxHeight = 240;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Setup animation for selection indicator
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initial position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHeight(selectedHeight);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    int pixel = _scrollController.position.pixels.round();
    int newHeight = _getHeightFromScrollPosition(pixel);

    if (newHeight != selectedHeight) {
      setState(() {
        selectedHeight = newHeight;
      });

    }
  }

  int _getHeightFromScrollPosition(int pixel) {
    // Convert scroll position to height
    // The relationship is inverted: higher scroll position = lower height
    return maxHeight - (pixel / 40).round();
  }

  void _scrollToHeight(int height) {
    final scrollPos = (maxHeight - height) * 40.0;
    _scrollController.animateTo(
      scrollPos,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveHeight() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Animate button press
      _animationController.forward().then((_) => _animationController.reverse());

      await _firestore.collection('users').doc(user.uid).set({
        'height': selectedHeight,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WeightSelectionScreen(gender: ''),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving height: ${e.toString()}')),
      );
    }
  }

  Widget _buildRulerTick(int height, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    bool isMajorTick = height % 5 == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left number (shown only for major ticks or selected height)
          if (isMajorTick || isSelected)
            SizedBox(
              width: 32,
              child: Text(
                height.toString(),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: isSelected ? 16 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDarkMode ? const Color(0xFFE2F163) : Colors.blue)
                      : (isDarkMode ? Colors.white60 : Colors.black54),
                ),
              ),
            )
          else
            const SizedBox(width: 32),

          const SizedBox(width: 8),

          // Tick mark
          Container(
            width: isMajorTick ? 24 : 16,
            height: 2,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? const Color(0xFFE2F163) : Colors.blue)
                  : (isDarkMode ? Colors.white60 : Colors.black26),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Calculate background gradient colors
    final Color primaryColor = isDarkMode ? const Color(0xFF232323) : Colors.white;
    final Color secondaryColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final Color accentColor = isDarkMode ? const Color(0xFFE2F163) : Colors.blue;
    final Color rulerBgColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFE8E8E8);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: accentColor,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "What Is Your Height?",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Drag the slider to set your height for personalized recommendations.",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Large height display
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.95, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              selectedHeight.toString(),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                " cm",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Height ruler section
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onVerticalDragStart: (_) {
                        setState(() {
                          isDragging = true;
                        });
                      },
                      onVerticalDragEnd: (_) {
                        setState(() {
                          isDragging = false;
                        });
                      },
                      child: Container(
                        width: rulerWidth + 40,
                        height: rulerHeight,
                        decoration: BoxDecoration(
                          color: rulerBgColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ruler tick marks
                            ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: (maxHeight - minHeight) + 1,
                              reverse: true,  // To make it start from the bottom
                              itemExtent: 40,
                              itemBuilder: (context, index) {
                                final height = minHeight + index;
                                final isSelected = height == selectedHeight;
                                return _buildRulerTick(height, isSelected);
                              },
                            ),

                            // Center selection indicator
                            Positioned(
                              left: 0,
                              right: 0,
                              top: rulerHeight / 2 - 20,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: accentColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    bottom: BorderSide(
                                      color: accentColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Right side marker
                            Positioned(
                              right: 0,
                              top: rulerHeight / 2 - 8,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: isDragging ? 20 : 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 240,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [const Color(0xFFE2F163), const Color(0xFFB3A0FF)]
                                : [Colors.blue, Colors.blueAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _saveHeight,
                            child: Center(
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.black : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}