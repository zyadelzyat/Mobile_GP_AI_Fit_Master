import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/theme_provider.dart'; // Import ThemeProvider

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel; // Stores the selected activity level

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
              "Physical Activity Level",
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
                  ActivityOption(
                    title: "Beginner",
                    isSelected: _selectedActivityLevel == "Beginner",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Beginner";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  ActivityOption(
                    title: "Intermediate",
                    isSelected: _selectedActivityLevel == "Intermediate",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Intermediate";
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  ActivityOption(
                    title: "Advance",
                    isSelected: _selectedActivityLevel == "Advance",
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = "Advance";
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()), // استبدل HomePage بالصفحة الفعلية
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