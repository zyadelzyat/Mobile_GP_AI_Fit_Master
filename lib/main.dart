import 'package:flutter/material.dart';
import '00_home_page.dart';  // Import the SignIn screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Screen',
      home: HomePage(),  // Set SignInScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
