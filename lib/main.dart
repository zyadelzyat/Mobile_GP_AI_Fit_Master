import 'package:flutter/material.dart';
import '01_signin_screen.dart';  // Import the SignIn screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Onboarding Screen',
      home: SignInScreen(),  // Set SignInScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
