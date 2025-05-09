import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Login___Signup/01_signin_screen.dart';
import 'Home__Page/admin_dashboard.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'Set Up/06 WeightSelectionScreen.dart';
import 'Set Up/03 GenderSelectionScreen.dart';
import 'Home__Page/Store.dart';
import 'Home__Page/00_home_page.dart';
import 'package:untitled/rating/AddRatingPage.dart';
import 'ui/onboarding_screen.dart';
import 'Home__Page/Store.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool firstLaunch = prefs.getBool('firstLaunch') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: GenderSelectionApp(firstLaunch: firstLaunch),
    ),
  );
}

class GenderSelectionApp extends StatefulWidget {
  final bool firstLaunch;
  const GenderSelectionApp({super.key, required this.firstLaunch});

  @override
  _GenderSelectionAppState createState() => _GenderSelectionAppState();
}

class _GenderSelectionAppState extends State<GenderSelectionApp> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SignInScreen(),
      // home: const SupplementsStorePage(),
      // home: OnboardingScreen(),
      // home: const WeightSelectionScreen();
      // home: const GenderSelectionScreen(),
      // home:  SupplementsStorePage(),
      //  home: const SignInScreen(),
      // home : AdminDashboard(),
      // home : const HomePage(),
      // home : const AddRatingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
