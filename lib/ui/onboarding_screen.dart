import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home__Page/00_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI FIT MASTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB3A0FF),
        scaffoldBackgroundColor: const Color(0xFFB3A0FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB3A0FF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFB3A0FF),
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

// --- Onboarding Model ---
class OnboardingModel {
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final IconData? icon;
  final Color iconBackgroundColor;

  const OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
    this.icon,
    this.iconBackgroundColor = const Color(0xFFFFEB3B),
  });
}

// --- Onboarding Screen Widget ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingModel> _pages = [
    const OnboardingModel(
      title: "Welcome to",
      subtitle: "AI FIT MASTER",
      image: "assets/onboarding1.jpg",
      buttonText: "Next",
      iconBackgroundColor: Colors.transparent,
    ),
    const OnboardingModel(
      title: "Start Your Journey Towards A More Active Lifestyle",
      subtitle: "",
      image: "assets/onboarding2.jpg",
      buttonText: "Next",
      icon: Icons.fitness_center,
    ),
    const OnboardingModel(
      title: "Find Nutrition Tips That Fit Your Lifestyle",
      subtitle: "",
      image: "assets/onboarding3.jpg",
      buttonText: "Next",
      icon: Icons.restaurant_menu,
    ),
    const OnboardingModel(
      title: "A Community For You, Challenge Yourself",
      subtitle: "",
      image: "assets/onboarding4.jpg",
      buttonText: "Get Started",
      icon: Icons.people,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          return _buildOnboardingPage(index);
        },
      ),
    );
  }

  Widget _buildOnboardingPage(int index) {
    final isLastPage = index == _pages.length - 1;
    final model = _pages[index];

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Full-screen image with dark overlay
          Positioned.fill(
            child: Image.asset(
              model.image,
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  // Icon (if applicable)
                  if (model.icon != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: model.iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        model.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Subtitle (for first screen)
                  if (model.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        model.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.purple[200],
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLastPage ? Colors.yellow[600] : Colors.white,
                          foregroundColor: isLastPage ? Colors.black : const Color(0xFF6C3EFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          model.buttonText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLastPage ? Colors.black : const Color(0xFF6C3EFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
