import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/theme_provider.dart';
import 'package:untitled/ui/onboarding_screen.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveActivityLevel() async {
    try {
      if (_selectedActivityLevel == null) {
        throw Exception('Please select an activity level');
      }

      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(user.uid).set({
        'activityLevel': _selectedActivityLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
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
              "Physical Activity Level",
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
                  ActivityOption(
                    title: "Beginner",
                    isSelected: _selectedActivityLevel == "Beginner",
                    onTap: () => setState(() => _selectedActivityLevel = "Beginner"),
                    isDarkMode: isDarkMode,
                  ),
                  ActivityOption(
                    title: "Intermediate",
                    isSelected: _selectedActivityLevel == "Intermediate",
                    onTap: () => setState(() => _selectedActivityLevel = "Intermediate"),
                    isDarkMode: isDarkMode,
                  ),
                  ActivityOption(
                    title: "Advance",
                    isSelected: _selectedActivityLevel == "Advance",
                    onTap: () => setState(() => _selectedActivityLevel = "Advance"),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveActivityLevel,
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

class ActivityOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ActivityOption({super.key,
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
            color: isSelected ? const Color(0xFFE2F163) : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
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