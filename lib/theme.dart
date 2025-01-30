import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF896CFE), // Purple
  scaffoldBackgroundColor: Colors.white, // White
  appBarTheme: const AppBarTheme(
    color: Colors.white, // White
    iconTheme: IconThemeData(color: Color(0xFF232323)), // Black
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF232323)), // Black
    bodyMedium: TextStyle(color: Color(0xFF232323)), // Black
  ), // Lime Green
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFB3A0FF), // Light Purple
  scaffoldBackgroundColor: const Color(0xFF232323), // Black
  appBarTheme: const AppBarTheme(
    color: Color(0xFF232323), // Black
    iconTheme: IconThemeData(color: Colors.white), // White
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // White
    bodyMedium: TextStyle(color: Colors.white), // White
  ), // Purple
);