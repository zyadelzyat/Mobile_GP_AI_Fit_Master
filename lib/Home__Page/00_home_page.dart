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

  Widget _buildCategoryIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalorieCalculatorPage()),
          );
        } else if (index == 5) { // Add this condition
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupplementsStorePage()),
          );
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 60 : 50,
            height: isSelected ? 60 : 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE2F163)
                  : const Color(0xFFB3A0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE2F163) : const Color(0xFFB3A0FF),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            // Modified Row with horizontal scrolling
            SizedBox(
              height: 100, // Fixed height for the category row
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryIcon(Icons.fitness_center, "Workout", 0),
                    _buildCategoryIcon(Icons.insert_chart, "Progress", 1),
                    _buildCategoryIcon(Icons.restaurant, "Nutrition", 2),
                    _buildCategoryIcon(Icons.chat, "Chat Bot", 3),
                    _buildCategoryIcon(Icons.calculate, "Calorie Calc", 4),
                    _buildCategoryIcon(Icons.store, "Supplement Store", 5), // New button
                  ],
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