import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int selectedLevel = 0;
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];

  // روابط اليوتيوب لكل تمرين
  final Map<String, String> workoutYoutubeLinks = {
    'Functional Training': 'https://youtu.be/functional_training',
    'Upper Body': 'https://youtu.be/upper_body',
    'Full Body Stretching': 'https://youtu.be/full_body_stretching',
    'Glutes & Abs': 'https://youtu.be/glutes_abs',
  };

  // حالة المفضلة لكل تمرين
  final Map<String, bool> favorites = {
    'Functional Training': false,
    'Upper Body': false,
    'Full Body Stretching': false,
    'Glutes & Abs': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9D4EDD)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(levels.length, (index) {
                        bool isSelected = selectedLevel == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedLevel = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE8FB55) : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              levels[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Training of the day card
                    GestureDetector(
                      onTap: () => _launchYoutubeVideo(workoutYoutubeLinks['Functional Training']!),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D4EDD).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/training.png',
                                width: double.infinity,
                                height: 135,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8FB55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Training Of The Day',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Functional Training',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '45 Minutes',
                                        style: TextStyle(
                                          color: Colors.grey.shade200,
                                          fontSize: 12,
                                          shadows: [const Shadow(blurRadius: 3, color: Colors.black)],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '1430 Kcal',
                                        style: TextStyle(
                                          color: Colors.grey.shade200,
                                          fontSize: 12,
                                          shadows: [const Shadow(blurRadius: 3, color: Colors.black)],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.fitness_center, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '5 Exercises',
                                        style: TextStyle(
                                          color: Colors.grey.shade200,
                                          fontSize: 12,
                                          shadows: [const Shadow(blurRadius: 3, color: Colors.black)],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  favorites['Functional Training'] = !favorites['Functional Training']!;
                                }),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    favorites['Functional Training']! ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Let's Go Beginner Section
                    const Text(
                      "Let's Go Beginner",
                      style: TextStyle(
                        color: Color(0xFFE8FB55),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Explore Different Workout Styles",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Workout Tiles
                    _buildWorkoutTile(
                      title: 'Upper Body',
                      image: 'assets/upper_body.png',
                      duration: '20 Minutes',
                      calories: '1220 Kcal',
                      exercises: '5 Exercises',
                      youtubeUrl: workoutYoutubeLinks['Upper Body']!,
                      isFavorite: favorites['Upper Body']!,
                      onFavoritePressed: () => setState(() {
                        favorites['Upper Body'] = !favorites['Upper Body']!;
                      }),
                    ),
                    const SizedBox(height: 18),
                    _buildWorkoutTile(
                      title: 'Full Body Stretching',
                      image: 'assets/stretching.png',
                      duration: '45 Minutes',
                      calories: '1430 Kcal',
                      exercises: '5 Exercises',
                      youtubeUrl: workoutYoutubeLinks['Full Body Stretching']!,
                      isFavorite: favorites['Full Body Stretching']!,
                      onFavoritePressed: () => setState(() {
                        favorites['Full Body Stretching'] = !favorites['Full Body Stretching']!;
                      }),
                    ),
                    const SizedBox(height: 18),
                    _buildWorkoutTile(
                      title: 'Glutes & Abs',
                      image: 'assets/glutes.png',
                      duration: '25 Minutes',
                      calories: '1220 Kcal',
                      exercises: '8 Exercises',
                      youtubeUrl: workoutYoutubeLinks['Glutes & Abs']!,
                      isFavorite: favorites['Glutes & Abs']!,
                      onFavoritePressed: () => setState(() {
                        favorites['Glutes & Abs'] = !favorites['Glutes & Abs']!;
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTile({
    required String title,
    required String image,
    required String duration,
    required String calories,
    required String exercises,
    required String youtubeUrl,
    required bool isFavorite,
    required VoidCallback onFavoritePressed,
  }) {
    return GestureDetector(
      onTap: () => _launchYoutubeVideo(youtubeUrl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side content
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(duration, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(calories, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(exercises, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.play_circle_fill, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Youtube Channel",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      image,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoritePressed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchYoutubeVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube')),
        );
      }
    }
  }
}