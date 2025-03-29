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
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'gender': gender,
        });
        print("Gender updated successfully!");
      } else {
        print("No user logged in");
      }
    } catch (error) {
      print("Error updating gender: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What's Your Gender",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GenderOption(
            icon: Icons.male,
            label: "Male",
            baseColor: Colors.blue,
            selectedColor: Colors.blue,
            isSelected: selectedGender == 'Male',
            onTap: () {
              setState(() {
                selectedGender = 'Male';
              });
            },
          ),
          const SizedBox(height: 20),
          GenderOption(
            icon: Icons.female,
            label: "Female",
            baseColor: Colors.pink,
            selectedColor: Colors.pink,
            isSelected: selectedGender == 'Female',
            onTap: () {
              setState(() {
                selectedGender = 'Female';
              });
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              if (selectedGender != null) {
                await saveGenderToFirestore(selectedGender!);
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
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Theme.of(context).cardColor : Colors.white,
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
    );
  }
}

class GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color baseColor;
  final Color selectedColor;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderOption({
    super.key,
    required this.icon,
    required this.label,
    required this.baseColor,
    required this.selectedColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? selectedColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 50,
                color: selectedColor,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: selectedColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
