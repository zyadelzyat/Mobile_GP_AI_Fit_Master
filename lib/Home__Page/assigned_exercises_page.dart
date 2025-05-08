import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignedExercisesPage extends StatelessWidget {
  const AssignedExercisesPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchAssignedExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('assigned_exercises')
        .orderBy('assignedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add document ID for reference
      return data;
    }).toList();
  }

  Future<void> _launchVideo(BuildContext context, String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video URL available')),
      );
      return;
    }

    final Uri uri = Uri.parse(videoUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _markAsCompleted(String exerciseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('assigned_exercises')
        .doc(exerciseId)
        .update({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assigned Exercises'),
        backgroundColor: const Color(0xFF8E7AFE),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAssignedExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8E7AFE)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Color(0xFF8E7AFE),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No exercises assigned yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E7AFE),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            );
          }

          final exercises = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              final bool isCompleted = ex['completed'] == true;

              return Card(
                color: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E7AFE).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF8E7AFE),
                          size: 30,
                        ),
                      ),
                      title: Text(
                        ex['title'] ?? 'Exercise',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        '${ex['duration'] ?? '-'} • ${ex['calories'] ?? '-'} Kcal',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCompleted)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                              tooltip: 'Mark as completed',
                              onPressed: () {
                                _markAsCompleted(ex['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Marked as completed!')),
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Color(0xFF8E7AFE)),
                            tooltip: 'Play video',
                            onPressed: () => _launchVideo(context, ex['videoUrl']),
                          ),
                        ],
                      ),
                    ),
                    if (ex['description'] != null && ex['description'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          ex['description'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
