import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF896CFE), // Purple
  scaffoldBackgroundColor: Colors.white, // White
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white, // AppBar background color
    iconTheme: IconThemeData(color: Color(0xFF232323)), // AppBar icon color
    titleTextStyle: TextStyle(
      color: Color(0xFF232323), // AppBar title color
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF232323), // Main text color
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF232323), // Secondary text color
      fontSize: 14,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF232323),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF896CFE), // Purple
      foregroundColor: Colors.white, // Button text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  cardColor: const Color(0xFFF5F5F5), // Background for cards
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFB3A0FF), // Light Purple
  scaffoldBackgroundColor: const Color(0xFF232323), // Black
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF232323), // AppBar background color
    iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
    titleTextStyle: TextStyle(
      color: Colors.white, // AppBar title color
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white, // Main text color
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Colors.white70, // Secondary text color
      fontSize: 14,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF896CFE), // Purple
      foregroundColor: Colors.white, // Button text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  cardColor: const Color(0xFF383838), // Background for cards
);