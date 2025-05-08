import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assign_workout_page.dart';

class TrainerTraineesPage extends StatelessWidget {
  const TrainerTraineesPage({super.key});

  Future<List<Map<String, dynamic>>> fetchTrainees() async {
    User? trainer = FirebaseAuth.instance.currentUser;
    if (trainer == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('coachId', isEqualTo: trainer.uid)
        .where('role', isEqualTo: 'Trainee')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      // Ensure 'uid' is included if it's not already the document ID
      // If 'uid' is a field within the document, this is fine.
      // If 'uid' is supposed to be the document ID, it should be doc.id
      // For this example, we assume 'uid' is a field in the document.
      // If not, you might need to adjust how 'uid' is retrieved or passed.
      data['uid'] = data['uid'] ?? doc.id; // Ensure uid is present, fallback to doc.id if necessary
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // Light gray background
      appBar: AppBar(
        title: const Text(
          'My Trainees',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black title text
          ),
        ),
        backgroundColor: Colors.white, // White app bar
        elevation: 0, // No shadow
        iconTheme: const IconThemeData(color: Colors.black), // Black back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search trainees...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              // Add onChanged or onSubmitted for search functionality if needed
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTrainees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8E7AFE), // Accent color
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final trainees = snapshot.data ?? [];

                if (trainees.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Color(0xFF8E7AFE), // Accent color
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No trainees assigned yet.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: trainees.length,
                    itemBuilder: (context, index) {
                      final trainee = trainees[index];
                      final name =
                      "${trainee['firstName'] ?? ''} ${trainee['lastName'] ?? ''}"
                          .trim();
                      final String traineeIdValue = trainee['uid'] as String? ?? '';


                      String initials = '';
                      if (trainee['firstName'] != null &&
                          (trainee['firstName'] as String).isNotEmpty) {
                        initials += (trainee['firstName'] as String)[0];
                      }
                      if (trainee['lastName'] != null &&
                          (trainee['lastName'] as String).isNotEmpty) {
                        initials += (trainee['lastName'] as String)[0];
                      }
                      initials = initials.toUpperCase();
                      if (initials.isEmpty) initials = "NA";


                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0, // Subtle shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF8E7AFE),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty ? "Unnamed Trainee" : name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      trainee['email'] ?? 'No email',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (trainee['disease'] != null && trainee['disease'].toString().isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFECFF), // Light purple
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              trainee['disease'] ?? '',
                                              style: const TextStyle(
                                                color: Color(0xFF8E7AFE), // Accent color
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        if (trainee['phone'] != null && trainee['phone'].toString().isNotEmpty)
                                          Row(
                                            children: [
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.phone,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                trainee['phone'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF8E7AFE), // Accent color
                                ),
                                onPressed: () {
                                  // **FIX APPLIED HERE**
                                  if (traineeIdValue.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AssignWorkoutPage(
                                          traineeId: traineeIdValue,
                                          traineeName: name.isEmpty ? "Unnamed Trainee" : name,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Optionally, show an error message to the trainer
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Error: Trainee ID is missing. Cannot assign workout.')),
                                    );
                                    print('Error: Attempted to navigate to AssignWorkoutPage with an invalid traineeId.');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8E7AFE), // Accent color
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Placeholder for "Add new trainee" functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new trainee functionality not implemented yet.')),
          );
        },
      ),
    );
  }
}
