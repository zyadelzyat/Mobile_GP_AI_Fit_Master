import 'package:flutter/material.dart';
import 'Home__Page/00_home_page.dart';  // Import the SignIn screen
// import 'AI/chatbot.dart';
import 'Login___Signup/01_signin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Screen',
      home: SignInScreen(),  // Set SignInScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
