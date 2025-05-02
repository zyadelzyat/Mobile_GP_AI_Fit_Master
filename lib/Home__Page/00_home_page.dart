import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import Rating Bar

import 'package:untitled/AI/chatbot.dart';
import 'package:untitled/profile.dart';
import 'package:untitled/theme_provider.dart';
import 'package:untitled/videos_page.dart';
import 'CalorieCalculator.dart';
import 'Store.dart';
import 'trainer_trainees_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled/Home__Page/NutritionMainPage.dart';

// Import the Add Rating Page (ensure this file exists)
import 'AddRatingPage.dart'; // Import Add Rating Page

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
  Map<String, dynamic> _userData = {}; // Specify type
  bool _isLoadingUserData = true; // Start as true

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fitness_center, 'label': 'Workout', 'route': null},
    {'icon': Icons.insert_chart, 'label': 'Nutrition', 'route': 'Nutrition'},
    {'icon': Icons.shopping_bag, 'label': 'Products', 'route': 'SupplementsStore'},
    {'icon': Icons.calculate_outlined, 'label': 'Calories', 'route': 'CalorieCalculator'},
  ];

  // Dynamic categories based on user role
  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> categories = List.from(_categories); // Create a modifiable copy
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

  // Ensure consistent typing for maps
  // Made _workouts mutable for favorite state changes
  List<Map<String, dynamic>> _workouts = [
    {
      'title': '3 tips for gym beginners',
      'image': 'assets/workout1.jpg', // Make sure these assets exist
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6',
      'duration': '8 Minutes',
      'calories': '90 kcal',
      'isFavorite': false,
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
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Optionally show an error message to the user
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
    if (!mounted) return;
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot favoritesDoc =
        await _firestore.collection('favorites').doc(currentUser.uid).get();
        if (favoritesDoc.exists && mounted) {
          Map<String, dynamic> favoritesData =
          favoritesDoc.data() as Map<String, dynamic>;
          // Ensure 'workouts' exists and is a list, default to empty list if null
          List<dynamic> favoriteWorkoutsTitles = favoritesData['workouts'] as List<dynamic>? ?? [];

          // Update the 'isFavorite' status in the local _workouts list
          List<Map<String, dynamic>> updatedWorkouts = List.from(_workouts); // Create copy
          for (int i = 0; i < updatedWorkouts.length; i++) {
            String workoutTitle = updatedWorkouts[i]['title'];
            updatedWorkouts[i]['isFavorite'] = favoriteWorkoutsTitles.contains(workoutTitle);
          }

          // Update state only if component is still mounted
          if (mounted) {
            setState(() {
              _workouts = updatedWorkouts; // Assign the updated list back
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
    if (!mounted) return;
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
        }, SetOptions(merge: true)); // Use merge to avoid overwriting other potential favorite types
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

  void _navigateToFeature(String? routeName) {
    if (routeName == null || !mounted) return;

    switch (routeName) {
      case 'Workout':
      // Maybe navigate to a general workout page or do nothing if handled by categories
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
    // Add other cases if needed
    }
  }

  Future<void> _launchUrlHelper(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) { // Check context validity
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $url")),
        );
      }
      print("Could not launch $url");
    }
  }

  Future<void> _launchYouTubeChannel() async {
    await _launchUrlHelper('https://www.youtube.com/@yusufashraf17');
  }

  Future<void> _launchVideo(String url) async {
    await _launchUrlHelper(url);
  }

  void _navigateToProfile() {
    if (!mounted) return; // Check context validity
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: currentUser.uid),
        ),
      );
    } else {
      // Avoid showing snackbar if not mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("You need to be logged in to view your profile")),
        );
      }
    }
  }

  void _navigateToTrainees() {
    if (!mounted) return; // Check context validity
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerTraineesPage()),
    );
  }

  void _navigateToChatbot() {
    if (!mounted) return; // Check context validity
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  void _toggleFavorite(int index) {
    if (!mounted) return; // Check context validity
    setState(() {
      // Ensure index is valid before accessing
      if (index >= 0 && index < _workouts.length) {
        _workouts[index]['isFavorite'] = !_workouts[index]['isFavorite'];
      } else {
        print("Error: Invalid index $index for toggling favorite.");
      }
    });
    _saveFavorites(); // Save changes to Firestore
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCategoryIcon(dynamic icon, String label, int index) {
    bool isSelected = _selectedCategoryIndex == index; // Not currently used, but kept
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedCategoryIndex = index;
        });
        // Use _filteredCategories to get the correct route based on role
        if (_filteredCategories[index]['route'] != null) {
          _navigateToFeature(_filteredCategories[index]['route']);
        }
        // Handle 'Workout' tap specifically if needed (currently route is null)
        else if (_filteredCategories[index]['label'] == 'Workout') {
          // Maybe open a workout section within home or navigate somewhere else
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
            child: icon == null // Handle custom YouTube icon case
                ? const Icon(
              Icons.play_circle_fill, // YouTube-like play icon
              color: Color(0xFF8E7AFE),
              size: 24,
            )
                : Icon( // Handle standard icon case
              icon as IconData, // Assuming icon is IconData if not null
              color: const Color(0xFF8E7AFE),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == 'YT_Workout' ? 'Workout' : label, // Display 'Workout' for YT_Workout
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center, // Ensure text centers if it wraps
          ),
        ],
      ),
    );
  }


  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index) {
    // Added null check for safety, although data structure implies non-null
    final videoUrl = workout['videoUrl'] as String?;
    final isFavorite = workout['isFavorite'] as bool? ?? false;
    final imageUrl = workout['image'] as String? ?? 'assets/placeholder.png'; // Default placeholder
    final title = workout['title'] as String? ?? 'No Title';
    final duration = workout['duration'] as String? ?? '-';
    final calories = workout['calories'] as String? ?? '-';

    return GestureDetector(
      onTap: () {
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _launchVideo(videoUrl);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44, // Card width
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Card background
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
                      // Error builder for image loading issues
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading workout image '$imageUrl': $error");
                        return Container(
                          height: 100,
                          color: Colors.grey[800],
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                        );
                      }
                  ),
                ),
                // Play button overlay only if videoUrl exists
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
                // Favorite (Star) button overlay
                Positioned(
                  top: 8, // Adjusted position
                  right: 8, // Adjusted position
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
                        color: Colors.yellow, // Use yellow for star
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
                  // **** START: RenderFlex Overflow Fix ****
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      // Wrap Text with Expanded
                      Expanded(
                        child: Text(
                          duration,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis, // Prevent overflow within Expanded
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8), // Space between duration and calories
                      const Icon(Icons.local_fire_department, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      // Wrap Text with Expanded
                      Expanded(
                        child: Text(
                          calories,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis, // Prevent overflow within Expanded
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  // **** END: RenderFlex Overflow Fix ****
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHealthAndFitCard(Map<String, dynamic> item) {
    final imageUrl = item['image'] as String? ?? 'assets/placeholder.png';
    final title = item['title'] as String? ?? 'No Title';

    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Card background
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
                }
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

  // **** START: Added Rating Section Widget Builder ****
  Widget _buildRatingSection() {
    // TODO: Fetch ACTUAL trainer info and rating for the current trainee from Firestore.
    // This likely involves querying the 'ratings' collection based on traineeId (currentUser.uid)
    // and potentially fetching the associated trainer's details from the 'users' collection.
    // For now, using placeholders.
    String coachName = "Coach John"; // Placeholder - Replace with actual data
    String coachImageUrl = "assets/coach_placeholder.png"; // Placeholder - ENSURE THIS ASSET EXISTS AND IS DECLARED
    double currentRating = 4.0; // Placeholder - Replace with actual data
    String lastComment = "Good effort but keep pushing!"; // Placeholder - Replace with actual data

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Dark background like other cards
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Rate",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell( // Make "Add Rating" tappable
                onTap: () {
                  if (!mounted) return; // Check context validity
                  // Navigate to the Add Rating page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRatingPage()), // Navigate to the AddRatingPage
                  ).then((_) {
                    // Optional: Refresh rating data here if needed after rating is submitted
                    print("Returned from AddRatingPage");
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Colors.yellow, size: 20), // Use yellow star
                    SizedBox(width: 4),
                    Text(
                      "Add Rating",
                      style: TextStyle(
                        color: Color(0xFF8E7AFE), // Accent color
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
            children: [
              CircleAvatar(
                radius: 25,
                // Use AssetImage for local assets
                backgroundImage: AssetImage(coachImageUrl),
                backgroundColor: Colors.grey[800], // Fallback color
                // Handle image errors for CircleAvatar
                onBackgroundImageError: (exception, stackTrace) {
                  // Log error - this is where the "Unable to load asset" comes from
                  print('Error loading coach image: $exception');
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coachName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Use RatingBarIndicator to DISPLAY the rating
                    RatingBarIndicator(
                      rating: currentRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber, // Use amber/yellow for filled stars
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      unratedColor: Colors.amber.withAlpha(50), // Lighter color for unrated
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastComment,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
  // **** END: Added Rating Section Widget Builder ****


  Widget _buildFavoritesView() {
    if (!mounted) return const SizedBox.shrink(); // Handle disposed state

    List<Map<String, dynamic>> favoriteWorkouts =
    _workouts.where((workout) => workout['isFavorite'] == true).toList();

    if (favoriteWorkouts.isEmpty) {
      return Center(
        child: Padding( // Add padding for better spacing
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

    // Display favorites in a ListView
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteWorkouts.length,
      itemBuilder: (context, index) {
        // Find the original index in the main _workouts list to allow toggling
        // This assumes titles are unique identifiers within _workouts
        final originalIndex = _workouts.indexWhere(
                (workout) => workout['title'] == favoriteWorkouts[index]['title']);

        // Check if originalIndex is valid before building the card
        if (originalIndex == -1) {
          print("Warning: Could not find original index for favorite workout: ${favoriteWorkouts[index]['title']}");
          return const SizedBox.shrink(); // Don't build card if index is invalid
        }

        // Reuse a card structure similar to AllVideosPage or create a dedicated one
        return _buildFavoriteWorkoutCard(favoriteWorkouts[index], originalIndex);
      },
    );
  }

  // Helper widget for displaying a favorite workout card
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
                    height: 180, // Larger image for favorites view
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading favorite image '$imageUrl': $error");
                      return Container(
                        height: 180,
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    }
                ),
              ),
              // Play Button Overlay
              if (videoUrl != null && videoUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (videoUrl.isNotEmpty) { // Double check not empty
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
              // Favorite Toggle Button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(originalIndex), // Use original index
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
                // Apply Expanded fix here too for consistency if needed, though less likely to overflow
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded( // Apply fix here too
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
                    Expanded( // Apply fix here too
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
    // Use null-aware operator and provide a default name
    // Ensure _userData is accessed safely, especially during loading
    String userName = _isLoadingUserData ? 'User' : (_userData['firstName'] as String? ?? 'User');

    // Determine the main content based on the selected navigation index
    Widget mainContent;
    if (_isLoadingUserData) {
      // Show loading indicator centered on the screen
      mainContent = const Center(
        child: CircularProgressIndicator(color: Color(0xFF8E7AFE)),
      );
    } else if (_currentNavIndex == 0) { // Home Tab
      mainContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Give slight bounce effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Adjust padding
              child: Row(
                children: [
                  Expanded( // Allow text column to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName",
                          style: const TextStyle(
                            color: Color(0xFF8E7AFE), // Accent color
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Space between lines
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
                  // Keep icons on the right
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement Search functionality
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
                      // TODO: Implement Notifications functionality
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // Ensure filtered categories are used
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
                      _navigateToFeature('VideosPage'); // Navigate to see all videos
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Keep row tight
                      children: const [
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Color(0xFF8E7AFE), // Accent color
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4), // Space before icon
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
              height: 200, // Fixed height for horizontal list
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _workouts.length,
                itemBuilder: (context, index) =>
                    _buildWorkoutCard(_workouts[index], index),
              ),
            ),
            const SizedBox(height: 24),

            // --- Promotional Banner ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E7AFE).withOpacity(0.2), // Semi-transparent accent
                  borderRadius: BorderRadius.circular(15),
                  // Optional: Add gradient or border if desired
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
                                color: Colors.yellow, // Highlight color
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Explore Plans with Pro Tips!",
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
                        'assets/workout1.jpg', // Use a relevant banner image asset
                        width: 150, // Adjust width as needed
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading banner image: $error");
                          return Container(
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
            const SizedBox(height: 24),


            // **** START: Conditional Rating Section ****
            // Check if the user role is 'Trainee' (Case sensitive - adjust if needed)
            // Ensure _userData['role'] is fetched and not null before checking
            if (_userData.containsKey('role') && _userData['role'] == 'Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRatingSection(), // Display the rating section
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
            SizedBox(
              height: 180, // Adjust height if needed
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _healthAndFitItems.length,
                itemBuilder: (context, index) =>
                    _buildHealthAndFitCard(_healthAndFitItems[index]),
              ),
            ),
            const SizedBox(height: 24),

            // --- Conditional Trainer Button ---
            // Ensure _userData['role'] exists before checking
            // Use lowercase 'trainee' as per original logic check? Verify role casing in Firestore.
            if (_userData.containsKey('role') &&
                _userData['role'] != 'Trainee' && // Adjust casing if needed
                _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted padding
                child: GestureDetector(
                  onTap: _navigateToTrainees,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF8E7AFE).withOpacity(0.2), // Use consistent styling
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
            const SizedBox(height: 16), // Bottom padding before nav bar
          ],
        ),
      );
    } else if (_currentNavIndex == 1) { // Favorites Tab
      mainContent = _buildFavoritesView();
    } else if (_currentNavIndex == 2) { // AI Coach Tab
      // Assuming ChatPage is a full screen/widget itself
      mainContent = const ChatPage();
    } else { // Should not happen with current nav bar setup, but good fallback
      mainContent = const Center(
        child: Text("Invalid Tab", style: TextStyle(color: Colors.white)),
      );
    }

    // --- Scaffold Structure ---
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Main background color
      body: SafeArea( // Ensure content avoids notches/status bars
        child: mainContent, // Display the determined content
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (!mounted) return; // Check context validity
          if (index == 3) { // Profile Tab
            _navigateToProfile();
            // Keep the current index visually selected until profile page pops
          } else {
            // For Home (0), Favorites (1), AI Coach (2)
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
        backgroundColor: const Color(0xFF232323), // Match background
        selectedItemColor: const Color(0xFF8E7AFE), // Accent color for selected
        unselectedItemColor: Colors.grey, // Color for unselected items
        type: BottomNavigationBarType.fixed, // Keep items fixed width
        showUnselectedLabels: true, // Optionally show labels for unselected items
        selectedFontSize: 12, // Standard sizes
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Use outlined icons
            activeIcon: Icon(Icons.home), // Use filled icon when active
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined), // Use outlined icons
            activeIcon: Icon(Icons.star), // Use filled icon when active
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), // Use outlined icons
            activeIcon: Icon(Icons.chat_bubble), // Use filled icon when active
            label: 'AI Coach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Use outlined icons
            activeIcon: Icon(Icons.person), // Use filled icon when active
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


// Helper class for displaying all videos (remains mostly unchanged)
// Added error handling for image loading and context checks for launchUrl
class AllVideosPage extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  const AllVideosPage({Key? key, required this.videos}) : super(key: key);

  Future<void> _launchVideo(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Check context validity before showing SnackBar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $url")),
          );
        }
        print("Could not launch $url");
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


  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> video) {
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
          if (context.mounted) { // Check mounted before showing SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No video available for this item.")),
            );
          }
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
                      print("Error loading video image '$imageUrl': $error");
                      return Container(
                        height: 180, color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                // Play Button Overlay only if videoUrl exists
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
                  // Apply Expanded fix here as well for consistency
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded( // Apply fix
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
                      Expanded( // Apply fix
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
      backgroundColor: const Color(0xFF232323), // Match theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323), // Match theme
        title: const Text(
          "All Workouts",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
        elevation: 0, // No shadow
      ),
      body: videos.isEmpty
          ? const Center(child: Text("No workouts available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) => _buildVideoCard(context, videos[index]),
      ),
    );
  }
}

