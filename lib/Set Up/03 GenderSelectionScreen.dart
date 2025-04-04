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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors to match the new design
    final backgroundColor = const Color(0xFF232323); // Updated background color
    final textColor = Colors.white;
    final purpleHeaderColor = const Color(0xFF9D8AD5);
    final maleCircleColor = Colors.transparent;
    final maleIconColor = Colors.white;
    final maleBorderColor = Colors.white;
    final femaleCircleColor = const Color(0xFFD7F24D); // Bright lime green/yellow
    final femaleIconColor = Colors.black;
    final buttonColor = const Color(0xFF333333);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  color: textColor,
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
                    circleColor: maleCircleColor,
                    iconColor: maleIconColor,
                    textColor: textColor,
                    borderColor: maleBorderColor,
                  ),

                  const SizedBox(height: 20),

                  _buildGenderOption(
                    context: context,
                    gender: 'Female',
                    icon: Icons.female,
                    circleColor: femaleCircleColor,
                    iconColor: femaleIconColor,
                    textColor: textColor,
                    borderColor: femaleCircleColor,
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
                        builder: (context) => const HeightSelectionScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select your gender"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
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

  Widget _buildGenderOption({
    required BuildContext context,
    required String gender,
    required IconData icon,
    required Color circleColor,
    required Color iconColor,
    required Color textColor,
    required Color borderColor,
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