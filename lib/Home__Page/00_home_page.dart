import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/profile.dart';
import 'package:untitled/theme_provider.dart';
import 'package:untitled/videos_page.dart';
import 'CalorieCalculator.dart';
import 'SupplementsStore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  // Define category data for easier management
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fitness_center, 'label': 'Workout', 'route': null},
    {'icon': Icons.insert_chart, 'label': 'Progress', 'route': null},
    {'icon': Icons.restaurant, 'label': 'Nutrition', 'route': null},
    {'icon': Icons.chat, 'label': 'Chat Bot', 'route': const ChatPage()},
    {'icon': Icons.calculate, 'label': 'Calorie Calc', 'route': CalorieCalculatorPage()},
    {'icon': Icons.store, 'label': 'Supplement Store', 'route': SupplementsStorePage()},
  ];

  Widget _buildCategoryIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;
    final themeColors = {
      'selected': const Color(0xFFE2F163),
      'unselected': const Color(0xFFB3A0FF),
      'background': const Color(0xFF232323),
    };

    // Calculate appropriate icon size based on container size to prevent overflow
    final containerSize = isSelected ? 60.0 : 50.0;
    final iconSize = containerSize * 0.5; // Ensure icon is 50% of container size

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategoryIndex = index;
          });

          final route = _categories[index]['route'];
          if (route != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: isSelected ? themeColors['selected'] : themeColors['unselected'],
                shape: BoxShape.circle,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: themeColors['selected']!.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: iconSize,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80, // Fixed width for text to prevent overflow
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? themeColors['selected'] : themeColors['unselected'],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSelected ? 14 : 12,
                ),
                textAlign: TextAlign.center, // Center the text
                overflow: TextOverflow.ellipsis, // Handle long text gracefully
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        title: const Text("Health & Fitness Tracker", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Track your fitness and health journey.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Improved category icons section with overflow protection
            Container(
              height: 120, // Increased height to prevent vertical overflow
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: List.generate(
                      _categories.length,
                          (index) => _buildCategoryIcon(
                        _categories[index]['icon'],
                        _categories[index]['label'],
                        index,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    "Select a category to explore.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
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