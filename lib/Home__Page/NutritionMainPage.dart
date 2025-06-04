import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/00_home_page.dart';
import 'package:untitled/Home__Page/favorite_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Profile/profile.dart';
import '../meal/trainee_meal_plans_page.dart';

class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final Color background = Color(0xFF1D1A33);
  final Color primary = Color(0xFFB28DFF);
  final Color yellow = Color(0xFFE5FF70);
  final Color darkCard = Color(0xFF2B2B40);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map _userData = {};
  int _currentNavIndex = 2; // Nutrition tab

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavBarTap(int index) {
    if (!mounted) return;
    if (index == _currentNavIndex) return;
    setState(() {
      _currentNavIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FavoritesPage(favoriteRecipes: [])));
        break;
      case 2:
      // Already on Nutrition
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(primary),
          ),
        ),
      );
    }

    // Only Trainee sees bottom nav bar
    final bool isTrainee = _userData['role'] == 'Trainee';

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
                        child: Text('Meal Ideas',
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
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB29BFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (!mounted) return;
            if (index == _currentNavIndex) return;
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 1:
              // Already on Favorites, no action needed or refresh if required
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NutritionPage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    ),
                  ),
                );
                break;
            }
            setState(() {
              _currentNavIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/home.png')),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/store.png')),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/chat.png')),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/profile.png')),
              label: 'Profile',
            ),
          ],
        ),
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
          child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
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

// Placeholder classes for the imports that are commented out
class MealPlansPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1A33),
      appBar: AppBar(
        title: Text('Meal Plans'),
        backgroundColor: Color(0xFFB28DFF),
      ),
      body: Center(
        child: Text('Meal Plans Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class MealIdeaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1A33),
      appBar: AppBar(
        title: Text('Meal Ideas'),
        backgroundColor: Color(0xFFB28DFF),
      ),
      body: Center(
        child: Text('Meal Ideas Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}