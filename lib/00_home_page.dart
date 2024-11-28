import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF232323), // Background color for the main screen
      appBar: AppBar(
        backgroundColor: Color(0xFF232323),
        elevation: 0,
        title: Text(
          "Hi, Madison",
          style: TextStyle(
            color: Color(0xFF896CFE), // Text color
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF896CFE)), // Search icon
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF896CFE)), // Notifications icon
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF896CFE)), // Profile icon
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "It's time to challenge your limits.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryIcon(Icons.fitness_center, "Workout", 0),
                _buildCategoryIcon(Icons.insert_chart, "Progress", 1),
                _buildCategoryIcon(Icons.restaurant, "Nutrition", 2),
                _buildCategoryIcon(Icons.chat, "Chat Bot", 3),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Recommendations",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            _buildRecommendationCards(),
            SizedBox(height: 20),
            _buildWeeklyChallengeCard(),
          ],
        ),
      ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFB3A0FF), // Purple background
          unselectedItemColor: Colors.white, // White color for unselected icons
          showSelectedLabels: false, // Hide selected labels
          showUnselectedLabels: false, // Hide unselected labels
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
             });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // Home icon
              label: '', // Label hidden
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), // Progress icon
              label: '', // Label hidden
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star), // Goals icon
              label: '', // Label hidden
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat), // Chat icon
              label: '', // Label hidden
            ),
          ],
        ),
      );
  }

  Widget _buildCategoryIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isSelected
                ? Color(0xFFE2F163) // Selected state color
                : Color(0xFFB3A0FF), // Default state color
            child: Icon(icon, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFE2F163) : Color(0xFFB3A0FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String duration, String kcal) {
    return Card(
      color: Color(0xFF4E4E4E),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(Icons.fitness_center, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              "$duration | $kcal",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRecommendationCard("Squat Exercise", "12 Minutes", "120 Kcal"),
        _buildRecommendationCard("Full Body Stretching", "12 Minutes", "120 Kcal"),
      ],
    );
  }

  Widget _buildWeeklyChallengeCard() {
    return Card(
      color: Color(0xFF4E4E4E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.sports_handball, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Weekly Challenge: Plank With Hip Twist",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
