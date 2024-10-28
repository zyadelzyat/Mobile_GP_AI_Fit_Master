import 'package:flutter/material.dart';
import 'package:untitled/home_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( // Added const for performance
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// every page own class