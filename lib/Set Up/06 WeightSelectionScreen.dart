import 'package:flutter/material.dart';
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
  double selectedWeight = 58;
  double minWeight = 50;
  double maxWeight = 300;
  late ScrollController _scrollController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveWeight() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'weight': selectedWeight,
        'weightUnit': isKg ? 'kg' : 'lb',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving weight: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _updateScrollPosition(double weight) {
    double offset = (weight - minWeight) * 30;
    offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  void _scrollListener() {
    double currentOffset = _scrollController.offset;
    double weight = (minWeight + currentOffset / 30).roundToDouble();
    weight = weight.clamp(minWeight, maxWeight);
    if (weight != selectedWeight) {
      setState(() {
        selectedWeight = weight;
      });
    }
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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.yellow : Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HeightSelectionScreen()),
                (Route<dynamic> route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellow : Colors.black,
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
              onPressed: (index) => setState(() => isKg = index == 0),
              borderRadius: BorderRadius.circular(30),
              fillColor: const Color(0xFFE2F163),
              selectedColor: Colors.black,
              color: isDarkMode ? Colors.white54 : Colors.black54,
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
                    itemCount: (maxWeight - minWeight).toInt() + 1,
                    itemBuilder: (context, index) {
                      final weight = minWeight + index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeight = weight;
                            _updateScrollPosition(weight);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weight.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: selectedWeight == weight ? 24 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: selectedWeight == weight
                                      ? (isDarkMode ? Colors.yellow : Colors.blue)
                                      : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                              ),
                              if (index != (maxWeight - minWeight).toInt())
                                Container(
                                  height: 20,
                                  width: 2,
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Positioned(
                  top: -10,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.yellow,
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