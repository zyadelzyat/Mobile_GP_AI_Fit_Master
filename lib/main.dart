import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/profile.dart';
import 'package:untitled/Login___Signup/01_signin_screen.dart';
import 'Home__Page/00_home_page.dart';
import 'Login___Signup/signup_screen.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'Set Up/03 GenderSelectionScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GenderSelectionApp(),
    ),
  );
}

class GenderSelectionApp extends StatefulWidget {
  const GenderSelectionApp({super.key});

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
      theme: lightTheme, // Use your light theme
      darkTheme: darkTheme, // Use your dark theme
      themeMode: themeProvider.themeMode, // Use the selected theme mode
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
