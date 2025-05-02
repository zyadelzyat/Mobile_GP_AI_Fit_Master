import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AddRatingPage extends StatefulWidget {
  const AddRatingPage({super.key});

  @override
  _AddRatingPageState createState() => _AddRatingPageState();
}

class _AddRatingPageState extends State<AddRatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _rating = 0; // To store the selected rating
  final TextEditingController _commentController = TextEditingController();

  // State variables for fetching trainers
  bool _isLoadingTrainers = true;
  List<Map<String, dynamic>> _trainers = []; // List to hold trainer data {id, name}
  String? _selectedTrainerId; // To store the selected trainer's Firestore document ID

  @override
  void initState() {
    super.initState();
    _fetchTrainers(); // Fetch trainers when the page loads
    _rating = 0; // Start with 0 rating
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Function to fetch users with the role 'Trainer'
  Future<void> _fetchTrainers() async {
    if (!mounted) return; // Ensure widget is still mounted
    setState(() {
      _isLoadingTrainers = true;
      _trainers = []; // Clear previous list
      _selectedTrainerId = null; // Reset selection
    });

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Trainer') // Filter by role
          .orderBy('firstName') // Optional: order by name
          .get();

      List<Map<String, dynamic>> fetchedTrainers = [];
      for (var doc in querySnapshot.docs) {
        // Check if data exists and is a map
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Construct full name safely
          String firstName = data['firstName'] as String? ?? 'N/A';
          String lastName = data['lastName'] as String? ?? '';
          String fullName = '$firstName $lastName'.trim();

          fetchedTrainers.add({
            'id': doc.id, // Store the document ID (trainer's UID)
            'name': fullName, // Store the display name
          });
        }
      }

      if (mounted) { // Check again before setting state
        setState(() {
          _trainers = fetchedTrainers;
          _isLoadingTrainers = false;
          // Optionally pre-select the first trainer if list is not empty
          // if (_trainers.isNotEmpty) {
          //   _selectedTrainerId = _trainers[0]['id'];
          // }
        });
      }

    } catch (e) {
      print("Error fetching trainers: $e");
      if (mounted) {
        setState(() {
          _isLoadingTrainers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching trainers: ${e.toString()}')),
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

    if (_selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a coach.')),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating (1-5 stars).')),
      );
      return;
    }

    // Show loading indicator while saving
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare the data to be saved[6][8]
      final ratingData = {
        'traineeId': currentUser.uid, // ID of the user giving the rating
        'trainerId': _selectedTrainerId, // ID of the trainer being rated
        'rating': _rating, // The star rating value
        'comment': _commentController.text.trim(), // The comment text
        'timestamp': FieldValue.serverTimestamp(), // Server timestamp for ordering
        // Optional: Add trainee name/info if needed for display later
        'traineeFirstName': currentUser.displayName?.split(' ').first ?? '',
        'traineeProfilePicUrl': currentUser.photoURL ?? ''
      };

      // Add the data to the 'ratings' collection[6][8][5]
      await _firestore.collection('ratings').add(ratingData);

      Navigator.pop(context); // Close the loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
      Navigator.pop(context); // Go back to the previous page (Home Page)

    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323), // Match home page background
      appBar: AppBar(
        title: const Text('Add Rating', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF232323),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView( // Allows scrolling if content overflows
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coach Selector Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFF8E7AFE))
              ),
              child: _isLoadingTrainers
                  ? const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )) // Show loader while fetching
                  : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrainerId,
                  hint: const Text(
                      "--Choose your coach--",
                      style: TextStyle(color: Colors.grey)
                  ),
                  dropdownColor: const Color(0xFF2A2A2A), // Dark dropdown background
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8E7AFE)),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (String? newValue) {
                    if (mounted) { // Check context validity
                      setState(() {
                        _selectedTrainerId = newValue;
                      });
                    }
                  },
                  items: _trainers.map<DropdownMenuItem<String>>((trainer) {
                    return DropdownMenuItem<String>(
                      value: trainer['id'], // Use Firestore document ID as the value
                      child: Text(trainer['name']), // Display the trainer's name
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                _isLoadingTrainers ? "Loading coaches..." : "Available coaches: ${_trainers.length}",
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
                  Center( // Center the rating bar
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1, // Minimum rating is 1 star
                      direction: Axis.horizontal,
                      allowHalfRating: false, // Can set to true if needed
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        if (mounted) { // Check context validity
                          setState(() {
                            _rating = rating;
                          });
                        }
                      },
                      unratedColor: Colors.grey[800], // Color for empty stars
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "(${_rating.toInt()}/5)", // Display current rating number
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
                  fontWeight: FontWeight.bold),
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
              onPressed: _submitRating, // Call the function to save to Firestore
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3FC6F), // Yellowish button color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Color(0xFF232323), // Dark text color
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}
