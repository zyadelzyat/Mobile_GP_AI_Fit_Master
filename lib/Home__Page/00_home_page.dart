import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/Profile/profile.dart';
import 'CalorieCalculator.dart';
import '../Store/Store.dart';
import 'trainer_trainees_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/rating/AddRatingPage.dart';
import 'assigned_exercises_page.dart';
import 'package:untitled/meal/trainee_meal_plans_page.dart';
import 'package:untitled/Home__Page/NutritionMainPage.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map _userData = {};
  bool _isLoadingUserData = true;

  final List<Map<String, dynamic>> _baseCategories = [
    {
      'iconAsset': 'assets/icons/workout_icon.png',
      'label': 'Workout',
      'route': null,
    },
    {
      'iconAsset': 'assets/icons/calculating_calories_icon.png',
      'label': 'Calculating Calories',
      'route': 'CalorieCalculator',
    },
    {
      'iconAsset': 'assets/icons/nutrition_icon.png',
      'label': 'Nutrition',
      'route': 'Nutrition',
    },
    {
      'iconAsset': 'assets/icons/products_icon.png',
      'label': 'Products',
      'route': 'SupplementsStore',
    },
  ];

  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> categories = List.from(_baseCategories);
    if (_userData.containsKey('role')) {
      final String userRole = _userData['role'] as String? ?? '';
      if (userRole == 'Self-Trainee' || userRole == 'Trainer') {
        categories.removeWhere((category) => category['label'] == 'Nutrition');
        // ...rest of your logic for Self-Trainee (e.g. YT_Workout)
        if (userRole == 'Self-Trainee') {
          categories = categories.map((category) {
            if (category['label'] == 'Workout') {
              return {
                'iconAsset': 'assets/icons/youtube.png',
                'label': 'YT_Workout',
                'route': 'YT_Channel',
              };
            }
            return category;
          }).toList();
        }
      }
      // For Trainee, do not remove Nutrition
    }
    return categories;
  }
  List<Map<String, dynamic>> _workouts = [
    {
      'title': '3 Tips For Beginners',
      'image': 'assets/workout1.jpg',
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6',
      'duration': '12 Minutes',
      'calories': '120 Kcal',
      'isFavorite': false,
    },
    {
      'title': 'Best Bulking Drink !',
      'image': 'assets/workout2.jpg',
      'color': Colors.blue,
      'videoUrl': 'https://www.youtube.com/watch?v=3sH7wbIZjEY',
      'duration': '12 Minutes',
      'calories': '120 Kcal',
      'isFavorite': false,
    },
  ];

  final List<Map<String, dynamic>> _healthAndFitItems = [
    {
      'title': 'Supplement Guide',
      'description': '',
      'image': 'assets/supplement.jpg',
    },
    {
      'title': '15 Quick & Effective Daily Routines',
      'description': '',
      'image': 'assets/daily.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData().then((_) {
      if (mounted && _userData.isNotEmpty) {
        _loadFavorites();
        setState(() {});
      }
    });
  }

  Future<void> _fetchCurrentUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && mounted) {
          setState(() {
            _userData = Map.from(userDoc.data() as Map);
          });
        } else {
          setState(() => _userData = {});
        }
      } else {
        setState(() => _userData = {});
      }
    } catch (e) {
      setState(() => _userData = {});
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    try {
      DocumentSnapshot favoritesDoc =
      await _firestore.collection('favorites').doc(currentUser.uid).get();
      if (favoritesDoc.exists && mounted) {
        Map<String, dynamic> favoritesData =
        favoritesDoc.data() as Map<String, dynamic>;
        List<dynamic> favoriteWorkoutsTitlesDynamic =
            favoritesData['workouts'] ?? [];
        List<String> favoriteWorkoutsTitles =
        favoriteWorkoutsTitlesDynamic.cast<String>();
        List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts);
        for (int i = 0; i < updatedWorkouts.length; i++) {
          String workoutTitle = updatedWorkouts[i]['title'] as String;
          updatedWorkouts[i]['isFavorite'] =
              favoriteWorkoutsTitles.contains(workoutTitle);
        }
        setState(() {
          _workouts = updatedWorkouts;
        });
      } else {
        setState(() {
          List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts);
          for (var workout in updatedWorkouts) {
            workout['isFavorite'] = false;
          }
          _workouts = updatedWorkouts;
        });
      }
    } catch (e) {}
  }

  Future<void> _saveFavorites() async {
    if (!mounted) return;
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    try {
      List<String> favoriteWorkoutsTitles = [];
      for (var workout in _workouts) {
        if (workout['isFavorite'] == true) {
          favoriteWorkoutsTitles.add(workout['title'] as String);
        }
      }
      await _firestore.collection('favorites').doc(currentUser.uid).set({
        'workouts': favoriteWorkoutsTitles,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  void _navigateToFeature(String? routeName) {
    if (routeName == null || !mounted) return;

    switch (routeName) {
      case 'Workout':
        if (_userData['role'] == 'Trainee') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignedExercisesPage()),
          );
        } else {
          print("Workout category tapped (no specific route assigned)");
        }
        break;
      case 'Nutrition':
        if (_userData['role'] == 'Trainee') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TraineeMealPlansPage()),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NutritionPage()));
        }
        break;
      case 'ChatBot':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
        break;
      case 'CalorieCalculator':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalorieCalculator()));
        break;
      case 'SupplementsStore':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplementsStorePage()));
        break;
      case 'YT_Channel':
        _launchYouTubeChannel();
        break;
      default:
        break;
    }
  }

  Future<void> _launchUrlHelper(String url) async {
    final Uri uri = Uri.parse(url);
    if (!mounted) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {}
  }

  Future<void> _launchYouTubeChannel() async {
    await _launchUrlHelper('https://www.youtube.com/@yusufashraf17');
  }

  Future<void> _launchVideo(String url) async {
    await _launchUrlHelper(url);
  }

  void _navigateToProfile() {
    if (!mounted) return;
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: currentUser.uid)),
      ).then((_) => _fetchCurrentUserData());
    }
  }

  void _navigateToTrainees() {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainerTraineesPage()));
  }

  void _toggleFavorite(int index) {
    if (!mounted) return;
    setState(() {
      if (index >= 0 && index < _workouts.length) {
        _workouts[index]['isFavorite'] = !(_workouts[index]['isFavorite'] as bool? ?? false);
      }
    });
    _saveFavorites();
  }

  Widget _buildCategoryIcon(String iconAsset, String label, int index) {
    String displayLabel = (label == 'YT_Workout') ? 'Workout' : label;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        String? route = _filteredCategories[index]['route'] as String?;
        _navigateToFeature(route ?? label);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E7AFE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset(
              iconAsset,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.category, color: Color(0xFF8E7AFE), size: 30);
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map workout, int index) {
    final videoUrl = workout['videoUrl'] as String?;
    final isFavorite = workout['isFavorite'] as bool? ?? false;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png';
    final title = workout['title'] as String? ?? 'Workout Title';
    final duration = workout['duration'] as String? ?? '-';
    final calories = workout['calories'] as String? ?? '-';

    return GestureDetector(
      onTap: () {
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _launchVideo(videoUrl);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                if (videoUrl != null && videoUrl.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E7AFE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(_workouts.indexWhere((w) => w['title'] == title)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFavorite ? Colors.yellowAccent : Colors.white70,
                        size: 20,
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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department_outlined, color: Colors.orangeAccent, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(calories, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
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

  Widget _buildHealthAndFitCard(Map item) {
    final imageUrl = item['image'] as String? ?? 'assets/placeholder.png';
    final title = item['title'] as String? ?? 'Health & Fit Item';
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      margin: const EdgeInsets.only(right: 12),
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
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB3A0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: Color(0xFF8E7AFE)),
                        SizedBox(width: 6),
                        Text(
                          "My Rate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                        Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                        Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                        Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                        Icon(Icons.star, color: Color(0xFFFFD600), size: 22),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage('assets/coach_placeholder.png'),
                        ),
                        SizedBox(width: 8),
                        Text("Coach", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("Good effort but .............", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDBD5FF),
                      foregroundColor: const Color(0xFF8E7AFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRatingPage()));
                    },
                    icon: const Icon(Icons.add_circle, size: 20),
                    label: const Text("Add Rating", style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = _isLoadingUserData ? 'User' : (_userData['firstName'] as String? ?? 'User');

    Widget mainContent;
    if (_isLoadingUserData) {
      mainContent = const Center(child: CircularProgressIndicator(color: Color(0xFF8E7AFE)));
    } else if (_currentNavIndex == 0) {
      mainContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, $userName", style: const TextStyle(color: Color(0xFF896CFE), fontSize: 26, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        const Text("Ready to crush your goals today?", style: TextStyle(color: Colors.grey, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}, tooltip: 'Search'),
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}, tooltip: 'Notifications'),
                  IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: _navigateToProfile, tooltip: 'Profile'),
                ],
              ),
            ),
            if (_filteredCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: _filteredCategories.length > 3 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceAround,
                  children: List.generate(_filteredCategories.length, (index) {
                    final category = _filteredCategories[index];
                    return _buildCategoryIcon(category['iconAsset'] as String, category['label'] as String, index);
                  }),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Workouts", style: TextStyle(color: Color(0xFFE2F163), fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("See All", style: TextStyle(color: Color(0xFF8E7AFE), fontSize: 14)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: Color(0xFF8E7AFE), size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _workouts.length,
                itemBuilder: (context, index) => _buildWorkoutCard(_workouts[index], index),
              ),
            ),
            const SizedBox(height: 24),
            if (!(_userData.containsKey('role') && _userData['role'] == 'Trainee')) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFFB3A0FF), borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Achieve Your Goals", style: TextStyle(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Plank With Hip Twist", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/plank_image.png',
                            height: 65, width: 65, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(height: 65, width: 65, color: Colors.grey[700], child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (_userData.containsKey('role') && _userData['role'] == 'Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRatingSection(),
              ),
              const SizedBox(height: 24),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text("Health & Fit", style: TextStyle(color: Color(0xFFE2F163), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _healthAndFitItems.length,
                itemBuilder: (context, index) => _buildHealthAndFitCard(_healthAndFitItems[index]),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else if (_currentNavIndex == 1) {
      mainContent = Center(child: Text("Store Tab (handled by navigation)", style: TextStyle(color: Colors.white)));
    } else if (_currentNavIndex == 2) {
      mainContent = const ChatPage();
    } else if (_currentNavIndex == 3) {
      mainContent = ProfilePage(userId: FirebaseAuth.instance.currentUser?.uid ?? '');
    } else {
      mainContent = const Center(child: Text("Invalid Tab Index", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      extendBody: true,
      body: SafeArea(child: mainContent),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFB29BFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              if (!mounted) return;
              if (index == 1) {
                // Get favorite workouts from the current state
                List<Map<String, dynamic>> favoriteWorkouts = _workouts
                    .where((workout) => workout['isFavorite'] == true)
                    .toList();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoritesPage(favoriteRecipes: favoriteWorkouts)
                    )
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      _currentNavIndex = 0;
                    });
                  }
                });
              } else {
                setState(() {
                  _currentNavIndex = index;
                });
              }
            },
            backgroundColor: const Color(0xFFB29BFF),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            iconSize: 26,
            items: const [
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/icons/home.png')),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/icons/fav.png')),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/icons/chat.png')),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/icons/User.png')),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );

  }
}
