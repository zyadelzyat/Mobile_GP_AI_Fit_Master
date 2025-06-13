import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '08 activity_level_screen.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key, required String gender});

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveGoal() async {
    try {
      if (_selectedGoal == null) throw Exception('Please select a goal');
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'goal': _selectedGoal,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActivityLevelScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Is Your Goal?",
              style: TextStyle(
                color: theme.textTheme.headlineLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  GoalOption(
                    title: "Lose Weight",
                    isSelected: _selectedGoal == "Lose Weight",
                    onTap: () => setState(() => _selectedGoal = "Lose Weight"),
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Gain Weight",
                    isSelected: _selectedGoal == "Gain Weight",
                    onTap: () => setState(() => _selectedGoal = "Gain Weight"),
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Muscle Mass Gain",
                    isSelected: _selectedGoal == "Muscle Mass Gain",
                    onTap: () => setState(() => _selectedGoal = "Muscle Mass Gain"),
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Shape Body",
                    isSelected: _selectedGoal == "Shape Body",
                    onTap: () => setState(() => _selectedGoal = "Shape Body"),
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Others",
                    isSelected: _selectedGoal == "Others",
                    onTap: () => setState(() => _selectedGoal = "Others"),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveGoal,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const GoalOption({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE2F163)
                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : (isDarkMode ? Colors.white : Colors.black),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
