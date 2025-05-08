// [File: 00_home_page.dart]
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Assuming needed for ThemeProvider if used
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import Rating Bar - Not directly used here but might be in AddRatingPage
import 'package:untitled/AI/chatbot.dart'; // Replace 'untitled' with your project name
import 'package:untitled/Home__Page/profile.dart'; // Replace 'untitled'
// import 'package:untitled/theme_provider.dart'; // Uncomment if needed
// import 'package:untitled/videos_page.dart'; // Replace 'untitled' - This seems to be for "See All" workouts
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
  int _currentNavIndex = 0; // 0: Home, 1: Store, 2: Chat
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> _userData = {}; // Use specific type Map<String, dynamic>
  bool _isLoadingUserData = true; // Start as true


  // Define membership plans (name, price, typeKey for Firestore) - consistent with profile.dart
  final List<Map<String, dynamic>> _membershipPlans = [
    {'name': 'Basic Plan', 'price': 20.0, 'typeKey': 'basic'},
    {'name': 'Standard Plan', 'price': 30.0, 'typeKey': 'standard'},
    {'name': 'Premium Plan', 'price': 50.0, 'typeKey': 'premium'},
  ];


  // Original list of all possible categories
  final List<Map<String, dynamic>> _baseCategories = [
    {
      'iconAsset': 'assets/icons/youtube.png',
      'label': 'Workout',
      'route': null // Default Workout might not navigate, but show content below
    },
    {
      'iconAsset': 'assets/icons/nutrition_icon.png',
      'label': 'Nutrition',
      'route': 'Nutrition'
    },
    {
      'iconAsset': 'assets/icons/products_icon.png',
      'label': 'Products',
      'route': 'SupplementsStore'
    },
    {
      'iconAsset': 'assets/icons/calculating_calories_icon.png',
      'label': 'Calculating Calories',
      'route': 'CalorieCalculator'
    },
  ];

  // Dynamic categories based on user role and membership status
  List<Map<String, dynamic>> get _filteredCategories {
    List<Map<String, dynamic>> categories = List.from(_baseCategories); // Create a modifiable copy

    // --- Role-Based Filtering Logic ---
    if (_userData.containsKey('role')) {
      final String userRole = _userData['role'] as String? ?? '';
      if (userRole == 'Self-Trainee') {
        categories.removeWhere((category) => category['label'] == 'Nutrition');
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
      // Add other role-based conditions if needed for Trainee, Trainer, etc.
    } else {
      // Default view for users with no role or before role is loaded
      categories.removeWhere((category) => category['label'] == 'Nutrition');
    }

    // --- Membership-Based Category ---
    final String membershipStatus = _userData['membershipStatus'] as String? ?? 'none';
    if (membershipStatus != 'active' && _auth.currentUser != null) { // Only show if logged in and not active
      // Add "Join Membership" if not already present to avoid duplicates during rebuilds
      if (!categories.any((cat) => cat['label'] == 'Join Membership')) {
        categories.add({
          'iconAsset': 'assets/icons/membership_icon.png', // Ensure this icon exists
          'label': 'Join Membership',
          'route': 'JoinMembership'
        });
      }
    } else {
      // Remove "Join Membership" if user becomes active or logs out
      categories.removeWhere((category) => category['label'] == 'Join Membership');
    }


    return categories;
  }


  List<Map<String, dynamic>> _workouts = [
    {
      'title': 'Squat Exercise',
      'image': 'assets/workout1.jpg',
      'color': Colors.purple,
      'videoUrl': 'https://youtube.com/shorts/ajWEUdlbMOA?si=2N01glDn192AaGv6',
      'duration': '12 Minutes',
      'calories': '120 Kcal',
      'isFavorite': false,
    },
    {
      'title': 'Full Body Stretching',
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
      }
      // Ensure UI rebuilds after fetching user data to reflect membership status in categories
      if (mounted) {
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
            _userData = Map<String, dynamic>.from(userDoc.data() as Map<String, dynamic>);
          });
        } else {
          print("User document does not exist for UID: ${currentUser.uid}");
          if (mounted) setState(() => _userData = {});
        }
      } else {
        print("No current user logged in.");
        if (mounted) setState(() => _userData = {});
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
        setState(() => _userData = {}); // Set to empty on error
      }
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
        Map<String, dynamic> favoritesData = favoritesDoc.data() as Map<String, dynamic>;
        List<dynamic> favoriteWorkoutsTitlesDynamic = favoritesData['workouts'] ?? [];
        List<String> favoriteWorkoutsTitles = favoriteWorkoutsTitlesDynamic.cast<String>();

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
          SnackBar(content: Text('Error loading favorites: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveFavorites() async {
    if (!mounted) return;
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
      }, SetOptions(merge: true));
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

  void _navigateToFeature(String? routeName) {
    if (routeName == null || !mounted) return;
    switch (routeName) {
      case 'Workout':
        print("Workout category tapped (no specific route assigned)");
        break;
      case 'Nutrition':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NutritionPage()));
        break;
      case 'ChatBot': // This route might be handled by bottom nav too
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
      case 'JoinMembership': // Handle new category
        _showMembershipDialog();
        break;
    // case 'VideosPage':
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => AllVideosPage(videos: _workouts)));
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
        MaterialPageRoute(builder: (context) => ProfilePage(userId: currentUser.uid)),
      ).then((_) => _fetchCurrentUserData()); // Refresh data when returning from profile
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You need to be logged in to view your profile")),
        );
      }
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


  // --- Membership Dialogs (similar to profile.dart) ---
  void _showMembershipDialog() {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join a membership.')),
      );
      // Optionally, navigate to login screen
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedPlanKey;
        Map<String, dynamic>? selectedPlanDetails;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: Text('Select Membership Plan', style: TextStyle(color: Color(0xFFB29BFF))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _membershipPlans.map((plan) {
                  return RadioListTile<String>(
                    title: Text('${plan['name']} - \$${plan['price'].toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                    value: plan['typeKey'],
                    groupValue: selectedPlanKey,
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedPlanKey = value;
                        selectedPlanDetails = plan;
                      });
                    },
                    activeColor: Color(0xFFB29BFF),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFB29BFF)),
                  child: Text('Next', style: TextStyle(color: Colors.white)),
                  onPressed: selectedPlanKey == null ? null : () {
                    Navigator.of(context).pop();
                    _showPaymentMethodDialog(selectedPlanDetails!);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodDialog(Map<String, dynamic> planDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text('Choose Payment Method for ${planDetails['name']}', style: TextStyle(color: Color(0xFFB29BFF))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.money, color: Color(0xFFB29BFF)),
                title: Text('Pay with Cash', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleCashPayment(planDetails);
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: Color(0xFFB29BFF)),
                title: Text('Pay with Visa', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleVisaPayment(planDetails);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Color(0xFFB29BFF))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCashPayment(Map<String, dynamic> planDetails) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return; // Should be checked before calling _showMembershipDialog

    try {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'membershipType': planDetails['typeKey'],
        'membershipPrice': planDetails['price'],
        'membershipPaymentType': 'cash',
        'membershipStatus': 'pending_approval',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash payment request submitted. Admin will review.')),
      );
      _fetchCurrentUserData(); // Refresh user data to update UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process cash payment: $e')),
      );
    }
  }

  void _handleVisaPayment(Map<String, dynamic> planDetails) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Initiating Visa payment for ${planDetails['name']}. Integration with a payment gateway is required here.')),
    );
    print("Visa payment for ${planDetails['typeKey']} selected. Implement payment gateway integration here.");
    // After successful payment via gateway:
    // await _firestore.collection('users').doc(currentUser.uid).update({
    //   'membershipType': planDetails['typeKey'],
    //   'membershipPrice': planDetails['price'],
    //   'membershipPaymentType': 'visa',
    //   'membershipStatus': 'active',
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
    // _fetchCurrentUserData(); // Refresh
  }


  // --- WIDGET BUILDERS ---
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
                return Icon(
                  label == 'Join Membership' ? Icons.card_membership : Icons.category, // Specific icon for membership
                  color: Color(0xFF8E7AFE),
                  size: 30,
                );
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(_workouts.indexWhere((w) => w['title'] == title)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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

  Widget _buildHealthAndFitCard(Map<String, dynamic> item) {
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    String coachName = "Coach Name"; // Fetch from user data or trainee profile
    String coachImageUrl = "assets/coach_placeholder.png"; // Fetch actual image path
    double currentRating = _userData['lastGivenRating'] as double? ?? 4.0; // Example, fetch actual
    String lastComment = _userData['lastRatingComment'] as String? ?? "No recent comments."; // Example

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
              const Text("My Rating", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.edit_note, size: 18, color: Color(0xFF8E7AFE)),
                label: const Text("Add/Edit Rating", style: TextStyle(color: Color(0xFF8E7AFE), fontSize: 14)),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRatingPage()))
                      .then((_) {
                    print("Returned from AddRatingPage, potentially refresh rating data.");
                    // TODO: Re-fetch rating data if necessary
                  });
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Display existing rating and comment
          // This part needs logic to fetch and display actual rating data
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String userName = _isLoadingUserData ? 'User' : (_userData['firstName'] as String? ?? 'User');
    Widget mainContent;

    if (_isLoadingUserData) {
      mainContent = const Center(child: CircularProgressIndicator(color: Color(0xFF8E7AFE)));
    } else if (_currentNavIndex == 0) { // Home Tab Content
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
                  IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {/* ... */}, tooltip: 'Search'),
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {/* ... */}, tooltip: 'Notifications'),
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
                  const Text("Featured Workouts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () { print("See All Workouts tapped"); /* _navigateToFeature('VideosPage'); */ },
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
                            'assets/plank_image.png', // Ensure this asset exists
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
              child: const Text("Health & Fit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            if (_userData.containsKey('role') && _userData['role'] != 'Trainee' && _userData['role'] != 'Self-Trainee') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _navigateToTrainees,
                  icon: const Icon(Icons.group),
                  label: const Text("View My Trainees"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8E7AFE), foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      );
    } else if (_currentNavIndex == 1) { // Store (handled by onTap)
      mainContent = Center(child: Text("Store Tab (handled by navigation)", style: TextStyle(color: Colors.white)));
    } else if (_currentNavIndex == 2) { // Chat
      mainContent = const ChatPage();
    } else {
      mainContent = const Center(child: Text("Invalid Tab Index", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(child: mainContent),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (!mounted) return;
            if (index == 1) { // Store
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplementsStorePage()));
            } else { // Home (0) or Chat (2)
              setState(() { _currentNavIndex = index; });
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Store'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          ],
        ),
      ),
    );
  }
}
