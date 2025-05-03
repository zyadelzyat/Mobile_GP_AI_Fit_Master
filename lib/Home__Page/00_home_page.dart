import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming needed for ThemeProvider if used
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import Rating Bar
import 'package:untitled/AI/chatbot.dart'; // Replace 'untitled' with your project name
import 'package:untitled/Home__Page/profile.dart'; // Replace 'untitled'
// import 'package:untitled/theme_provider.dart'; // Uncomment if needed
import 'package:untitled/videos_page.dart'; // Replace 'untitled'
import 'CalorieCalculator.dart'; // Replace 'untitled' if needed
import 'Store.dart'; // Replace 'untitled' if needed
import 'trainer_trainees_page.dart'; // Replace 'untitled' if needed
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/Home__Page/NutritionMainPage.dart'; // Replace 'untitled'
import 'AddRatingPage.dart'; // Replace 'untitled' if needed

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  // Updated _currentNavIndex to reflect 3 items in BottomNavBar (Home, Store, Chat)
  int _currentNavIndex = 0; // 0: Home, 1: Store, 2: Chat
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> _userData = {}; // Use specific type
  bool _isLoadingUserData = true; // Start as true

  // *** CORRECTED: Use 'iconAsset' with image paths ***
  final List<Map<String, dynamic>> _categories = [
    {
      'iconAsset': 'assets/icons/youtube.png', // Path to your custom workout icon
      'label': 'Workout',
      'route': null
    },
    {
      'iconAsset': 'assets/icons/nutrition_icon.png', // Path to your custom nutrition icon
      'label': 'Nutrition',
      'route': 'Nutrition'
    },
    {
      'iconAsset': 'assets/icons/products_icon.png', // Path to your custom products icon
      'label': 'Products',
      'route': 'SupplementsStore'
    },
    {
      'iconAsset': 'assets/icons/calculating_calories_icon.png', // Path to your custom calculator icon
      'label': 'Calculating Calories', // Updated label
      'route': 'CalorieCalculator'
    },
  ];

  // Dynamic categories based on user role
  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> categories = List.from(_categories); // Create a modifiable copy
    if (_userData.containsKey('role') && _userData['role'] == 'Self-Trainee') {
      // Exclude Nutrition and modify Workout for Self-Trainee
      categories = categories
          .where((category) => category['label'] != 'Nutrition')
          .map((category) {
        if (category['label'] == 'Workout') {
          return {
            // *** CHANGE THIS LINE ***
            'iconAsset': 'assets/icons/youtube.png', // Use the same youtube icon path
            'label': 'YT_Workout', // Keep or change label as needed
            'route': 'YT_Channel', // Keep or change route as needed
          };
        }
        return category;
      }).toList();
    }
    // Add other role conditions if they exist...

    // This part seems misplaced in the original code, should likely be outside the Self-Trainee condition
    // categories.removeWhere((category) => category['label'] == 'ChatBot'); // Example filter

    return categories;
  }

  // Made _workouts mutable for favorite state changes
  List<Map<String, dynamic>> _workouts = [
    {
      'title': '3 tips for gym beginners',
      'image': 'assets/workout1.jpg', // Make sure these assets exist
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6',
      'duration': '8 Minutes',
      'calories': '90 kcal',
      'isFavorite': false, // Initialize as false, load state later
    },
    {
      'title': 'Best Bulking Drink For Skinny Guys!',
      'image': 'assets/workout2.jpg', // Make sure these assets exist
      'color': Colors.blue,
      'videoUrl': 'https://www.youtube.com/watch?v=3sH7wbIZjEY',
      'duration': '12 Minutes',
      'calories': '120 kcal',
      'isFavorite': false, // Default to false, load state later
    },
    // Add more workouts if needed
  ];

  final List<Map<String, dynamic>> _healthAndFitItems = [
    {
      'title': 'Supplement Guide',
      'description': '',
      'image': 'assets/supplement.jpg', // Make sure this asset exists
    },
    {
      'title': '5 Quick & Effective Daily Routines',
      'description': '',
      'image': 'assets/daily.jpg', // Make sure this asset exists
    },
    // Add more items if needed
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data first, then load favorites which might depend on user ID
    _fetchCurrentUserData().then((_) {
      _loadFavorites(); // Load favorites after user data is fetched
    });
  }

  Future<void> _fetchCurrentUserData() async {
    // Ensure widget is still mounted before state changes
    if (!mounted) return;
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && mounted) { // Check if mounted before setting state
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        } else {
          print("User document does not exist for UID: ${currentUser.uid}");
          // Handle case where user doc doesn't exist
        }
      } else {
        print("No current user logged in.");
        // Handle case where no user is logged in
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) { // Check if mounted before setting state
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return; // Check if component is still mounted
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot favoritesDoc =
        await _firestore.collection('favorites').doc(currentUser.uid).get();
        if (favoritesDoc.exists && mounted) {
          Map<String, dynamic> favoritesData =
          favoritesDoc.data() as Map<String, dynamic>;
          List<dynamic> favoriteWorkoutsTitlesDynamic = favoritesData['workouts'] ?? [];
          List<String> favoriteWorkoutsTitles = favoriteWorkoutsTitlesDynamic.cast<String>();
          List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts);
          for (int i = 0; i < updatedWorkouts.length; i++) {
            String workoutTitle = updatedWorkouts[i]['title'];
            updatedWorkouts[i]['isFavorite'] = favoriteWorkoutsTitles.contains(workoutTitle);
          }
          if (mounted) {
            setState(() {
              _workouts = updatedWorkouts;
            });
          }
        } else {
          print("No favorites document found for user ${currentUser.uid}");
          if (mounted) {
            setState(() {
              for (var workout in _workouts) {
                workout['isFavorite'] = false;
              }
            });
          }
        }
      }
    } catch (e) {
      print("Error loading favorites: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading favorites: ${e.toString()}'))
        );
      }
    }
  }

  Future<void> _saveFavorites() async {
    if (!mounted) return; // Check if component is still mounted
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        List<String> favoriteWorkoutsTitles = [];
        for (var workout in _workouts) {
          if (workout['isFavorite'] == true) {
            favoriteWorkoutsTitles.add(workout['title']);
          }
        }
        await _firestore.collection('favorites').doc(currentUser.uid).set({
          'workouts': favoriteWorkoutsTitles,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Favorites saved successfully.");
      }
    } catch (e) {
      print("Error saving favorites: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving favorites: ${e.toString()}")),
        );
      }
    }
  }

  // --- Navigation ---
  void _navigateToFeature(String? routeName) {
    if (routeName == null || !mounted) return; // Check context validity
    switch (routeName) {
      case 'Workout':
        break; // Default section, do nothing
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
                builder: (context) => const CalorieCalculator()));
        break;
      case 'SupplementsStore':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SupplementsStorePage()));
        break;
      case 'YT_Channel':
        _launchYouTubeChannel();
        break;
      // case 'VideosPage': // Handle 'See All' tap for workouts
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => AllVideosPage(videos: _workouts))); // Assuming AllVideosPage exists
      //   break;
      default:
        print("Unknown route: $routeName");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navigation for '$routeName' not implemented.")),
          );
        }
    }
  }

  Future<void> _launchUrlHelper(String url) async {
    final Uri uri = Uri.parse(url);
    if (!mounted) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch $url");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $url")),
          );
        }
      }
    } catch (e) {
      print("Error launching URL $url: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching URL: ${e.toString()}")),
        );
      }
    }
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
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: currentUser.uid),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("You need to be logged in to view your profile")),
        );
      }
    }
  }

  void _navigateToTrainees() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerTraineesPage()),
    );
  }

  void _navigateToChatbot() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  // --- State Management ---
  void _toggleFavorite(int index) {
    if (!mounted) return;
    setState(() {
      if (index >= 0 && index < _workouts.length) {
        _workouts[index]['isFavorite'] = !_workouts[index]['isFavorite'];
      } else {
        print("Error: Invalid index $index for toggling favorite.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error updating favorite status.")),
          );
        }
        return;
      }
    });
    _saveFavorites();
  }

  // --- WIDGET BUILDERS ---

  // *** CORRECTED: Accepts iconAsset path and uses Image.asset ***
  Widget _buildCategoryIcon(String iconAsset, String label, int index) {
    String displayLabel = (label == 'YT_Workout') ? 'Workout' : label;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedCategoryIndex = index;
        });
        String? route = _filteredCategories[index]['route'];
        if (route != null) {
          _navigateToFeature(route);
        } else if (_filteredCategories[index]['label'] == 'Workout'){
          print("Workout category tapped (no specific route assigned)");
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E7AFE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            // *** Use Image.asset with color tinting ***
            child: Image.asset(
              iconAsset,
              width: 24,
              height: 24,
              //color: const Color(0xFF8E7AFE), // Apply the theme color tint <--- THIS LINE
              errorBuilder: (context, error, stackTrace) {
                print("Error loading icon image '$iconAsset': $error");
                // Fallback icon if image fails
                return const Icon(
                  Icons.broken_image, // More appropriate fallback
                  color: Color(0xFF8E7AFE),
                  size: 24,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index) {
    final videoUrl = workout['videoUrl'] as String?;
    final isFavorite = workout['isFavorite'] as bool? ?? false;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png';
    final title = workout['title'] as String? ?? 'No Title';
    final duration = workout['duration'] as String? ?? '-';
    final calories = workout['calories'] as String? ?? '-';
    return GestureDetector(
      onTap: () {
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _launchVideo(videoUrl);
        } else {
          print("No video URL for workout: $title");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No video available for this workout.")),
            );
          }
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
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading workout image '$imageUrl': $error");
                      return Container(
                        height: 100,
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                if (videoUrl != null && videoUrl.isNotEmpty)
                  Container(
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                        size: 18,
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
                      Expanded(
                        child: Text(
                          duration,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          calories,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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
    final imageUrl = item['image'] ?? 'assets/placeholder.png';
    final title = item['title'] ?? 'No Title';
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
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading health/fit image '$imageUrl': $error");
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

  Widget _buildRatingSection() {
    String coachName = "Coach";
    String coachImageUrl = "assets/coach_placeholder.png";
    double currentRating = 4.0;
    String lastComment = "Good effort but ..........";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB3A0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "My Rate",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddRatingPage()),
                    ).then((_) {
                      print("Returned from AddRatingPage");
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Add Rating",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(coachImageUrl),
                  backgroundColor: Colors.grey[800],
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading coach image: $exception');
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color: index < currentRating.floor()
                                ? Colors.yellow
                                : Colors.grey[800],
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastComment,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        coachName,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesView() {
    if (!mounted) return const SizedBox.shrink();
    List<Map<String, dynamic>> favoriteWorkouts =
    _workouts.where((workout) => workout['isFavorite'] == true).toList();

    if (favoriteWorkouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
                "Mark workouts as favorites by tapping the star icon to see them here.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteWorkouts.length,
      itemBuilder: (context, index) {
        final originalIndex = _workouts.indexWhere(
                (workout) => workout['title'] == favoriteWorkouts[index]['title']);
        if (originalIndex == -1) {
          print("Warning: Could not find original index for favorite workout: ${favoriteWorkouts[index]['title']}");
          return const SizedBox.shrink();
        }
        return _buildFavoriteWorkoutCard(favoriteWorkouts[index], originalIndex);
      },
    );
  }

  Widget _buildFavoriteWorkoutCard(Map<String, dynamic> workout, int originalIndex) {
    final videoUrl = workout['videoUrl'] as String?;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png';
    final title = workout['title'] as String? ?? 'No Title';
    final duration = workout['duration'] as String? ?? '-';
    final calories = workout['calories'] as String? ?? '-';
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
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading favorite image '$imageUrl': $error");
                    return Container(
                      height: 180,
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                    );
                  },
                ),
              ),
              if (videoUrl != null && videoUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (videoUrl.isNotEmpty) {
                      _launchVideo(videoUrl);
                    }
                  },
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                    Expanded(
                      child: Text(
                        duration,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.local_fire_department, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        calories,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
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

  @override
  Widget build(BuildContext context) {
    String userName = _isLoadingUserData ? 'User' : (_userData['firstName'] as String? ?? 'User');
    Widget mainContent;

    if (_isLoadingUserData) {
      mainContent = const Center(
        child: CircularProgressIndicator(color: Color(0xFF8E7AFE)),
      );
    } else if (_currentNavIndex == 0) { // Home Tab Content
      mainContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Section (with Profile Icon in AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "It's time to challenge your limits.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Search not implemented yet.'))
                        );
                      }
                    },
                    tooltip: 'Search',
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifications not implemented yet.'))
                        );
                      }
                    },
                    tooltip: 'Notifications',
                  ),
                  // Profile Icon Button in AppBar
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: _navigateToProfile,
                    tooltip: 'Profile',
                  ),
                ],
              ),
            ),
            // Category Icons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_filteredCategories.length, (index) {
                  final category = _filteredCategories[index];
                  // *** CORRECTED: Pass 'iconAsset' path to builder ***
                  return _buildCategoryIcon(
                    category['iconAsset'], // Use the asset path
                    category['label'],
                    index,
                  );
                }),
              ),
            ),
            // Workouts Section
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
                      _navigateToFeature('VideosPage'); // Navigate to all videos page
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Color(0xFF8E7AFE),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
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
            // Promotional Banner (Conditional)
            if (!(_userData.containsKey('role') && _userData['role'] == 'Trainee')) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container( /* ... Banner content ... */ ),
              ),
              const SizedBox(height: 24),
            ],
            // Rating Section (Conditional)
            if (_userData.containsKey('role') && _userData['role'] == 'Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRatingSection(),
              ),
              const SizedBox(height: 24),
            ],
            // Health & Fit Section
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
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _healthAndFitItems.length,
                itemBuilder: (context, index) =>
                    _buildHealthAndFitCard(_healthAndFitItems[index]),
              ),
            ),
            const SizedBox(height: 24),
            // Trainer Button (Conditional)
            if (_userData.containsKey('role') &&
                _userData['role'] != 'Trainee' &&
                _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector( /* ... Trainer button content ... */ ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      );
    } else if (_currentNavIndex == 1) { // Favorites Tab Content
      // This index now corresponds to 'Store' based on the BottomNavBar items below
      // If you want a favorites tab, you need to adjust the BottomNavBar items and logic
      mainContent = _buildFavoritesView(); // Assuming you might want favorites later
    } else if (_currentNavIndex == 2) { // AI Coach Tab Content
      mainContent = const ChatPage(); // Show ChatPage directly
    } else { // Fallback
      mainContent = const Center(
        child: Text("Invalid Tab Index", style: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: mainContent,
      ),
      // *** CORRECTED BottomNavBar to have 3 items: Home, Store, Chat ***
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8E7AFE), // Purple background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (!mounted) return;
            // Handle navigation based on the 3 items
            if (index == 1) { // Store is index 1
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupplementsStorePage()),
              );
              // Optional: Reset index if you don't want Store to be persistently selected
              // setState(() { _currentNavIndex = 0; });
            } else { // Home (0) or Chat (2)
              setState(() {
                _currentNavIndex = index;
              });
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          // *** Updated items to match 3-item layout ***
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure you have the corresponding pages imported:
// NutritionPage, CalorieCalculator, SupplementsStorePage, AllVideosPage,
// ProfilePage, TrainerTraineesPage, ChatPage, AddRatingPage
