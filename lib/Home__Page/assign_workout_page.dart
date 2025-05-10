import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

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

  // New fields
  String _trainer = '';
  String _sets = '';
  String _reps = '';
  String _duration = '';
  DateTime? _date;
  String _selectedSessionType = 'Individual';
  String _selectedWorkoutPlan = 'PPL (Push, Pull, Legs)'; // Default value

  final TextEditingController _dateController = TextEditingController();

  // Options from the provided image for Workout Plan
  final List<String> _workoutPlans = [
    'PPL (Push, Pull, Legs)',
    'Split (Chest, Back, Shoulders, Arms, Legs)',
    'Upper/Lower Split',
    'Full Body Workout',
    'Bro Split (1 Muscle/Day)',
    'PHUL (Power Hypertrophy Upper Lower)',
    'PHAT (Power Hypertrophy Adaptive Training)',
    'GVT (German Volume Training)',
    'FST-7 (Fascial Stretch Training)'
  ];

  // Session type options
  final List<String> _sessionTypes = ['Individual', 'Group'];

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
    } else {
      // Set default workout plan if not editing
      if (_workoutPlans.isNotEmpty) {
        _selectedWorkoutPlan = _workoutPlans[0];
      }
      // Set default session type if not editing
      if (_sessionTypes.isNotEmpty) {
        _selectedSessionType = _sessionTypes[0];
      }
    }
  }

  void _loadExistingWorkout() {
    final workout = widget.existingWorkout!;
    _title = workout['title'] ?? '';
    _description = workout['description'] ?? '';
    _videoUrl = workout['videoUrl'] ?? '';
    _selectedMuscleGroup = workout['muscleGroup'] ?? 'Chest';
    _selectedWeek = workout['week'] ?? 1;

    // Load new fields
    _trainer = workout['trainer'] ?? '';
    _sets = workout['sets'] ?? '';
    _reps = workout['reps'] ?? '';
    _duration = workout['duration'] ?? '';
    if (workout['date'] != null && workout['date'] is Timestamp) {
      _date = (workout['date'] as Timestamp).toDate();
      _dateController.text = DateFormat('yyyy-MM-dd').format(_date!);
    }
    _selectedSessionType = workout['sessionType'] ?? _sessionTypes[0];
    _selectedWorkoutPlan = workout['workoutPlan'] ?? _workoutPlans[0];
  }

  bool _isValidYoutubeUrl(String url) {
    if (url.isEmpty) return true; // Allow empty URL if not required
    return url.contains('youtube.com/watch') ||
        url.contains('youtu.be/') ||
        url.contains('youtube.com/shorts');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_date!);
      });
    }
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

      Map<String, dynamic> workoutData = {
        'title': _title,
        'description': _description,
        'videoUrl': _videoUrl,
        'muscleGroup': _selectedMuscleGroup,
        'week': _selectedWeek,
        // Add new fields to data
        'trainer': _trainer,
        'sets': _sets,
        'reps': _reps,
        'duration': _duration,
        'date': _date != null ? Timestamp.fromDate(_date!) : null,
        'sessionType': _selectedSessionType,
        'workoutPlan': _selectedWorkoutPlan,
      };

      try {
        if (widget.isEditing && widget.existingWorkout != null) {
          // Update existing workout
          workoutData['updatedAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.traineeId)
              .collection('assigned_exercises')
              .doc(widget.existingWorkout!['id'])
              .update(workoutData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout updated successfully!')),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Create new workout
          workoutData['assignedAt'] = FieldValue.serverTimestamp();
          workoutData['completed'] = false; // Default completion status
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.traineeId)
              .collection('assigned_exercises')
              .add(workoutData);
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
    // For example, launch the URL if it's valid
    if (_videoUrl.isNotEmpty && _isValidYoutubeUrl(_videoUrl)) {
      // Implement video preview logic, e.g., using url_launcher
      // For now, just a placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Previewing: $_videoUrl')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or empty video URL for preview.')),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
              // Workout Plan Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Workout Plan'),
                dropdownColor: const Color(0xFF2A2A2A),
                value: _selectedWorkoutPlan,
                items: _workoutPlans.map((String plan) {
                  return DropdownMenuItem<String>(
                    value: plan,
                    child: Text(plan, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWorkoutPlan = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Please select a workout plan' : null,
              ),
              const SizedBox(height: 16),

              // Trainer TextFormField
              TextFormField(
                decoration: _inputDecoration('Trainer'),
                style: const TextStyle(color: Colors.white),
                initialValue: _trainer,
                onSaved: (val) => _trainer = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Please enter trainer name' : null,
              ),
              const SizedBox(height: 16),

              // Sets TextFormField
              TextFormField(
                decoration: _inputDecoration('Sets'),
                style: const TextStyle(color: Colors.white),
                initialValue: _sets,
                keyboardType: TextInputType.number,
                onSaved: (val) => _sets = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter sets';
                  if (int.tryParse(val) == null) return 'Please enter a valid number for sets';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reps TextFormField
              TextFormField(
                decoration: _inputDecoration('Reps'),
                style: const TextStyle(color: Colors.white),
                initialValue: _reps,
                keyboardType: TextInputType.number,
                onSaved: (val) => _reps = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter reps';
                  if (int.tryParse(val) == null) return 'Please enter a valid number for reps';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration TextFormField
              TextFormField(
                decoration: _inputDecoration('Duration (e.g., 30 mins, 1 hour)'),
                style: const TextStyle(color: Colors.white),
                initialValue: _duration,
                onSaved: (val) => _duration = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Please enter duration' : null,
              ),
              const SizedBox(height: 16),

              // Date TextFormField with DatePicker
              TextFormField(
                controller: _dateController,
                decoration: _inputDecoration('Date (YYYY-MM-DD)', suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF8E7AFE))),
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (val) => _date == null ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),

              // Session Type Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Session Type'),
                dropdownColor: const Color(0xFF2A2A2A),
                value: _selectedSessionType,
                items: _sessionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSessionType = newValue;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Please select a session type' : null,
              ),
              const SizedBox(height: 16),

              // Existing fields
              TextFormField(
                decoration: _inputDecoration('Exercise Title'),
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
                validator: (value) => value == null || value.isEmpty ? 'Please select a muscle group' : null,
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
                validator: (value) => value == null ? 'Please select a week' : null,
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
                onChanged: (val) => setState(() => _videoUrl = val), // Keep onChanged for immediate preview button enable/disable
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
