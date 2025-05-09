import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'assign_workout_page.dart';

class TraineeWorkoutsPage extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const TraineeWorkoutsPage({
    required this.traineeId,
    required this.traineeName,
    Key? key,
  }) : super(key: key);

  @override
  State<TraineeWorkoutsPage> createState() => _TraineeWorkoutsPageState();
}

class _TraineeWorkoutsPageState extends State<TraineeWorkoutsPage> {
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _fetchAssignedWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.traineeId)
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

  Future<void> _launchVideo(String? videoUrl) async {
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

  Future<void> _deleteWorkout(String workoutId) async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.traineeId)
          .collection('assigned_exercises')
          .doc(workoutId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting workout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation(String workoutId, String workoutTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Delete Workout', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$workoutTitle"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E7AFE))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkout(workoutId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editWorkout(Map<String, dynamic> workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignWorkoutPage(
          traineeId: widget.traineeId,
          traineeName: widget.traineeName,
          isEditing: true,
          existingWorkout: workout,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(
          '${widget.traineeName}\'s Workouts',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8E7AFE),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignWorkoutPage(
                    traineeId: widget.traineeId,
                    traineeName: widget.traineeName,
                  ),
                ),
              );

              if (result == true) {
                setState(() {});
              }
            },
            tooltip: 'Assign New Workout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E7AFE)))
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAssignedWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8E7AFE)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final workouts = snapshot.data ?? [];

          if (workouts.isEmpty) {
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
                    'No workouts assigned yet',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignWorkoutPage(
                            traineeId: widget.traineeId,
                            traineeName: widget.traineeName,
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E7AFE),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Assign Workout'),
                  ),
                ],
              ),
            );
          }

          // Group workouts by week
          Map<int, List<Map<String, dynamic>>> workoutsByWeek = {};
          for (var workout in workouts) {
            int week = workout['week'] ?? 1;
            if (!workoutsByWeek.containsKey(week)) {
              workoutsByWeek[week] = [];
            }
            workoutsByWeek[week]!.add(workout);
          }

          // Sort weeks
          List<int> weeks = workoutsByWeek.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weeks.length,
            itemBuilder: (context, weekIndex) {
              int week = weeks[weekIndex];
              List<Map<String, dynamic>> weekWorkouts = workoutsByWeek[week]!;

              // Group by muscle group within each week
              Map<String, List<Map<String, dynamic>>> byMuscleGroup = {};
              for (var workout in weekWorkouts) {
                String muscleGroup = workout['muscleGroup'] ?? 'Other';
                if (!byMuscleGroup.containsKey(muscleGroup)) {
                  byMuscleGroup[muscleGroup] = [];
                }
                byMuscleGroup[muscleGroup]!.add(workout);
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
                        ...muscleExercises.map((workout) {
                          final bool isCompleted = workout['completed'] == true;
                          final String title = workout['title'] ?? 'Exercise';
                          final String description = workout['description'] ?? '';

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
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.white70),
                                        color: const Color(0xFF3A3A3A),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editWorkout(workout);
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(workout['id'], title);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, color: Color(0xFF8E7AFE), size: 20),
                                                SizedBox(width: 8),
                                                Text('Edit', style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
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
                                            _formatTimestamp(workout['assignedAt']),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (workout['videoUrl'] != null && workout['videoUrl'].toString().isNotEmpty)
                                        ElevatedButton.icon(
                                          onPressed: () => _launchVideo(workout['videoUrl']),
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
