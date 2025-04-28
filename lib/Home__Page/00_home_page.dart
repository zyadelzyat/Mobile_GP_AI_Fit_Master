import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/profile.dart';
import 'package:untitled/theme_provider.dart';
import 'package:untitled/videos_page.dart';
import 'CalorieCalculator.dart';
import 'Store.dart';
import 'trainer_trainees_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/Home__Page/NutritionMainPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> _userData = {};
  bool _isLoadingUserData = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fitness_center, 'label': 'Workout', 'route': null},
    {'icon': Icons.insert_chart, 'label': 'Nutrition', 'route': 'Nutrition'},
    {'icon': Icons.shopping_bag, 'label': 'Products', 'route': 'SupplementsStore'},
    {'icon': Icons.calculate_outlined, 'label': 'Calories', 'route': 'CalorieCalculator'},
  ];

  // Dynamic categories based on user role
  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> categories = _categories;
    if (_userData['role'] == 'Self-Trainee') {
      // Exclude Nutrition and modify Workout for Self-Trainee
      categories = categories
          .where((category) => category['label'] != 'Nutrition')
          .map((category) {
        if (category['label'] == 'Workout') {
          return {
            'icon': null, // Use null to indicate custom image (YouTube logo)
            'label': 'YT_Workout',
            'route': 'YT_Channel',
          };
        }
        return category;
      }).toList();
    }
    return categories;
  }

  final List<Map<String, dynamic>> _workouts = [
    {
      'title': '3 tips for gym beginners',
      'image': 'assets/workout1.jpg',
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6',
      'duration': '8 Minutes',
      'calories': '90 kcal',
      'isFavorite': false,
    },
    {
      'title': 'Best Bulking Drink For Skinny Guys!',
      'image': 'assets/workout2.jpg',
      'color': Colors.blue,
      'videoUrl': 'https://www.youtube.com/watch?v=3sH7wbIZjEY',
      'duration': '12 Minutes',
      'calories': '120 kcal',
      'isFavorite': true,
    },
  ];

  final List<Map<String, dynamic>> _healthAndFitItems = [
    {
      'title': 'Supplement Guide',
      'description': '',
      'image': 'assets/supplement.jpg',
    },
    {
      'title': '5 Quick & Effective Daily Routines',
      'description': '',
      'image': 'assets/daily.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
    _loadFavorites();
  }

  Future<void> _fetchCurrentUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

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

  Future<void> _loadFavorites() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot favoritesDoc =
        await _firestore.collection('favorites').doc(currentUser.uid).get();

        if (favoritesDoc.exists) {
          Map<String, dynamic> favoritesData =
          favoritesDoc.data() as Map<String, dynamic>;
          List<dynamic> favoriteWorkouts = favoritesData['workouts'] ?? [];

          for (int i = 0; i < _workouts.length; i++) {
            String workoutTitle = _workouts[i]['title'];
            if (favoriteWorkouts.contains(workoutTitle)) {
              setState(() {
                _workouts[i]['isFavorite'] = true;
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> _saveFavorites() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        List<String> favoriteWorkouts = [];
        for (var workout in _workouts) {
          if (workout['isFavorite'] == true) {
            favoriteWorkouts.add(workout['title']);
          }
        }

        await _firestore.collection('favorites').doc(currentUser.uid).set({
          'workouts': favoriteWorkouts,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving favorites: $e");
    }
  }

  void _navigateToFeature(String? routeName) {
    if (routeName == null) return;

    switch (routeName) {
      case 'Workout':
        break;
      case 'Nutrition':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NutritionPage()));
        break;
      case 'ChatBot':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ChatPage()));
        break;
      case 'CalorieCalculator':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CalorieCalculatorPage()));
        break;
      case 'SupplementsStore':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SupplementsStorePage()));
        break;
      case 'VideosPage':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AllVideosPage(videos: _workouts)));
        break;
      case 'YT_Channel':
        _launchYouTubeChannel();
        break;
    }
  }

  Future<void> _launchYouTubeChannel() async {
    const url = 'https://www.youtube.com/@yusufashraf17';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
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
        const SnackBar(
            content: Text("You need to be logged in to view your profile")),
      );
    }
  }

  void _navigateToTrainees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerTraineesPage()),
    );
  }

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  void _toggleFavorite(int index) {
    setState(() {
      _workouts[index]['isFavorite'] = !_workouts[index]['isFavorite'];
    });
    _saveFavorites();
  }

  Future<void> _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  Widget _buildCategoryIcon(dynamic icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });

        if (_filteredCategories[index]['route'] != null) {
          _navigateToFeature(_filteredCategories[index]['route']);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E7AFE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: icon == null
                ? const Icon(
              Icons.play_circle_fill, // YouTube-like play icon
              color: Color(0xFF8E7AFE),
              size: 24,
            )
                : Icon(
              icon,
              color: const Color(0xFF8E7AFE),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == 'YT_Workout' ? 'Workout' : label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index) {
    return GestureDetector(
      onTap: () {
        if (workout['videoUrl'] != null) {
          _launchVideo(workout['videoUrl']);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    workout['image'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        workout['isFavorite'] ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        workout['duration'],
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department,
                          color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        workout['calories'],
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthAndFitCard(Map<String, dynamic> item) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              item['image'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              item['title'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    List<Map<String, dynamic>> favoriteWorkouts =
    _workouts.where((workout) => workout['isFavorite'] == true).toList();

    if (favoriteWorkouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.star_border,
              color: Colors.grey,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              "No favorites yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Mark workouts as favorites to see them here",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteWorkouts.length,
      itemBuilder: (context, index) {
        final originalIndex = _workouts.indexWhere(
                (workout) => workout['title'] == favoriteWorkouts[index]['title']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      favoriteWorkouts[index]['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(originalIndex),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        if (favoriteWorkouts[index]['videoUrl'] != null) {
                          _launchVideo(favoriteWorkouts[index]['videoUrl']);
                        }
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favoriteWorkouts[index]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          favoriteWorkouts[index]['duration'],
                          style:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          favoriteWorkouts[index]['calories'],
                          style:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = _userData['firstName'] ?? 'Madison';

    Widget mainContent;

    if (_currentNavIndex == 0) {
      mainContent = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName",
                        style: const TextStyle(
                          color: Color(0xFF8E7AFE),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "It's time to challenge your limits.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < _filteredCategories.length; i++)
                    _buildCategoryIcon(
                      _filteredCategories[i]['icon'],
                      _filteredCategories[i]['label'],
                      i,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  GestureDetector(
                    onTap: () {
                      _navigateToFeature('VideosPage');
                    },
                    child: Row(
                      children: const [
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Color(0xFF8E7AFE),
                            fontSize: 14,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF8E7AFE), size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _workouts.length,
                itemBuilder: (context, index) =>
                    _buildWorkoutCard(_workouts[index], index),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E7AFE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Don't Give Up",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Plans with Pro Tips!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(15)),
                      child: Image.asset(
                        'assets/workout1.jpg',
                        width: 150,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Health & Fit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _healthAndFitItems.length,
                itemBuilder: (context, index) =>
                    _buildHealthAndFitCard(_healthAndFitItems[index]),
              ),
            ),
            const SizedBox(height: 24),
            if (_userData['role'] != 'trainee' &&
                _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _navigateToTrainees,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF8E7AFE).withOpacity(0.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, color: Color(0xFF8E7AFE)),
                        SizedBox(width: 10),
                        Text(
                          "View Assigned Trainees",
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
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      );
    } else if (_currentNavIndex == 1) {
      mainContent = _buildFavoritesView();
    } else if (_currentNavIndex == 2) {
      mainContent = const Center(
        child: ChatPage(),
      );
    } else {
      mainContent = const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8E7AFE),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: mainContent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 3) {
            _navigateToProfile();
          }
        },
        backgroundColor: const Color(0xFF232323),
        selectedItemColor: const Color(0xFF8E7AFE),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'AI Coach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AllVideosPage extends StatelessWidget {
  final List<Map<String, dynamic>> videos;

  const AllVideosPage({Key? key, required this.videos}) : super(key: key);

  Future<void> _launchVideo(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        if (video['videoUrl'] != null) {
          _launchVideo(context, video['videoUrl']);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    video['image'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        video['duration'],
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_fire_department,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        video['calories'],
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
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
        title: const Text(
          "All Workouts",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) => _buildVideoCard(context, videos[index]),
        ),
      ),
    );
  }
}