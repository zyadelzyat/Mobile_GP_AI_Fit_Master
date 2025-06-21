import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TraineeRatingPage extends StatefulWidget {
  const TraineeRatingPage({Key? key}) : super(key: key);

  @override
  _TraineeRatingPageState createState() => _TraineeRatingPageState();
}

class _TraineeRatingPageState extends State<TraineeRatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _ratingData;
  Map<String, dynamic>? _trainerData;

  @override
  void initState() {
    super.initState();
    _fetchRating();
  }

  Future _fetchRating() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Query the main ratings collection instead of trainee_ratings subcollection
      final QuerySnapshot ratingSnapshot = await _firestore
          .collection('ratings') // Use main ratings collection
          .where('traineeId', isEqualTo: currentUser.uid) // Current user is the trainee
          .where('ratingType', isEqualTo: 'trainer_to_trainee') // Trainer rating trainee
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (ratingSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Get the rating data
      final ratingDoc = ratingSnapshot.docs.first;
      final ratingData = ratingDoc.data() as Map<String, dynamic>;

      // Get trainer details using trainerId
      if (ratingData.containsKey('trainerId')) {
        final String trainerId = ratingData['trainerId'];
        final DocumentSnapshot trainerDoc = await _firestore
            .collection('users')
            .doc(trainerId)
            .get();

        if (trainerDoc.exists) {
          final trainerData = trainerDoc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _ratingData = ratingData;
              _trainerData = trainerData;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching rating: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rating: ${e.toString()}')),
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
          "My Rate",
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
          : _ratingData == null
          ? _buildNoRatingView()
          : _buildRatingView(),
    );
  }

  Widget _buildNoRatingView() {
    return Center(
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
              "No Rating Yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your coach hasn't rated you yet.",
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

  Widget _buildRatingView() {
    final double rating = (_ratingData?['rating'] ?? 0.0).toDouble();
    final String comment = _ratingData?['comment'] ?? '';

    // Format trainer name
    String trainerName = 'Your coach';
    if (_trainerData != null) {
      final String firstName = _trainerData?['firstName'] ?? '';
      final String lastName = _trainerData?['lastName'] ?? '';
      trainerName = 'Coach $firstName';
    }

    // Get trainer profile image if available
    String? profileImageUrl = _trainerData?['profileImageUrl'];

    return Column(
      children: [
        // Trainer info section
        Container(
          width: double.infinity,
          color: const Color(0xFFB29BFF),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage('assets/profile.png') as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Text(
                trainerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Rating display
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                    rating: rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 36.0,
                    unratedColor: Colors.grey.withOpacity(0.3),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "(${rating.toInt()}/5)",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Your coach rates you ${rating.toInt()} stars",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Comment section
        if (comment.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Text(
                comment,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

        // OK button
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC3FC6F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "ok",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
