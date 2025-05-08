import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignWorkoutPage extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const AssignWorkoutPage({
    required this.traineeId,
    required this.traineeName,
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
  String _duration = '';
  String _calories = '';
  bool _isLoading = false;

  bool _isValidYoutubeUrl(String url) {
    if (url.isEmpty) return true; // Allow empty URL if not required
    // Basic check for YouTube URLs (can be made more robust)
    return url.contains('youtube.com/watch') ||
        url.contains('youtu.be/') ||
        url.contains('youtube.com/shorts');
  }

  Future<void> _assignWorkout() async {
    // **FIX APPLIED HERE**
    if (widget.traineeId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot assign workout: Trainee ID is invalid.')),
        );
      }
      return; // Stop execution if traineeId is empty
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.traineeId) // This line was causing the error if traineeId was empty
            .collection('assigned_exercises')
            .add({
          'title': _title,
          'description': _description,
          'videoUrl': _videoUrl,
          'duration': _duration,
          'calories': _calories,
          'assignedAt': FieldValue.serverTimestamp(),
          'completed': false, // Default to not completed
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout assigned successfully!')),
          );
          Navigator.pop(context, true); // Pop and indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error assigning workout: ${e.toString()}')),
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
    if (_videoUrl.isNotEmpty) {
      final Uri uri = Uri.parse(_videoUrl);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open video URL. Ensure YouTube app is installed or URL is correct.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error launching URL: ${e.toString()}')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video URL is empty.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      appBar: AppBar(
        title: Text('Assign to ${widget.traineeName}'),
        backgroundColor: const Color(0xFF8E7AFE), // Accent color
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
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Description (Optional)'),
                style: const TextStyle(color: Colors.white),
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
                onChanged: (val) => setState(() => _videoUrl = val), // Update _videoUrl for preview button enable/disable
                onSaved: (val) => _videoUrl = val ?? '',
                validator: (val) {
                  if (val != null &&
                      val.isNotEmpty &&
                      !_isValidYoutubeUrl(val)) {
                    return 'Please enter a valid YouTube URL (e.g., youtube.com/watch?v=..., youtu.be/..., youtube.com/shorts/...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDecoration('Duration (e.g., 12 Mins)'),
                      style: const TextStyle(color: Colors.white),
                      onSaved: (val) => _duration = val ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDecoration('Calories (e.g., 120 Kcal)'),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _calories = val ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _assignWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E7AFE), // Accent color
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
                    : const Text('Assign Workout', style: TextStyle(fontSize: 16)),
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
        borderSide: BorderSide(color: Color(0xFF8E7AFE)), // Accent color
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
