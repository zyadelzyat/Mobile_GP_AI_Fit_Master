import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/NutritionMainPage.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, String>> favoriteRecipes;

  FavoritesPage({required this.favoriteRecipes});

  final Color darkCard = const Color(0xFF2B2B40);
  final Color yellow = const Color(0xFFE5FF70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1A33),
        elevation: 0,
        title: const Text('Favorites',
            style: TextStyle(color: Color(0xFFB28DFF), fontWeight: FontWeight.bold)),
      ),
      body: favoriteRecipes.isEmpty
          ? Center(child: Text("No favorites yet!", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(recipe["image"]!,
                    width: 60, height: 60, fit: BoxFit.cover),
              ),
              title: Text(recipe["title"]!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(recipe["subtitle"]!,
                  style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.star, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
