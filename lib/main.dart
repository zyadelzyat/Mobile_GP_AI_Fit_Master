import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/profile.dart';
// import 'package:untitled/Login___Signup/01_signin_screen.dart';
import 'Home__Page/00_home_page.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'Set Up/03 GenderSelectionScreen.dart'; // Import your GenderSelectionScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GenderSelectionApp(),
    ),
  );
}

class GenderSelectionApp extends StatelessWidget {
  const GenderSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: lightTheme, // Use your light theme
      darkTheme: darkTheme, // Use your dark theme
      themeMode: themeProvider.themeMode, // Use the selected theme mode
      home:  HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}