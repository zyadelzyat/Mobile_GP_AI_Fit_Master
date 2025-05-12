import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming needed for ThemeProvider if used
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import Rating Bar
import 'package:untitled/AI/chatbot.dart'; // Replace 'untitled' with your project name
import 'package:untitled/Home__Page/NutritionMainPage.dart';
import 'profile.dart';
// import 'package:untitled/theme_provider.dart'; // Uncomment if needed
import 'package:untitled/videos_page.dart'; // Replace 'untitled'
import 'CalorieCalculator.dart'; // Replace 'untitled' if needed
import 'Store.dart'; // Replace 'untitled' if needed
import 'trainer_trainees_page.dart'; // Replace 'untitled' if needed
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/rating/AddRatingPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0; // 0: Home, 1: Favorites, 2: AI Coach, 3: Profile
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map _userData = {}; // Use specific type
  bool _isLoadingUserData = true; // Start as true

  // Static categories definitions
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fitness_center, 'label': 'Workout', 'route': null}, // Route null for default workout section
    {'icon': Icons.insert_chart, 'label': 'Nutrition', 'route': 'Nutrition'},
    {'icon': Icons.shopping_bag, 'label': 'Products', 'route': 'SupplementsStore'},
    {'icon': Icons.calculate_outlined, 'label': 'Calories', 'route': 'CalorieCalculator'},
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
            'icon': null, // Use null to indicate custom image (YouTube logo)
            'label': 'YT_Workout', // Special label to identify YouTube workout
            'route': 'YT_Channel', // Route to launch YouTube channel
          };
        }
        return category;
      }).toList();
    }
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

  Future _fetchCurrentUserData() async {
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
            _userData = userDoc.data() as Map;
          });
        } else {
          print("User document does not exist for UID: ${currentUser.uid}");
          // Handle case where user doc doesn't exist (e.g., show error or default values)
        }
      } else {
        print("No current user logged in.");
        // Handle case where no user is logged in (e.g., navigate to login)
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

  Future _loadFavorites() async {
    if (!mounted) return; // Check if component is still mounted
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot favoritesDoc =
        await _firestore.collection('favorites').doc(currentUser.uid).get();
        if (favoritesDoc.exists && mounted) {
          Map favoritesData =
          favoritesDoc.data() as Map;
          List favoriteWorkoutsTitlesDynamic = favoritesData['workouts'] ?? [];
          List favoriteWorkoutsTitles = favoriteWorkoutsTitlesDynamic.cast();
          // Update the 'isFavorite' status in the local _workouts list
          List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts); // Create copy
          for (int i = 0; i < updatedWorkouts.length; i++) {
            String workoutTitle = updatedWorkouts[i]['title'];
            updatedWorkouts[i]['isFavorite'] = favoriteWorkoutsTitles.contains(workoutTitle);
          }
          if (mounted) {
            setState(() {
              _workouts = updatedWorkouts; // Assign the updated list back
            });
          }
        } else {
          print("No favorites document found for user ${currentUser.uid}");
          // Ensure all workouts are marked as not favorite if no document exists
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

  Future _saveFavorites() async {
    if (!mounted) return; // Check if component is still mounted
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Collect titles of favorite workouts
        List favoriteWorkoutsTitles = [];
        for (var workout in _workouts) {
          if (workout['isFavorite'] == true) {
            favoriteWorkoutsTitles.add(workout['title']);
          }
        }
        // Save to Firestore
        await _firestore.collection('favorites').doc(currentUser.uid).set({
          'workouts': favoriteWorkoutsTitles,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Use merge to avoid overwriting other potential fields
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
      // Default workout section is part of the main screen, do nothing
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
                builder: (context) => const CalorieCalculator()));
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
      default:
        print("Unknown route: $routeName");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navigation for '$routeName' not implemented.")),
          );
        }
    }
  }

  Future _launchUrlHelper(String url) async {
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

  // Specific launch functions
  Future _launchYouTubeChannel() async {
    await _launchUrlHelper('https://www.youtube.com/@yusufashraf17');
  }

  Future _launchVideo(String url) async {
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
      // Check index bounds before accessing _workouts
      if (index >= 0 && index < _workouts.length) {
        _workouts[index]['isFavorite'] = !_workouts[index]['isFavorite'];
      } else {
        // Handle error: Index out of bounds
        print("Error: Invalid index $index for toggling favorite.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error updating favorite status.")),
          );
        }
        return; // Exit if index is invalid
      }
    });
    _saveFavorites(); // Save changes to Firestore
  }

  // --- WIDGET BUILDERS ---
  Widget _buildCategoryIcon(dynamic icon, String label, int index) {
    // Determine the display label (show "Workout" even if label is "YT_Workout")
    String displayLabel = (label == 'YT_Workout') ? 'Workout' : label;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedCategoryIndex = index;
        });
        // Navigate if a route is defined
        String? route = _filteredCategories[index]['route'];
        if (route != null) {
          _navigateToFeature(route);
        }
        // If it's the default 'Workout' category (which has route null), do nothing extra on tap here.
        else if (_filteredCategories[index]['label'] == 'Workout'){
          print("Workout category tapped (no specific route assigned)");
          // Optionally handle this case, e.g., scroll to workout section
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
            // Use play icon if icon is null (for YT_Workout), otherwise use the provided icon
            child: icon == null
                ? const Icon(
              Icons.play_circle_fill, // YouTube-like play icon
              color: Color(0xFF8E7AFE),
              size: 24,
            )
                : Icon(
              icon as IconData,
              color: const Color(0xFF8E7AFE),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayLabel, // Use the adjusted display label
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

  Widget _buildWorkoutCard(Map workout, int index) {
    final videoUrl = workout['videoUrl'] as String?;
    final isFavorite = workout['isFavorite'] as bool? ?? false; // Safely handle null
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png'; // Provide a default
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
        width: MediaQuery.of(context).size.width * 0.44, // Responsive width
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Dark card background
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center, // Center play button
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
                      // Log error and show placeholder
                      print("Error loading workout image '$imageUrl': $error");
                      return Container(
                        height: 100,
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                // Show play button overlay if video exists
                if (videoUrl != null && videoUrl.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45, // Semi-transparent background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                // Favorite (Star) Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(index), // Use the passed index
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border, // Reflect favorite state
                        color: Colors.yellow, // Star color
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
                      Expanded( // Use Expanded to prevent overflow
                        child: Text(
                          duration,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8), // Space between duration and calories
                      const Icon(Icons.local_fire_department, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded( // Use Expanded
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

  Widget _buildHealthAndFitCard(Map item) {
    final imageUrl = item['image'] ?? 'assets/placeholder.png'; // Default image
    final title = item['title'] ?? 'No Title'; // Default title
    return Container(
      width: MediaQuery.of(context).size.width * 0.44, // Responsive width
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Dark card background
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
                // Log error and show placeholder
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
    // --- Placeholder Data ---
    String coachName = "Coach";
    String coachImageUrl = "assets/coach_placeholder.png";
    double currentRating = 4.0;
    String lastComment = "Good effort but ..........";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB3A0FF), // Outer container with light purple #B3A0FF
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Inner dark container
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: My Rate and Add Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // My Rate with star icon
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
                // Add Rating button
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
            // Coach info, stars and comment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coach avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(coachImageUrl),
                  backgroundColor: Colors.grey[800],
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading coach image: $exception');
                  },
                ),
                const SizedBox(width: 12),
                // Rating and comment column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Star rating
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
                      // Comment text
                      Text(
                        lastComment,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Coach name
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

  // **** END: UPDATED Rating Section Widget Builder ****

  Widget _buildFavoritesView() {
    if (!mounted) return const SizedBox.shrink(); // Handle component unmounting
    // Filter workouts marked as favorite
    List<Map<String, dynamic>> favoriteWorkouts =
    _workouts.where((workout) => workout['isFavorite'] == true).toList();
    // Display a message if no favorites exist
    if (favoriteWorkouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Add padding around the message
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: const [
              Icon(
                Icons.star_border, // Empty star icon
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
                textAlign: TextAlign.center, // Center align the description
              ),
            ],
          ),
        ),
      );
    }

    // Build a list view of favorite workout cards
    return ListView.builder(
      padding: const EdgeInsets.all(16), // Padding around the list
      itemCount: favoriteWorkouts.length,
      itemBuilder: (context, index) {
        // Find the original index in the main _workouts list to allow toggling
        // This is important because _toggleFavorite uses the index from the main list
        final originalIndex = _workouts.indexWhere(
                (workout) => workout['title'] == favoriteWorkouts[index]['title']);
        if (originalIndex == -1) {
          // Handle edge case where workout might not be found (shouldn't happen usually)
          print("Warning: Could not find original index for favorite workout: ${favoriteWorkouts[index]['title']}");
          return const SizedBox.shrink(); // Return an empty widget
        }
        return _buildFavoriteWorkoutCard(favoriteWorkouts[index], originalIndex);
      },
    );
  }

  // Helper widget for displaying a favorite workout card
  Widget _buildFavoriteWorkoutCard(Map workout, int originalIndex) {
    final videoUrl = workout['videoUrl'] as String?;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png';
    final title = workout['title'] as String? ?? 'No Title';
    final duration = workout['duration'] as String? ?? '-';
    final calories = workout['calories'] as String? ?? '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Space between cards
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Dark card background
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
                  height: 180, // Larger image for favorite view
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
              // Play button overlay
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
              // Favorite (Star) Icon - Always filled for favorites tab
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(originalIndex), // Use original index to toggle
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star, // Always filled star in favorites view
                      color: Colors.yellow,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16), // More padding for details
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Slightly larger title
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
    // Determine user name, show 'User' while loading or if name is missing
    String userName = _isLoadingUserData ? 'User' : (_userData['firstName'] as String? ?? 'User');

    // Determine which content to show based on the selected navigation index
    Widget mainContent;
    if (_isLoadingUserData) {
      // Show loading indicator while fetching user data
      mainContent = const Center(
        child: CircularProgressIndicator(color: Color(0xFF8E7AFE)), // Use theme color
      );
    } else if (_currentNavIndex == 0) { // Home Tab Content
      mainContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Nice scroll effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Standard padding
              child: Row(
                children: [
                  Expanded( // Allow text column to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName", // Display user's first name
                          style: const TextStyle(
                            color: Color(0xFF8E7AFE), // Accent color
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // Handle long names
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "It's time to challenge your limits.", // Subtitle
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
                  // Action Icons (Search, Notifications)
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement search functionality
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Search not implemented yet.'))
                        );
                      }
                    },
                    tooltip: 'Search',
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {
                      // TODO: Implement notifications functionality
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifications not implemented yet.'))
                        );
                      }
                    },
                    tooltip: 'Notifications',
                  ),
                ],
              ),
            ),
            // --- Category Icons Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute icons evenly
                children: List.generate(_filteredCategories.length, (index) {
                  final category = _filteredCategories[index];
                  return _buildCategoryIcon(
                    category['icon'],
                    category['label'],
                    index,
                  );
                }),
              ),
            ),
            // --- Workouts Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align title left, 'See All' right
                children: [
                  const Text(
                    "Workouts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector( // Make 'See All' tappable
                    onTap: () {
                      _navigateToFeature('VideosPage'); // Navigate to all videos page
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Prevent row taking full width
                      children: const [
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Color(0xFF8E7AFE), // Accent color
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
            SizedBox( // Constrain the height of the horizontal list
              height: 200, // Adjust height as needed for workout cards
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16), // Padding for list items
                scrollDirection: Axis.horizontal, // Make list scroll horizontally
                itemCount: _workouts.length,
                itemBuilder: (context, index) =>
                    _buildWorkoutCard(_workouts[index], index), // Pass index
              ),
            ),
            const SizedBox(height: 24), // Spacing before next section

            // --- Promotional Banner ---
            // Only show the "Don't Give Up" banner if user role is NOT 'Trainee'
            if (!(_userData.containsKey('role') && _userData['role'] == 'Trainee')) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity, // Full width banner
                  height: 120, // Fixed height
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E7AFE).withOpacity(0.2), // Light accent background
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded( // Text section takes available space
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                            children: const [
                              Text(
                                "Don't Give Up", // Banner title
                                style: TextStyle(
                                  color: Colors.yellow, // Highlight color
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Explore Plans with Pro Tips!", // Banner subtitle
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Banner Image
                      ClipRRect( // Clip image to match container radius
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(15)), // Only round right corners
                        child: Image.asset(
                          'assets/workout1.jpg', // Use a relevant banner image
                          width: 150, // Fixed image width
                          height: 120, // Match container height
                          fit: BoxFit.cover, // Cover the area
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading banner image: $error");
                            return Container( // Placeholder on error
                              width: 150, height: 120, color: Colors.grey[800],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24), // Spacing
            ],

            // **** START: Conditional Rating Section ****
            // Conditionally display the updated rating section only if the user role is 'Trainee'
            if (_userData.containsKey('role') && _userData['role'] == 'Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRatingSection(),
              ),
              const SizedBox(height: 24), // Spacing after rating section
            ],
            // **** END: Conditional Rating Section ****

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
            SizedBox( // Horizontal list for health/fit items
              height: 180, // Adjust height as needed
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _healthAndFitItems.length,
                itemBuilder: (context, index) =>
                    _buildHealthAndFitCard(_healthAndFitItems[index]),
              ),
            ),
            const SizedBox(height: 24), // Spacing

            // --- Conditional Trainer Button ---
            // Show this button only if the user role is NOT 'Trainee' and NOT 'Self-Trainee' (e.g., 'Trainer')
            if (_userData.containsKey('role') &&
                _userData['role'] != 'Trainee' &&
                _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: _navigateToTrainees, // Navigate to trainees page
                  child: Container(
                    width: double.infinity, // Full width
                    height: 60, // Fixed height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF8E7AFE).withOpacity(0.2), // Accent background
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center content
                      children: [
                        Icon(Icons.group, color: Color(0xFF8E7AFE)), // Group icon
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
            const SizedBox(height: 16), // Bottom padding inside scroll view
          ],
        ),
      );
    } else if (_currentNavIndex == 1) { // Favorites Tab Content
      mainContent = _buildFavoritesView();
    } else if (_currentNavIndex == 2) { // AI Coach Tab Content
      mainContent = const ChatPage(); // Show ChatPage directly
    } else { // Fallback for invalid index (shouldn't normally happen)
      mainContent = const Center(
        child: Text("Invalid Tab Index", style: TextStyle(color: Colors.white)),
      );
    }

    // --- Scaffold Structure ---
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Main background color for the app
      body: SafeArea( // Ensure content avoids notches and system bars
        child: mainContent, // Display the selected content widget
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex, // Highlight the current tab
        onTap: (index) {
          if (!mounted) return;
          // Handle tab taps
          if (index == 3) { // Profile Tab (Index 3)
            _navigateToProfile(); // Navigate to profile page
            // NOTE: We don't update _currentNavIndex here because Profile is a separate page,
            // not just a different view within the main Scaffold body controlled by the index.
            // The visual selection will remain on the previous tab until the user navigates back.
          } else {
            // For Home, Favorites, AI Coach tabs, just update the state
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
        backgroundColor: const Color(0xFFB29BFF), // Match background
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70, // Color for unselected items
        type: BottomNavigationBarType.fixed, // Keep items fixed, labels always visible
        showUnselectedLabels: true, // Ensure labels are always shown
        selectedFontSize: 12, // Font size for labels
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/Stars.png')),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/chat.png')),
            label: 'AI COACH',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/profile.png')),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper class for displaying all videos page (navigated from "See All")
// -----------------------------------------------------------------------------
class AllVideosPage extends StatelessWidget {
  final List<Map<String, dynamic>> videos; // Receive list of videos
  const AllVideosPage({Key? key, required this.videos}) : super(key: key);

  // Helper to launch video URL safely
  Future _launchVideo(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!context.mounted) return; // Check if context is still valid
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication); // Open externally
      } else {
        print("Could not launch $url");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $url")),
          );
        }
      }
    } catch (e) {
      print("Error launching URL $url: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching video: ${e.toString()}")),
        );
      }
    }
  }

  // Builder for individual video cards in the list
  Widget _buildVideoCard(BuildContext context, Map video) {
    final videoUrl = video['videoUrl'] as String?;
    final imageUrl = video['image'] as String? ?? 'assets/placeholder.png';
    final title = video['title'] as String? ?? 'No Title';
    final duration = video['duration'] as String? ?? '-';
    final calories = video['calories'] as String? ?? '-';
    return GestureDetector(
      onTap: () {
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _launchVideo(context, videoUrl);
        } else {
          print("No video URL for: $title");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No video available for this item.")),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Space between cards
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Dark card background
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
                    height: 180, // Consistent image height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading video image '$imageUrl': $error");
                      return Container( // Placeholder on error
                        height: 180, color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                // Play button overlay
                if (videoUrl != null && videoUrl.isNotEmpty)
                  Container(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Match theme background
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Match theme background
        title: const Text(
          "All Workouts",
          style: TextStyle(color: Colors.white), // White title
        ),
        leading: IconButton( // Explicit back button for clarity
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Go back to the previous screen
            }
          },
          tooltip: 'Back',
        ),
        elevation: 0, // No shadow for a flatter look
      ),
      body: videos.isEmpty
          ? const Center(child: Text("No workouts available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16), // Padding for the list view
        itemCount: videos.length,
        itemBuilder: (context, index) => _buildVideoCard(context, videos[index]),
      ),
    );
  }
}
