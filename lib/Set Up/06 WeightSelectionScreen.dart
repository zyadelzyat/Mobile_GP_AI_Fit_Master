import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '07 GoalSelectionScreen.dart';
import '05 HeightSelectionScreen.dart';

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
  late ScrollController _scrollController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final double itemWidth = 60;
  DateTime? _lastScrollUpdate;

  double get minWeight => isKg ? minWeightKg : minWeightLb;
  double get maxWeight => isKg ? maxWeightKg : maxWeightLb;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save weight. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollPosition(selectedWeight);
    });
  }

  void _updateScrollPosition(double weight) {
    double offset = (weight - minWeight) * itemWidth;
    if (_scrollController.hasClients) {
      offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuad,
      );
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final now = DateTime.now();
    if (_lastScrollUpdate != null &&
        now.difference(_lastScrollUpdate!).inMilliseconds < 100) {
      return;
    }
    _lastScrollUpdate = now;

    double currentOffset = _scrollController.offset;
    int weightIndex = (currentOffset / itemWidth).round();
    double weight = minWeight + weightIndex;
    weight = weight.clamp(minWeight, maxWeight);
    if (weight != selectedWeight) {
      setState(() {
        selectedWeight = weight;
        HapticFeedback.selectionClick();
      });
      _updateScrollPosition(weight);
    }
  }

  void _toggleUnit(int index) {
    setState(() {
      final oldWeight = selectedWeight;
      isKg = index == 0;
      selectedWeight = isKg
          ? (oldWeight / 2.20462).roundToDouble()
          : (oldWeight * 2.20462).roundToDouble();
      selectedWeight = selectedWeight.clamp(minWeight, maxWeight);
      _updateScrollPosition(selectedWeight);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    const highlightColor = Color(0xFFE2F163);
    final nonSelectedColor = isDarkMode
        ? highlightColor.withOpacity(0.5) // Dimmed #E2F163 for dark mode
        : const Color(0xFFB3A0FF); // Purple for light mode

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? highlightColor : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? highlightColor : Colors.black,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What Is Your Weight?",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Select your weight from the options below.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ToggleButtons(
              isSelected: [isKg, !isKg],
              onPressed: _toggleUnit,
              borderRadius: BorderRadius.circular(30),
              fillColor: isDarkMode ? highlightColor.withOpacity(0.3) : highlightColor,
              selectedColor: Colors.black,
              color: nonSelectedColor, // Colorful non-selected state
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("KG", style: TextStyle(fontSize: 18)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("LB", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFFB3A0FF) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2 - itemWidth / 2,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: (maxWeight - minWeight).toInt() + 1,
                    itemBuilder: (context, index) {
                      final weight = minWeight + index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeight = weight;
                            HapticFeedback.selectionClick();
                            _updateScrollPosition(weight);
                          });
                        },
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weight.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: selectedWeight == weight ? 28 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: selectedWeight == weight
                                      ? highlightColor
                                      : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 5, // Adjusted to center arrow above number
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: highlightColor,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "${selectedWeight.toStringAsFixed(0)} ${isKg ? "Kg" : "Lb"}",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}