import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/Meal_Plan/MealPlansPage.dart';
import 'package:untitled/Home__Page/favorite_page.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/Home__Page/favorite_page.dart';
import 'package:untitled/Meal_Plan/MealPlansPage.dart';
import 'package:untitled/Meal_Plan/Mealpreferences.dart'; // عدل الاسم حسب اسم الملف لو مختلف
import 'package:untitled/Meal_Idea/MealIdeaPage.dart';


class NutritionPage extends StatelessWidget {
  final Color background = Color(0xFF1D1A33);
  final Color primary = Color(0xFFB28DFF);
  final Color yellow = Color(0xFFE5FF70);
  final Color darkCard = Color(0xFF2B2B40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text(
          'Nutrition',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: primary),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle buttons
            Container(
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MealPlansPage()),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: yellow,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text('Meal Plans',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MealIdeaPage()),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: yellow,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text('Meal Plans',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Recipe of the Day
            Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/recipe_day.png',
                        height: 180,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: yellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("Recipe Of The Day",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Carrot And Orange Smoothie",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text("10 Minutes",
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(width: 12),
                                Text("•", style: TextStyle(color: Colors.white)),
                                SizedBox(width: 12),
                                Text("70 Cal",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Recommended section
            Text('Recommended',
                style: TextStyle(
                    color: yellow, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                _recommendedCard('Fruit Smoothie', '12 Minutes | 120 Cal',
                    'assets/images/fruit_smoothie.png'),
                SizedBox(width: 12),
                _recommendedCard('Salads With Quinoa', '12 Minutes | 120 Cal',
                    'assets/images/quinoa_salad.png'),
              ],
            ),

            SizedBox(height: 24),

            // Recipes For You section
            Text('Recipes For You',
                style: TextStyle(
                    color: yellow, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _recipeListTile('Delights With Greek Yogurt', '6 Minutes | 200 Cal',
                'assets/images/greek_yogurt.png'),
            SizedBox(height: 12),
            _recipeListTile('Baked Salmon', '30 Minutes | 350 Cal',
                'assets/images/baked_salmon.png'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage(favoriteRecipes: [],)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: ''),
        ],
      ),
    );
  }

  Widget _recommendedCard(String title, String subtitle, String imagePath) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
              image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Icon(Icons.play_circle_fill, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeListTile(String title, String subtitle, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
          Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(title,
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white70)),
        trailing: Icon(Icons.star_border, color: Colors.white),
      ),
    );
  }
}
