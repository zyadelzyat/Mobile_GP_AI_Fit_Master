import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignedExercisesPage extends StatefulWidget {
  const AssignedExercisesPage({Key? key}) : super(key: key);

  @override
  State<AssignedExercisesPage> createState() => _AssignedExercisesPageState();
}

class _AssignedExercisesPageState extends State<AssignedExercisesPage> {
  bool _isRefreshing = false;

  Future<List<Map<String, dynamic>>> _fetchAssignedExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('assigned_exercises')
        .orderBy('week', descending: false)
        .orderBy('muscleGroup', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
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

  Future<void> _toggleCompletionStatus(String exerciseId, bool currentStatus) async {
    setState(() {
      _isRefreshing = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assigned_exercises')
          .doc(exerciseId)
          .update({
        'completed': !currentStatus,
        'completedAt': !currentStatus ? FieldValue.serverTimestamp() : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentStatus
              ? 'Workout marked as completed!'
              : 'Workout marked as incomplete'),
          backgroundColor: !currentStatus ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshExercises() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Workout Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8E7AFE),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshExercises,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: RefreshIndicator(
        onRefresh: _refreshExercises,
        color: const Color(0xFF8E7AFE),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchAssignedExercises(),
          builder: (context, snapshot) {
            if (_isRefreshing || snapshot.connectionState == ConnectionState.waiting) {
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
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E7AFE),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Home'),
                    ),
                  ],
                ),
              );
            }

            final exercises = snapshot.data!;
            // Group exercises by week
            Map<int, List<Map<String, dynamic>>> exercisesByWeek = {};
            for (var exercise in exercises) {
              int week = exercise['week'] ?? 1;
              if (!exercisesByWeek.containsKey(week)) {
                exercisesByWeek[week] = [];
              }
              exercisesByWeek[week]!.add(exercise);
            }

            // Sort weeks
            List<int> weeks = exercisesByWeek.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: weeks.length,
              itemBuilder: (context, weekIndex) {
                int week = weeks[weekIndex];
                List<Map<String, dynamic>> weekExercises = exercisesByWeek[week]!;

                // Group by muscle group within each week
                Map<String, List<Map<String, dynamic>>> byMuscleGroup = {};
                for (var exercise in weekExercises) {
                  String muscleGroup = exercise['muscleGroup'] ?? 'Other';
                  if (!byMuscleGroup.containsKey(muscleGroup)) {
                    byMuscleGroup[muscleGroup] = [];
                  }
                  byMuscleGroup[muscleGroup]!.add(exercise);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 16, top: weekIndex > 0 ? 24 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E7AFE),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Week $week',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ...byMuscleGroup.entries.map((entry) {
                      String muscleGroup = entry.key;
                      List<Map<String, dynamic>> muscleExercises = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _getMuscleGroupIcon(muscleGroup),
                                  color: const Color(0xFFE2F163),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  muscleGroup,
                                  style: const TextStyle(
                                    color: Color(0xFFE2F163),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ...muscleExercises.map((exercise) {
                            final bool isCompleted = exercise['completed'] == true;
                            final String title = exercise['title'] ?? 'Exercise';
                            final String description = exercise['description'] ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: const Color(0xFF2A2A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _toggleCompletionStatus(exercise['id'], isCompleted),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isCompleted
                                                      ? Icons.check_circle
                                                      : Icons.check_circle_outline,
                                                  color: isCompleted
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isCompleted ? 'Done' : 'Mark Done',
                                                  style: TextStyle(
                                                    color: isCompleted
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (description.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.grey,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatTimestamp(exercise['assignedAt']),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _launchVideo(context, exercise['videoUrl']),
                                          icon: const Icon(Icons.play_circle_outline, size: 16),
                                          label: const Text('Watch Video'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8E7AFE),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            textStyle: const TextStyle(fontSize: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new;
      case 'back':
        return Icons.fitness_center;
      case 'shoulders':
        return Icons.accessibility;
      case 'arms':
        return Icons.sports_gymnastics;
      case 'legs':
        return Icons.directions_run;
      case 'core':
        return Icons.airline_seat_flat;
      case 'full body':
        return Icons.person;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }

    return 'Recently';
  }
}
