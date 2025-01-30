import 'package:flutter/material.dart';

class VideosPage extends StatelessWidget {
  final List<Map<String, String>> exerciseVideos = [
    {
      "title": "Push-Ups",
      "description": "Learn how to do push-ups correctly.",
      "videoUrl": "https://www.youtube.com/watch?v=IODxDxX7oi4",
    },
    {
      "title": "Squats",
      "description": "Master the perfect squat technique.",
      "videoUrl": "https://www.youtube.com/watch?v=aclHkVaku9U",
    },
    {
      "title": "Plank",
      "description": "Improve your core strength with planks.",
      "videoUrl": "https://www.youtube.com/watch?v=pSHjTRCQxIw",
    },
    // Add more videos here
  ];

  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Videos"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: exerciseVideos.length,
        itemBuilder: (context, index) {
          final video = exerciseVideos[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(video["title"]!),
              subtitle: Text(video["description"]!),
              trailing: Icon(Icons.play_circle_filled, color: Theme.of(context).primaryColor),
              onTap: () {
                // Navigate to a video player page or play the video directly
              },
            ),
          );
        },
      ),
    );
  }
}