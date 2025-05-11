import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteRecipes;

  FavoritesPage({required this.favoriteRecipes});

  final Color darkCard = const Color(0xFF2B2B40);
  final Color accentColor = const Color(0xFFB28DFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1A33),
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Color(0xFFB28DFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB28DFF)),
          onPressed: () {
            // Simply pop the current route to go back to the previous page
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFB28DFF)),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFB28DFF)),
            onPressed: () {
              // TODO: Implement notification functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFB28DFF)),
            onPressed: () {
              // TODO: Implement profile functionality
            },
          ),
        ],
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text(
          "No favorites yet!",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            color: darkCard,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      recipe['image'] ?? 'assets/images/placeholder.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'] ?? 'No Title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              recipe['duration'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              recipe['calories'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.fitness_center,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              recipe['exercises'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Color(0xFFB28DFF)),
                    onPressed: () {
                      final videoUrl = recipe['videoUrl'] as String?;
                      if (videoUrl != null && videoUrl.isNotEmpty) {
                        _launchVideo(videoUrl);
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
  }

  Future _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }
}
