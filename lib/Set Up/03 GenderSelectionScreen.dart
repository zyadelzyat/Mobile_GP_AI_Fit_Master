import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '05 HeightSelectionScreen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  Future<void> saveGenderToFirestore(String gender) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'gender': gender,
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating gender: $error"),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                "What's Your Gender",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildGenderOption(
                    context: context,
                    gender: 'Male',
                    icon: Icons.male,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderOption(
                    context: context,
                    gender: 'Female',
                    icon: Icons.female,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedGender != null) {
                      await saveGenderToFirestore(selectedGender!);
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeightSelectionScreen(gender: selectedGender!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please select your gender",
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          backgroundColor: theme.colorScheme.surface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
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

  Widget _buildGenderOption({
    required BuildContext context,
    required String gender,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedGender == gender;

    Color circleColor;
    Color iconColor;
    Color borderColor;

    if (isSelected) {
      if (gender == 'Male') {
        circleColor = isDarkMode ? Colors.white : const Color(0xFF9D8AD5);
        iconColor = isDarkMode ? Colors.black : Colors.white;
        borderColor = isDarkMode ? Colors.white : const Color(0xFF9D8AD5);
      } else {
        circleColor = const Color(0xFFD7F24D);
        iconColor = Colors.black;
        borderColor = const Color(0xFFD7F24D);
      }
    } else {
      circleColor = Colors.transparent;
      iconColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
      borderColor = theme.brightness == Brightness.light ? Colors.grey : Colors.grey;
    }

    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}