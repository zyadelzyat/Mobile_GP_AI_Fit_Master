import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider
import '08 activity_level_screen.dart'; // Import ActivityLevelScreen

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal; // Store the selected goal

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white, // Dynamic background
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF232323) : Colors.white, // Dynamic app bar
        elevation: 0, // Remove AppBar shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black), // Dynamic back icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black, // Dynamic theme toggle icon
            ),
            onPressed: () {
              themeProvider.toggleTheme(); // Toggle theme
            },
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
                color: isDarkMode ? Colors.white : Colors.black, // Dynamic title color
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(
                color: isDarkMode ? Colors.grey : Colors.black54, // Dynamic subtitle color
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
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Lose Weight";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Gain Weight",
                    isSelected: _selectedGoal == "Gain Weight",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Gain Weight";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Muscle Mass Gain",
                    isSelected: _selectedGoal == "Muscle Mass Gain",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Muscle Mass Gain";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Shape Body",
                    isSelected: _selectedGoal == "Shape Body",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Shape Body";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  GoalOption(
                    title: "Others",
                    isSelected: _selectedGoal == "Others",
                    onTap: () {
                      setState(() {
                        _selectedGoal = "Others";
                      });
                    },
                    isDarkMode: isDarkMode,
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
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white, // White in light mode
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Black in light mode
                    fontSize: 16,
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

  const GoalOption({super.key,
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
            color: isSelected ? const Color(0xFFE2F163) : (isDarkMode ? Colors.grey[800] : Colors.grey[200]), // Dynamic background
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : (isDarkMode ? Colors.white : Colors.black), // Dynamic text color
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