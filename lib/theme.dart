import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF896CFE), // Purple
  scaffoldBackgroundColor: Colors.white, // White
  appBarTheme: AppBarTheme(
    color: Colors.white, // White
    iconTheme: IconThemeData(color: Color(0xFF232323)), // Black
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF232323)), // Black
    bodyMedium: TextStyle(color: Color(0xFF232323)), // Black
  ), // Lime Green
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFB3A0FF), // Light Purple
  scaffoldBackgroundColor: Color(0xFF232323), // Black
  appBarTheme: AppBarTheme(
    color: Color(0xFF232323), // Black
    iconTheme: IconThemeData(color: Colors.white), // White
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // White
    bodyMedium: TextStyle(color: Colors.white), // White
  ), // Purple
);