import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignWorkoutPage extends StatefulWidget {
  final String traineeId;
  final String traineeName;
  final bool isEditing;
  final Map<String, dynamic>? existingWorkout;

  const AssignWorkoutPage({
    required this.traineeId,
    required this.traineeName,
    this.isEditing = false,
    this.existingWorkout,
    Key? key,
  }) : super(key: key);

  @override
  State<AssignWorkoutPage> createState() => _AssignWorkoutPageState();
}

class _AssignWorkoutPageState extends State<AssignWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _videoUrl = '';
  String _selectedMuscleGroup = 'Chest';
  int _selectedWeek = 1;
  bool _isLoading = false;

  // Muscle group options
  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core', 'Full Body'
  ];

  // Week options
  final List<int> _weeks = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingWorkout != null) {
      _loadExistingWorkout();
    }
  }

  void _loadExistingWorkout() {
    final workout = widget.existingWorkout!;
    _title = workout['title'] ?? '';
    _description = workout['description'] ?? '';
    _videoUrl = workout['videoUrl'] ?? '';
    _selectedMuscleGroup = workout['muscleGroup'] ?? 'Chest';
    _selectedWeek = workout['week'] ?? 1;
  }

  bool _isValidYoutubeUrl(String url) {
    if (url.isEmpty) return true; // Allow empty URL if not required
    return url.contains('youtube.com/watch') ||
        url.contains('youtu.be/') ||
        url.contains('youtube.com/shorts');
  }

  Future<void> _saveWorkout() async {
    if (widget.traineeId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot assign workout: Trainee ID is invalid.')),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        if (widget.isEditing && widget.existingWorkout != null) {
          // Update existing workout
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.traineeId)
              .collection('assigned_exercises')
              .doc(widget.existingWorkout!['id'])
              .update({
            'title': _title,
            'description': _description,
            'videoUrl': _videoUrl,
            'muscleGroup': _selectedMuscleGroup,
            'week': _selectedWeek,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout updated successfully!')),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Create new workout
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.traineeId)
              .collection('assigned_exercises')
              .add({
            'title': _title,
            'description': _description,
            'videoUrl': _videoUrl,
            'muscleGroup': _selectedMuscleGroup,
            'week': _selectedWeek,
            'assignedAt': FieldValue.serverTimestamp(),
            'completed': false,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout assigned successfully!')),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving workout: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _previewVideo() async {
    // Your existing code for previewing videos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Workout' : 'Assign to ${widget.traineeName}'),
        backgroundColor: const Color(0xFF8E7AFE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: _inputDecoration('Title'),
                style: const TextStyle(color: Colors.white),
                initialValue: _title,
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Muscle Group Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Muscle Group'),
                dropdownColor: const Color(0xFF2A2A2A),
                value: _selectedMuscleGroup,
                items: _muscleGroups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMuscleGroup = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Week Selection Dropdown
              DropdownButtonFormField<int>(
                decoration: _inputDecoration('Week'),
                dropdownColor: const Color(0xFF2A2A2A),
                value: _selectedWeek,
                items: _weeks.map((int week) {
                  return DropdownMenuItem<int>(
                    value: week,
                    child: Text('Week $week', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWeek = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: _inputDecoration('Description (Optional)'),
                style: const TextStyle(color: Colors.white),
                initialValue: _description,
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: _inputDecoration(
                  'Video URL (YouTube)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.preview, color: Color(0xFF8E7AFE)),
                    onPressed: _videoUrl.isEmpty ? null : _previewVideo,
                    tooltip: "Preview Video",
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                initialValue: _videoUrl,
                onChanged: (val) => setState(() => _videoUrl = val),
                onSaved: (val) => _videoUrl = val ?? '',
                validator: (val) {
                  if (val != null &&
                      val.isNotEmpty &&
                      !_isValidYoutubeUrl(val)) {
                    return 'Please enter a valid YouTube URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E7AFE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                  widget.isEditing ? 'Update Workout' : 'Assign Workout',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF8E7AFE)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      suffixIcon: suffixIcon,
    );
  }
}
