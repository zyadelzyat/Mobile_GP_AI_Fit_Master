import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:untitled/Meal_Plan/Mealpreferences.dart';

class MealPlansPage extends StatefulWidget {
  @override
  _MealPlansPageState createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الصورة الخلفية
          Positioned.fill(
            child: Image.asset(
              "assets/images/meal_banner.png",
              fit: BoxFit.cover,
            ),
          ),

          // المحتوى فوق الصورة
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.white),
                        Icon(Icons.notifications_none, color: Colors.white),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Animation على الكلام والزرار
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      children: [
                        // بوكس عليه blur
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.local_dining, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "Meal Plans",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // زرار شيك
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MealPreferencesPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            shape: const StadiumBorder(),
                            shadowColor: Colors.white,
                            elevation: 5,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                            child: Text(
                              "Know Your Plan",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
