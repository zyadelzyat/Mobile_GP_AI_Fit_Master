import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? firstLaunch;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
    // Set system UI overlay style for fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Set status bar to be transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    // Restore system UI when app is closed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstLaunch = prefs.getBool('firstLaunch') ?? true; // Defaults to true
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firstLaunch == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: firstLaunch! ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}

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
      title: "Welcome to AI FIT MASTER",
      description: "Start Your Journey Towards A More Active Lifestyle",
      image: "assets/onboarding1.jpg",
    ),
    const OnboardingModel(
      title: "Find Nutrition Tips That Fit Your Lifestyle",
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

  @override
  void initState() {
    super.initState();
    // Ensure fullscreen mode is applied to onboarding
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    if (mounted) {
      // Restore system UI when leaving onboarding
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return FullScreenOnboardingPage(
            model: _pages[index],
            isLastPage: index == _pages.length - 1,
            onPressed: () {
              if (index == _pages.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class FullScreenOnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final bool isLastPage;
  final VoidCallback onPressed;

  const FullScreenOnboardingPage({
    required this.model,
    required this.isLastPage,
    required this.onPressed,
    super.key,
  });

  get _currentPage => null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen background image
        Image.asset(
          model.image,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),

        // Semi-transparent overlay for the whole screen (optional)
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.2),
        ),

        // Center purple card with content
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Colors.purple.withOpacity(0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon at the top of the purple section
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 40,
                ),
                const SizedBox(height: 16),

                // Title text
                Text(
                  model.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 20),

                // Next button
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Page indicator dots at bottom
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4, // Number of pages
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Fit Master"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Welcome to AI Fit Master!"),
      ),
    );
  }
}