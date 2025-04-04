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
    {'icon': Icons.insert_chart, 'label': 'Nutrition', 'route': null},
  ];

  final List<Map<String, dynamic>> _workouts = [
    {
      'title': 'Squat Exercise',
      'duration': '32 Minutes',
      'kcal': '320 Kcal',
      'image': 'assets/workout1.jpg',
      'color': Colors.purple,
    },
    {
      'title': 'Full Body Stretching',
      'duration': '25 Minutes',
      'kcal': '190 Kcal',
      'image': 'assets/workout2.jpg',
      'color': Colors.blue,
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Supplement Guide',
      'image': 'assets/supplement.jpg',
      'route': 'SupplementsStore',
    },
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

  void _navigateToFeature(String routeName) {
    switch (routeName) {
      case 'Workout':
      // Navigate to workout page when implemented
        break;
      case 'ChatBot':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 'CalorieCalculator':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalorieCalculatorPage()),
        );
        break;
    }
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

  Widget _buildCategoryButton(IconData icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8E7AFE) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8E7AFE),
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E7AFE),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF2A2A2A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  workout['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: workout['color'],
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      workout['duration'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.local_fire_department, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      workout['kcal'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF333333)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/promo.jpg',
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Achieve Your\nGoals",
                  style: TextStyle(
                    color: Color(0xFFE2F163),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Plans With Hip Twist",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => _navigateToFeature(feature['route']),
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF2A2A2A),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                feature['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                feature['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = _userData['firstName'] ?? 'Fitness';

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(  // Added Expanded to make text area flexible
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, $userName",
                            style: const TextStyle(
                              color: Color(0xFF8E7AFE),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,  // Added to prevent text overflow
                            overflow: TextOverflow.ellipsis,  // Added to handle text overflow
                          ),
                          const Text(
                            "It's time to challenge your limits.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,  // Added to prevent text overflow
                            overflow: TextOverflow.ellipsis,  // Added to handle text overflow
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,  // Added to make this row take minimum space
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                          iconSize: 20,  // Reduced icon size slightly
                          padding: EdgeInsets.zero,  // Reduced padding
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),  // Constrained button size
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                          iconSize: 20,  // Reduced icon size slightly
                          padding: EdgeInsets.zero,  // Reduced padding
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),  // Constrained button size
                        ),
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: const CircleAvatar(
                            radius: 16,  // Slightly reduced from 18
                            backgroundColor: Color(0xFF8E7AFE),
                            child: Icon(Icons.person, color: Colors.white, size: 16),  // Reduced size from 20
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (int i = 0; i < _categories.length; i++)
                      _buildCategoryButton(
                        _categories[i]['icon'],
                        _categories[i]['label'],
                        i,
                      ),
                    _buildCategoryButton(Icons.calculate_outlined, 'Calorie', 2),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Workouts",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: const [
                          Text(
                            "See All",
                            style: TextStyle(
                              color: Color(0xFF8E7AFE),
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF8E7AFE),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) => _buildWorkoutCard(_workouts[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPromoBanner(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Health & Fit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var feature in _features) _buildFeatureItem(feature),
                    // ChatBot button at the bottom (only)
                    GestureDetector(
                      onTap: () => _navigateToFeature('ChatBot'),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF8E7AFE).withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline, color: Color(0xFF8E7AFE)),
                            SizedBox(width: 10),
                            Text(
                              "Chat with AI Coach",
                              style: TextStyle(
                                color: Color(0xFF8E7AFE),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}