import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> _userData = {};
  bool _isLoadingUserData = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fitness_center, 'label': 'Workout', 'route': null},
    {'icon': Icons.insert_chart, 'label': 'Progress', 'route': null},
    {'icon': Icons.restaurant, 'label': 'Nutrition', 'route': null},
    {'icon': Icons.chat, 'label': 'Chat Bot', 'route': const ChatPage()},
    {'icon': Icons.calculate, 'label': 'Calorie Calc', 'route': CalorieCalculatorPage()},
    {'icon': Icons.store, 'label': 'Supplement Store', 'route': SupplementsStorePage()},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Widget _buildCategoryIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;
    final themeColors = {
      'selected': const Color(0xFFE2F163),
      'unselected': const Color(0xFFB3A0FF),
      'background': const Color(0xFF232323),
    };

    final containerSize = isSelected ? 60.0 : 50.0;
    final iconSize = containerSize * 0.5;

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
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? themeColors['selected'] : themeColors['unselected'],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSelected ? 14 : 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: currentUser.uid),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to be logged in to view your profile")),
      );
    }
  }

  void _showProfileSheet() {
    if (_isLoadingUserData) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFB3A0FF)),
        ),
      );
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to be logged in to view your profile")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  "Name: ${_userData['firstName'] ?? ''} ${_userData['middleName'] != null && _userData['middleName'].isNotEmpty ? _userData['middleName'] + ' ' : ''}${_userData['lastName'] ?? ''}",
                  style: const TextStyle(color: Colors.white, fontSize: 18)
              ),
              const SizedBox(height: 8),
              Text(
                  "Email: ${_userData['email'] ?? 'Not available'}",
                  style: const TextStyle(color: Colors.white, fontSize: 16)
              ),
              const SizedBox(height: 8),
              Text(
                  "Phone: ${_userData['phone'] ?? 'Not available'}",
                  style: const TextStyle(color: Colors.white, fontSize: 16)
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3A0FF)),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToProfile();
                    },
                    child: const Text("View Full Profile", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _showProfileSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome Back!", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Track your fitness and health journey.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              height: 120,
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
                          (index) => _buildCategoryIcon(_categories[index]['icon'], _categories[index]['label'], index),
                    ),
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