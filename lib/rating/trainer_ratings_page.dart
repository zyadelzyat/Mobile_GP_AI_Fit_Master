import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TrainerRatingsPage extends StatefulWidget {
  const TrainerRatingsPage({Key? key}) : super(key: key);

  @override
  _TrainerRatingsPageState createState() => _TrainerRatingsPageState();
}

class _TrainerRatingsPageState extends State<TrainerRatingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _ratings = [];
  double _averageRating = 0.0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get all ratings where trainerId matches the current user's ID
      final QuerySnapshot ratingSnapshot = await _firestore
          .collection('ratings')
          .where('trainerId', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Process the ratings
      List<Map<String, dynamic>> ratings = [];
      double totalRatingValue = 0;

      for (var doc in ratingSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Get trainee details
        String traineeName = 'Unknown Trainee';
        String traineePhotoUrl = '';

        try {
          if (data.containsKey('traineeId')) {
            DocumentSnapshot traineeDoc = await _firestore
                .collection('users')
                .doc(data['traineeId'])
                .get();

            if (traineeDoc.exists) {
              Map<String, dynamic> traineeData = traineeDoc.data() as Map<String, dynamic>;
              String firstName = traineeData['firstName'] ?? '';
              String lastName = traineeData['lastName'] ?? '';
              traineeName = '$firstName $lastName'.trim();
              if (traineeName.isEmpty) traineeName = 'Unknown Trainee';
              traineePhotoUrl = traineeData['profileImageUrl'] ?? '';
            } else {
              // If trainee document doesn't exist, try to use data stored in the rating
              if (data.containsKey('traineeFirstName')) {
                traineeName = data['traineeFirstName'];
              }

              if (data.containsKey('traineeProfilePicUrl')) {
                traineePhotoUrl = data['traineeProfilePicUrl'];
              }
            }
          }
        } catch (e) {
          print('Error fetching trainee details: $e');
          // If there's an error, try to use data stored in the rating
          if (data.containsKey('traineeFirstName')) {
            traineeName = data['traineeFirstName'];
          }

          if (data.containsKey('traineeProfilePicUrl')) {
            traineePhotoUrl = data['traineeProfilePicUrl'];
          }
        }

        // Add to ratings list
        ratings.add({
          'id': doc.id,
          'rating': data['rating'] ?? 0.0,
          'comment': data['comment'] ?? '',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
          'traineeName': traineeName,
          'traineePhotoUrl': traineePhotoUrl,
          'traineeId': data['traineeId'] ?? '',
        });

        // Add to total for average calculation
        totalRatingValue += (data['rating'] ?? 0.0);
      }

      // Calculate average
      _totalRatings = ratings.length;
      _averageRating = _totalRatings > 0 ? totalRatingValue / _totalRatings : 0.0;

      if (mounted) {
        setState(() {
          _ratings = ratings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ratings: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29BFF),
        elevation: 0,
        title: const Text(
          "My Ratings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF9D7BFF)),
        ),
      )
          : Column(
        children: [
          // Rating summary section
          Container(
            width: double.infinity,
            color: const Color(0xFFB29BFF),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  '$_totalRatings ${_totalRatings == 1 ? 'Rating' : 'Ratings'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    RatingBarIndicator(
                      rating: _averageRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 24.0,
                      unratedColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ratings list
          Expanded(
            child: _ratings.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                      "No Ratings Yet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You haven't received any ratings from your trainees yet.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              itemCount: _ratings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final rating = _ratings[index];
                return _buildRatingCard(rating);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    // Format timestamp
    String formattedDate = 'Unknown date';
    if (rating['timestamp'] != null) {
      DateTime dateTime = (rating['timestamp'] as Timestamp).toDate();
      formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Trainee photo
                CircleAvatar(
                  radius: 20,
                  backgroundImage: rating['traineePhotoUrl'] != null &&
                      rating['traineePhotoUrl'].isNotEmpty
                      ? NetworkImage(rating['traineePhotoUrl'])
                      : const AssetImage('assets/profile.png') as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                // Trainee name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating['traineeName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating stars
                RatingBarIndicator(
                  rating: rating['rating'].toDouble(),
                  itemBuilder: (context, index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 18.0,
                  unratedColor: Colors.grey[700],
                ),
              ],
            ),
            if (rating['comment'] != null && rating['comment'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating['comment'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
