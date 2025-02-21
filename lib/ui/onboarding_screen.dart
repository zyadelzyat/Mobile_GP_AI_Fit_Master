import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    const OnboardingModel(
      title: "Welcome to\nAFFIT MASTER",
      description: "Start Your Journey Towards A More Active Lifestyle",
      image: "assets/onboarding1.jpg", // Add your images
    ),
    const OnboardingModel(
      title: "Find Nutrition Tips\nThat Fit Your Lifestyle",
      description: "Personalized dietary recommendations based on your goals",
      image: "assets/onboarding2.jpg",
    ),
    const OnboardingModel(
      title: "A Community For You",
      description: "Challenge Yourself with like-minded people",
      image: "assets/onboarding3.jpg",
    ),
    const OnboardingModel(
      title: "Ready to Transform?",
      description: "Let's create your personalized fitness plan",
      image: "assets/onboarding4.jpg",
    ),
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                model: _pages[index],
                isLastPage: index == _pages.length - 1,
                onPressed: _completeOnboarding,
              );
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final bool isLastPage;
  final VoidCallback onPressed;

  const OnboardingPage({
    required this.model,
    required this.isLastPage,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(model.image, height: 300),
          const SizedBox(height: 40),
          Text(
            model.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            model.description,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: Text(isLastPage ? "Get Started" : "Next"),
          ),
        ],
      ),
    );
  }
}

class OnboardingModel {
  final String title;
  final String description;
  final String image;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}