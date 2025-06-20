import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RatingType { traineeToTrainer, trainerToTrainee }

class AddRatingPage extends StatefulWidget {
  final RatingType? ratingType;
  final String? preselectedUserId;

  const AddRatingPage({
    super.key,
    this.ratingType,
    this.preselectedUserId,
  });

  @override
  _AddRatingPageState createState() => _AddRatingPageState();
}

class _AddRatingPageState extends State<AddRatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  // Rating type state
  RatingType _ratingType = RatingType.traineeToTrainer;

  // State variables for fetching users
  bool _isLoadingUsers = true;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _initializeRatingType();
    _getCurrentUserRole();
    _rating = 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _initializeRatingType() {
    if (widget.ratingType != null) {
      _ratingType = widget.ratingType!;
    }
    if (widget.preselectedUserId != null) {
      _selectedUserId = widget.preselectedUserId;
    }
  }

  // Get current user role to determine default rating type
  Future<void> _getCurrentUserRole() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && mounted) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _currentUserRole = userData['role'] as String?;
            // Set rating type based on user role - FIXED LOGIC
            if (_currentUserRole == 'Trainer') {
              _ratingType = RatingType.trainerToTrainee; // Trainer rates Trainee
            } else if (_currentUserRole == 'Trainee') {
              _ratingType = RatingType.traineeToTrainer; // Trainee rates Trainer
            }
          });
          _fetchUsers();
        }
      } catch (e) {
        print("Error fetching user role: $e");
        _fetchUsers(); // Fetch users anyway with default type
      }
    }
  }

  // Function to fetch users based on rating type - FIXED TO EXCLUDE CURRENT USER
  Future<void> _fetchUsers() async {
    if (!mounted) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingUsers = true;
      _users = [];
      // Keep preselected user if exists
      if (widget.preselectedUserId == null) {
        _selectedUserId = null;
      }
    });

    try {
      // Determine target role based on current user role and rating type
      String targetRole;

      if (_currentUserRole == 'Trainer') {
        // Trainer can only rate Trainees
        targetRole = 'Trainee';
        _ratingType = RatingType.trainerToTrainee;
      } else if (_currentUserRole == 'Trainee') {
        // Trainee can only rate Trainers
        targetRole = 'Trainer';
        _ratingType = RatingType.traineeToTrainer;
      } else {
        // Fallback logic
        targetRole = _ratingType == RatingType.traineeToTrainer ? 'Trainer' : 'Trainee';
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: targetRole)
          .orderBy('firstName')
          .get();

      List<Map<String, dynamic>> fetchedUsers = [];
      for (var doc in querySnapshot.docs) {
        // EXCLUDE CURRENT USER FROM THE LIST
        if (doc.id == currentUser.uid) {
          continue; // Skip current user
        }

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String firstName = data['firstName'] as String? ?? 'N/A';
          String lastName = data['lastName'] as String? ?? '';
          String fullName = '$firstName $lastName'.trim();

          fetchedUsers.add({
            'id': doc.id,
            'name': fullName,
          });
        }
      }

      if (mounted) {
        setState(() {
          _users = fetchedUsers;
          _isLoadingUsers = false;
        });
      }

    } catch (e) {
      print("Error fetching users: $e");
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: ${e.toString()}')),
        );
      }
    }
  }

  // Function to submit the rating to Firestore
  Future<void> _submitRating() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a rating.')),
      );
      return;
    }

    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a ${_ratingType == RatingType.traineeToTrainer ? 'coach' : 'trainee'}.')),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating (1-5 stars).')),
      );
      return;
    }

    // VALIDATION: Prevent rating same role
    if (_selectedUserId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot rate yourself!')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare rating data based on rating type
      Map<String, dynamic> ratingData;

      if (_ratingType == RatingType.traineeToTrainer) {
        ratingData = {
          'traineeId': currentUser.uid,
          'trainerId': _selectedUserId,
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'ratingType': 'trainee_to_trainer',
          'raterName': currentUser.displayName?.split(' ').first ?? '',
          'raterProfilePicUrl': currentUser.photoURL ?? ''
        };
      } else {
        ratingData = {
          'trainerId': currentUser.uid,
          'traineeId': _selectedUserId,
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'ratingType': 'trainer_to_trainee',
          'raterName': currentUser.displayName?.split(' ').first ?? '',
          'raterProfilePicUrl': currentUser.photoURL ?? ''
        };
      }

      await _firestore.collection('ratings').add(ratingData);

      Navigator.pop(context); // Close loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
      Navigator.pop(context); // Go back to previous page

    } catch (e) {
      Navigator.pop(context); // Close loading indicator
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: ${e.toString()}')),
      );
    }
  }

  String get _getAppBarTitle {
    return _ratingType == RatingType.traineeToTrainer
        ? 'Rate Coach'
        : 'Rate Trainee';
  }

  String get _getDropdownHint {
    return _ratingType == RatingType.traineeToTrainer
        ? "--Choose your coach--"
        : "--Choose trainee--";
  }

  String get _getUserCountText {
    String userType = _ratingType == RatingType.traineeToTrainer ? 'coaches' : 'trainees';
    return _isLoadingUsers ? "Loading $userType..." : "Available $userType: ${_users.length}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        title: Text(_getAppBarTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF232323),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Selector Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFF8E7AFE)),
              ),
              child: _isLoadingUsers
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUserId,
                  hint: Text(
                    _getDropdownHint,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  dropdownColor: const Color(0xFF2A2A2A),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8E7AFE)),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (String? newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedUserId = newValue;
                      });
                    }
                  },
                  items: _users.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'],
                      child: Text(user['name']),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                _getUserCountText,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 30),

            // Rating Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rating Level",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        if (mounted) {
                          setState(() {
                            _rating = rating;
                          });
                        }
                      },
                      unratedColor: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "(${_rating.toInt()}/5)",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Comments Section
            const Text(
              "Comments ✍️",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Your feedback helps us to improve...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF8E7AFE)),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Submit Button
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2F163),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Color(0xFF232323),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// RATING UTILITY CLASS - الكلاس ده هيحل مشكلة حساب التقييمات
class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // حساب متوسط تقييم المدرب (التقييمات اللي جاتله من المتدربين بس)
  static Future<double> getTrainerAverageRating(String trainerId) async {
    try {
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('trainerId', isEqualTo: trainerId)
          .where('ratingType', isEqualTo: 'trainee_to_trainer') // مهم جداً - المتدربين بيقيموا المدرب
          .get();

      if (ratingsSnapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num).toDouble();
      }

      return totalRating / ratingsSnapshot.docs.length;
    } catch (e) {
      print("Error getting trainer average rating: $e");
      return 0.0;
    }
  }

  // حساب متوسط تقييم المتدرب (التقييمات اللي جاتله من المدربين بس)
  static Future<double> getTraineeAverageRating(String traineeId) async {
    try {
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('traineeId', isEqualTo: traineeId)
          .where('ratingType', isEqualTo: 'trainer_to_trainee') // مهم جداً - المدربين بيقيموا المتدرب
          .get();

      if (ratingsSnapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num).toDouble();
      }

      return totalRating / ratingsSnapshot.docs.length;
    } catch (e) {
      print("Error getting trainee average rating: $e");
      return 0.0;
    }
  }

  // جلب عدد التقييمات لكل مستخدم
  static Future<int> getUserRatingCount(String userId, String userRole) async {
    try {
      QuerySnapshot ratingsSnapshot;

      if (userRole == 'Trainer') {
        ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('trainerId', isEqualTo: userId)
            .where('ratingType', isEqualTo: 'trainee_to_trainer')
            .get();
      } else {
        ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('traineeId', isEqualTo: userId)
            .where('ratingType', isEqualTo: 'trainer_to_trainee')
            .get();
      }

      return ratingsSnapshot.docs.length;
    } catch (e) {
      print("Error getting user rating count: $e");
      return 0;
    }
  }

  // جلب التقييمات الخاصة بمستخدم معين
  static Future<List<Map<String, dynamic>>> getUserRatings(String userId, String userRole) async {
    try {
      QuerySnapshot ratingsSnapshot;

      if (userRole == 'Trainer') {
        // جلب التقييمات اللي جات للمدرب من المتدربين
        ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('trainerId', isEqualTo: userId)
            .where('ratingType', isEqualTo: 'trainee_to_trainer')
            .orderBy('timestamp', descending: true)
            .get();
      } else {
        // جلب التقييمات اللي جات للمتدرب من المدربين
        ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('traineeId', isEqualTo: userId)
            .where('ratingType', isEqualTo: 'trainer_to_trainee')
            .orderBy('timestamp', descending: true)
            .get();
      }

      List<Map<String, dynamic>> ratings = [];
      for (var doc in ratingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        ratings.add(data);
      }

      return ratings;
    } catch (e) {
      print("Error getting user ratings: $e");
      return [];
    }
  }

  // دالة للتحقق من وجود تقييم سابق بين مستخدمين
  static Future<bool> hasUserRatedBefore(String raterId, String ratedUserId, String ratingType) async {
    try {
      QuerySnapshot existingRating;

      if (ratingType == 'trainee_to_trainer') {
        existingRating = await _firestore
            .collection('ratings')
            .where('traineeId', isEqualTo: raterId)
            .where('trainerId', isEqualTo: ratedUserId)
            .where('ratingType', isEqualTo: ratingType)
            .limit(1)
            .get();
      } else {
        existingRating = await _firestore
            .collection('ratings')
            .where('trainerId', isEqualTo: raterId)
            .where('traineeId', isEqualTo: ratedUserId)
            .where('ratingType', isEqualTo: ratingType)
            .limit(1)
            .get();
      }

      return existingRating.docs.isNotEmpty;
    } catch (e) {
      print("Error checking existing rating: $e");
      return false;
    }
  }
}