import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assign_workout_page.dart';
import 'trainee_workouts_page.dart';
import 'package:untitled/meal/view_meal_plans_page.dart';

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
      data['uid'] = data['uid'] ?? doc.id;
      return data;
    }).toList();
  }

  void _showTraineeOptions(BuildContext context, Map<String, dynamic> trainee) {
    final String traineeId = trainee['uid'] as String? ?? '';
    final String name = "${trainee['firstName'] ?? ''} ${trainee['lastName'] ?? ''}".trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Options for ${name.isEmpty ? "Unnamed Trainee" : name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                context,
                icon: Icons.fitness_center,
                title: 'Add Workout',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignWorkoutPage(
                        traineeId: traineeId,
                        traineeName: name.isEmpty ? "Unnamed Trainee" : name,
                      ),
                    ),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.list,
                title: 'Manage Workouts',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TraineeWorkoutsPage(
                        traineeId: traineeId,
                        traineeName: name.isEmpty ? "Unnamed Trainee" : name,
                      ),
                    ),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.restaurant_menu,
                title: 'Meal Plans',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMealPlansPage(
                        traineeId: traineeId,
                        traineeName: name.isEmpty ? "Unnamed Trainee" : name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8E7AFE)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'My Trainees',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8E7AFE),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search trainees...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTrainees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8E7AFE),
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
                            color: Color(0xFF8E7AFE),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No trainees assigned yet.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
                        elevation: 0,
                        color: const Color(0xFF2A2A2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _showTraineeOptions(context, trainee),
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
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        trainee['email'] ?? 'No email',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.more_vert,
                                  color: Color(0xFF8E7AFE),
                                ),
                              ],
                            ),
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
    );
  }
}
