import 'package:flutter/material.dart';
import '05 HeightSelectionScreen.dart';

void main() {
  runApp(const GenderSelectionApp());
}

class GenderSelectionApp extends StatelessWidget {
  const GenderSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GenderSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Set background to #232323
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Set AppBar background to #232323
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title outside the box
          const Text(
            "What's Your Gender",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Purple background behind description
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20), // Add some margin for spacing
            decoration: BoxDecoration(
              color: const Color(0xFFB39DDB), // Light purple background color
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 40),
          GenderOption(
            icon: Icons.male,
            label: "Male",
            baseColor: Colors.white,
            selectedColor: const Color(0xFFE2F163),
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
            baseColor: Colors.white,
            selectedColor: const Color(0xFFE2F163),
            isSelected: selectedGender == 'Female',
            onTap: () {
              setState(() {
                selectedGender = 'Female';
              });
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (selectedGender != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeightSelectionScreen(), // Navigate to AgeSelectionScreen
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
              backgroundColor: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 16),
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
    final currentColor = isSelected ? selectedColor : baseColor;

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
                        ? currentColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: currentColor,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: TextStyle(
                    color: currentColor,
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