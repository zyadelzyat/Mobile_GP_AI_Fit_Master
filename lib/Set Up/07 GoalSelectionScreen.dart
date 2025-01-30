import 'package:flutter/material.dart';
import '08 activity_level_screen.dart'; // تأكد من استيراد شاشة Activity Level

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal; // Store the selected goal

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
              "What Is Your Goal?",
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
                  GoalOption(
                    title: "Lose Weight",
                    isSelected: _selectedGoal == "Lose Weight",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Lose Weight";
                      });
                    },
                  ),
                  GoalOption(
                    title: "Gain Weight",
                    isSelected: _selectedGoal == "Gain Weight",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Gain Weight";
                      });
                    },
                  ),
                  GoalOption(
                    title: "Muscle Mass Gain",
                    isSelected: _selectedGoal == "Muscle Mass Gain",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Muscle Mass Gain";
                      });
                    },
                  ),
                  GoalOption(
                    title: "Shape Body",
                    isSelected: _selectedGoal == "Shape Body",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Shape Body";
                      });
                    },
                  ),
                  GoalOption(
                    title: "Others",
                    isSelected: _selectedGoal == "Others",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Others";
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivityLevelScreen()),
                  );
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

class GoalOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalOption({super.key, 
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
