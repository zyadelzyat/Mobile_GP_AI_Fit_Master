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
  Map<String, dynamic> _userData = {}; // Use specific type Map<String, dynamic>
  bool _isLoadingUserData = true; // Start as true

  // Original list of all possible categories
  final List<Map<String, dynamic>> _categories = [
    {
      'iconAsset': 'assets/icons/youtube.png', // Path to your custom workout icon
      'label': 'Workout',
      'route': null // Default Workout might not navigate, but show content below
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

    // --- Role-Based Filtering Logic ---
    if (_userData.containsKey('role')) {
      final String userRole = _userData['role'];

      if (userRole == 'Self-Trainee') {
        // Exclude Nutrition
        categories.removeWhere((category) => category['label'] == 'Nutrition');
        // Modify Workout to point to YouTube
        categories = categories.map((category) {
          if (category['label'] == 'Workout') {
            return {
              'iconAsset': 'assets/icons/youtube.png', // Keep YouTube icon
              'label': 'YT_Workout', // Internal label, displayed as 'Workout'
              'route': 'YT_Channel', // Route to launch YouTube
            };
          }
          return category;
        }).toList();
      } else if (userRole == 'Trainee') {
        // Example: Maybe Trainees see Nutrition but not YT link directly
        // No specific changes needed based on current logic, but could add rules here.
      } else if (userRole == 'Trainer') {
        // Example: Trainers might see different categories
        // categories.removeWhere((category) => category['label'] == 'Products');
      }
      // Add more role conditions as needed
    } else {
      // Default view for users with no role or before role is loaded
      // Example: Remove Nutrition by default if not logged in or no role
      categories.removeWhere((category) => category['label'] == 'Nutrition');
    }

    return categories;
  }


  // Made _workouts mutable for favorite state changes
  // Ensure these workouts match the visual style/content if needed [1]
  List<Map<String, dynamic>> _workouts = [
    {
      'title': 'Squat Exercise', // Matches image [1]
      'image': 'assets/workout1.jpg', // Make sure these assets exist and match image [1]
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6', // Example URL
      'duration': '12 Minutes', // Matches image [1]
      'calories': '120 Kcal', // Matches image [1]
      'isFavorite': false, // Initialize as false, load state later
    },
    {
      'title': 'Full Body Stretching', // Matches image [1]
      'image': 'assets/workout2.jpg', // Make sure these assets exist and match image [1]
      'color': Colors.blue,
      'videoUrl': 'https://www.youtube.com/watch?v=3sH7wbIZjEY', // Example URL
      'duration': '12 Minutes', // Matches image [1]
      'calories': '120 Kcal', // Matches image [1]
      'isFavorite': false, // Default to false, load state later
    },
    // Add more workouts if needed
  ];

  final List<Map<String, String>> _healthAndFitItems = [
    {
      'title': 'Supplement Guide', // Matches image [1]
      'description': '',
      'image': 'assets/supplement.jpg', // Make sure this asset exists and matches image [1]
    },
    {
      'title': '15 Quick & Effective Daily Routines', // Matches image [1]
      'description': '',
      'image': 'assets/daily.jpg', // Make sure this asset exists and matches image [1]
    },
    // Add more items if needed
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data first, then load favorites which might depend on user ID
    _fetchCurrentUserData().then((_) {
      // Only load favorites if user data fetch was successful and component still mounted
      if (mounted && _userData.isNotEmpty) {
        _loadFavorites(); // Load favorites after user data is fetched
      }
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
            // Ensure data is Map<String, dynamic>
            _userData = Map<String, dynamic>.from(userDoc.data() as Map<dynamic, dynamic>);
          });
        } else {
          print("User document does not exist for UID: ${currentUser.uid}");
          // Handle case where user doc doesn't exist (e.g., show default view)
          if (mounted) setState(() => _userData = {}); // Clear user data
        }
      } else {
        print("No current user logged in.");
        // Handle case where no user is logged in (e.g., show guest view)
        if (mounted) setState(() => _userData = {}); // Clear user data
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
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return; // No user, cannot load favorites

    try {
      DocumentSnapshot favoritesDoc =
      await _firestore.collection('favorites').doc(currentUser.uid).get();

      if (favoritesDoc.exists && mounted) {
        Map<String, dynamic> favoritesData = favoritesDoc.data() as Map<String, dynamic>;
        List<dynamic> favoriteWorkoutsTitlesDynamic = favoritesData['workouts'] ?? [];
        List<String> favoriteWorkoutsTitles = favoriteWorkoutsTitlesDynamic.cast<String>();

        // Create a new list to avoid modifying state directly during iteration
        List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts);
        for (int i = 0; i < updatedWorkouts.length; i++) {
          String workoutTitle = updatedWorkouts[i]['title'] as String;
          updatedWorkouts[i]['isFavorite'] = favoriteWorkoutsTitles.contains(workoutTitle);
        }

        if (mounted) {
          setState(() {
            _workouts = updatedWorkouts;
          });
        }
      } else {
        print("No favorites document found for user ${currentUser.uid}");
        // Ensure all workouts are marked as not favorite if doc doesn't exist
        if (mounted) {
          setState(() {
            List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts);
            for (var workout in updatedWorkouts) {
              workout['isFavorite'] = false;
            }
            _workouts = updatedWorkouts;
          });
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
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to save favorites.")),
        );
      }
      return;
    }

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
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other potential favorite types

      print("Favorites saved successfully.");

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
        print("Workout category tapped (no specific route assigned)");
        break;
      case 'Nutrition':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NutritionPage())); // Ensure NutritionPage exists
        break;
      case 'ChatBot':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ChatPage())); // Ensure ChatPage exists
        break;
      case 'CalorieCalculator':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CalorieCalculator())); // Ensure CalorieCalculator exists
        break;
      case 'SupplementsStore':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SupplementsStorePage())); // Ensure SupplementsStorePage exists
        break;
      case 'YT_Channel':
        _launchYouTubeChannel();
        break;
      // case 'VideosPage': // Handle 'See All' tap for workouts
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => AllVideosPage(videos: _workouts))); // Ensure AllVideosPage exists and accepts videos
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
    await _launchUrlHelper('https://www.youtube.com/@yusufashraf17'); // Use actual channel URL
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
          builder: (context) => ProfilePage(userId: currentUser.uid), // Ensure ProfilePage exists
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
      MaterialPageRoute(builder: (context) => const TrainerTraineesPage()), // Ensure TrainerTraineesPage exists
    );
  }

  void _navigateToChatbot() {
    if (!mounted) return;
    // Chat is now in bottom nav, this might be redundant unless called from elsewhere
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()), // Ensure ChatPage exists
    );
  }

  // --- State Management ---
  void _toggleFavorite(int index) {
    if (!mounted) return;
    setState(() {
      if (index >= 0 && index < _workouts.length) {
        // Toggle the boolean state
        _workouts[index]['isFavorite'] = !(_workouts[index]['isFavorite'] as bool? ?? false);
      } else {
        print("Error: Invalid index $index for toggling favorite.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error updating favorite status.")),
          );
        }
        return; // Exit if index is invalid
      }
    });
    // Save the updated favorites list to Firestore
    _saveFavorites();
  }


  // --- WIDGET BUILDERS ---

  // Builds a single category icon widget
  Widget _buildCategoryIcon(String iconAsset, String label, int index) {
    String displayLabel = (label == 'YT_Workout') ? 'Workout' : label;

    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        String? route = _filteredCategories[index]['route'];
        _navigateToFeature(route);

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
                print("Error loading icon image '$iconAsset': $error");
                return const Icon(
                  Icons.category,
                  color: Color(0xFF8E7AFE),
                  size: 30,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds a single workout card
  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index) {
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
        margin: const EdgeInsets.only(right: 12),
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
                      color: Colors.black54,
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
                    onTap: () => _toggleFavorite(_workouts.indexWhere((w) => w['title'] == title)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 14),
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
                      const Icon(Icons.local_fire_department_outlined, color: Colors.orangeAccent, size: 14),
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


  // Builds a single card for the Health & Fit section
  Widget _buildHealthAndFitCard(Map<String, String> item) {
    final imageUrl = item['image'] ?? 'assets/placeholder.png';
    final title = item['title'] ?? 'Health & Fit Item';

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

  // Builds the rating section (only shown for 'Trainee' role)
  Widget _buildRatingSection() {
    // Placeholder data - Fetch actual rating data if needed
    String coachName = "Coach Name"; // Fetch from user data or trainee profile
    String coachImageUrl = "assets/coach_placeholder.png"; // Fetch actual image path
    double currentRating = 4.0; // Fetch last given rating
    String lastComment = "Last comment here..."; // Fetch last comment

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Rating",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_note, size: 18, color: Color(0xFF8E7AFE)),
                label: const Text(
                  "Add/Edit Rating",
                  style: TextStyle(
                    color: Color(0xFF8E7AFE),
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRatingPage()), // Ensure AddRatingPage exists
                  ).then((_) {
                    print("Returned from AddRatingPage");
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
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
                    RatingBarIndicator(
                      rating: currentRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      unratedColor: Colors.grey[800],
                      direction: Axis.horizontal,
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
                      "Coach: $coachName",
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
    );
  }


  // Builds the view for displaying favorite workouts.
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
                Icons.star_border_rounded,
                color: Colors.grey,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                "No Favorites Yet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Tap the star icon on workouts to save them here.",
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

  // Builds a card specifically for the Favorites list
  Widget _buildFavoriteWorkoutCard(Map<String, dynamic> workout, int originalIndex) {
    final videoUrl = workout['videoUrl'] as String?;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png';
    final title = workout['title'] as String? ?? 'Favorite Workout';
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
                      color: Colors.black54,
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
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.yellowAccent,
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
                    const Icon(Icons.timer_outlined, color: Colors.grey, size: 16),
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
                    const Icon(Icons.local_fire_department_outlined, color: Colors.orangeAccent, size: 16),
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
    String userName = _isLoadingUserData
        ? 'User'
        : (_userData['firstName'] as String? ?? 'User');

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
            // --- Top Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName", // Display user name
                          // --- MODIFIED: Changed text color ---
                          style: const TextStyle(
                            color: Color(0xFF896CFE), // Color #896CFE [User Request]
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Ready to crush your goals today?",
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
                            const SnackBar(content: Text('Search functionality not implemented yet.'))
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
                            const SnackBar(content: Text('Notifications functionality not implemented yet.'))
                        );
                      }
                    },
                    tooltip: 'Notifications',
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: _navigateToProfile,
                    tooltip: 'Profile',
                  ),
                ],
              ),
            ),

            // --- Category Icons Section ---
            if (_filteredCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: _filteredCategories.length > 3
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.spaceAround,
                  children: List.generate(_filteredCategories.length, (index) {
                    final category = _filteredCategories[index];
                    return _buildCategoryIcon(
                      category['iconAsset'] as String,
                      category['label'] as String,
                      index,
                    );
                  }),
                ),
              ),


            // --- Workouts Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Workouts",
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
              height: 210,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _workouts.length,
                itemBuilder: (context, index) =>
                    _buildWorkoutCard(_workouts[index], index),
              ),
            ),
            const SizedBox(height: 24),


            // --- Promotional Banner (MODIFIED Padding) ---
            if (!(_userData.containsKey('role') && _userData['role'] == 'Trainee')) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container( // Outer container
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3A0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // --- MODIFIED: Increased padding to make inner box smaller ---
                  padding: const EdgeInsets.all(12), // Increased padding [User Request]
                  child: Container( // Inner container
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(15), // Keep inner rounding slightly less than outer
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Achieve Your Goals",
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Plank With Hip Twist",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/plank_image.png',
                            height: 65,
                            width: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading banner image 'assets/plank_image.png': $error");
                              return Container(
                                height: 65,
                                width: 65,
                                color: Colors.grey[700],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                              );
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


            // --- Rating Section (Conditional) ---
            if (_userData.containsKey('role') && _userData['role'] == 'Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRatingSection(),
              ),
              const SizedBox(height: 24),
            ],

            // --- Health & Fit Section ---
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


            // --- Trainer Button (Conditional) ---
            if (_userData.containsKey('role') &&
                _userData['role'] != 'Trainee' &&
                _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _navigateToTrainees,
                  icon: const Icon(Icons.group),
                  label: const Text("View My Trainees"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8E7AFE),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

          ],
        ),
      );
    } else if (_currentNavIndex == 1) {
      // Store Tab (Navigated to via onTap)
      mainContent = Center(child: Text("Store Tab (handled by navigation)", style: TextStyle(color: Colors.white)));
      // Or optionally: mainContent = _buildFavoritesView();
    } else if (_currentNavIndex == 2) { // Chat Tab Content
      mainContent = const ChatPage();
    } else { // Fallback
      mainContent = const Center(
        child: Text("Invalid Tab Index", style: TextStyle(color: Colors.white)),
      );
    }

    // --- Scaffold Structure ---
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: mainContent,
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (!mounted) return;
            if (index == 1) { // Store
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupplementsStorePage()),
              );
            } else { // Home (0) or Chat (2)
              setState(() {
                _currentNavIndex = index;
              });
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF8E7AFE),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
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

// --- Ensure necessary imports, pages, and assets exist ---
