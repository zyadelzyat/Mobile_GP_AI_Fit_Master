import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'Home__Page/00_home_page.dart'; // Import your home page
import 'AI/chatbot.dart'; // Import your chatbot page
import 'Login___Signup/01_signin_screen.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Onboarding Screen',
      theme: lightTheme, // Light theme
      darkTheme: darkTheme, // Dark theme
      themeMode: themeProvider.themeMode, // Use the theme mode from the provider
      home: SignInScreen(), // Set your initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}