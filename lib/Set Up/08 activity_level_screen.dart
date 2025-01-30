import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel; // Stores the selected activity level

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Set background to #232323
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Same as background color
        elevation: 0, // Remove AppBar shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Physical Activity Level",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ActivityOption(
                    title: "Beginner",
                    isSelected: _selectedActivityLevel == "Beginner",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Beginner";
                      });
                    },
                  ),
                  ActivityOption(
                    title: "Intermediate",
                    isSelected: _selectedActivityLevel == "Intermediate",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Intermediate";
                      });
                    },
                  ),
                  ActivityOption(
                    title: "Advance",
                    isSelected: _selectedActivityLevel == "Advance",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Advance";
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen or handle the selected activity level
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF232323),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
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

  const ActivityOption({super.key, 
    required this.title,
    required this.isSelected,
    required this.onTap,
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
            color: isSelected ? const Color(0xFFE2F163) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black,
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
