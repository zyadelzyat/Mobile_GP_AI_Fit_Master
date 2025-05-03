import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/theme_provider.dart';
import '05 HeightSelectionScreen.dart';

// Define color constants for both themes
class AppColors {
  // Theme-agnostic colors
  static const Color accentColor = Color(0xFFE2F163); // Yellow highlight

  // Dark mode colors
  static const Color darkBackground = Color(0xFF232323);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Colors.white54;
  static const Color darkButtonBackground = Color(0xFF3A3A3A);
  static const Color darkButtonText = Colors.white;
  static const Color darkButtonBorder = Colors.white24;
  static const Color darkMaleCircleSelected = Colors.white;
  static const Color darkFemaleCircleSelected = Color(0xFFD7F24D);
  static const Color darkCircleUnselected = Colors.transparent;
  static const Color darkBorderSelected = Colors.white;
  static const Color darkBorderUnselected = Colors.grey;

  // Light mode colors
  static const Color lightBackground = Colors.white;
  static const Color lightPrimaryText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color lightButtonBackground = Colors.white;
  static const Color lightButtonText = Colors.black;
  static const Color lightButtonBorder = Colors.black12;
  static const Color lightMaleCircleSelected = Color(0xFF9D8AD5);
  static const Color lightFemaleCircleSelected = Color(0xFFD7F24D);
  static const Color lightCircleUnselected = Colors.transparent;
  static const Color lightBorderSelected = Color(0xFF9D8AD5);
  static const Color lightBorderUnselected = Colors.grey;
}

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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Determine colors based on the current theme
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryTextColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final buttonBackgroundColor = isDarkMode ? AppColors.darkButtonBackground : AppColors.lightButtonBackground;
    final buttonTextColor = isDarkMode ? AppColors.darkButtonText : AppColors.lightButtonText;
    final buttonBorderColor = isDarkMode ? AppColors.darkButtonBorder : AppColors.lightButtonBorder;

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.accentColor, size: 16),
                const SizedBox(width: 4),
                Text("Back", style: TextStyle(color: AppColors.accentColor, fontSize: 16)),
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
              color: AppColors.accentColor,
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
            // Title section
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                "What's Your Gender",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
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
                    circleColor: selectedGender == 'Male'
                        ? (isDarkMode ? AppColors.darkMaleCircleSelected : AppColors.lightMaleCircleSelected)
                        : (isDarkMode ? AppColors.darkCircleUnselected : AppColors.lightCircleUnselected),
                    iconColor: selectedGender == 'Male'
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : primaryTextColor,
                    textColor: primaryTextColor,
                    borderColor: selectedGender == 'Male'
                        ? (isDarkMode ? AppColors.darkBorderSelected : AppColors.lightBorderSelected)
                        : (isDarkMode ? AppColors.darkBorderUnselected : AppColors.lightBorderUnselected),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderOption(
                    context: context,
                    gender: 'Female',
                    icon: Icons.female,
                    circleColor: selectedGender == 'Female'
                        ? (isDarkMode ? AppColors.darkFemaleCircleSelected : AppColors.lightFemaleCircleSelected)
                        : (isDarkMode ? AppColors.darkCircleUnselected : AppColors.lightCircleUnselected),
                    iconColor: selectedGender == 'Female' ? Colors.black : primaryTextColor,
                    textColor: primaryTextColor,
                    borderColor: selectedGender == 'Female'
                        ? (isDarkMode ? AppColors.darkFemaleCircleSelected : AppColors.lightFemaleCircleSelected)
                        : (isDarkMode ? AppColors.darkBorderUnselected : AppColors.lightBorderUnselected),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Continue button
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
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: buttonTextColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: buttonBorderColor, width: 1),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: buttonTextColor,
                  ),
                ),
              ),
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
    required Color circleColor,
    required Color iconColor,
    required Color textColor,
    required Color borderColor,
    required bool isDarkMode,
  }) {
    final isSelected = selectedGender == gender;

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
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
