import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white, // AppBar content color
    ),
    // Add more light theme properties here
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white, // AppBar content color
    ),
    scaffoldBackgroundColor: Colors.grey[900], // Dark background
    cardColor: Colors.grey[800], // Card background
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
        color: Colors.white,
      ), // Ensure dialog titles are white
      // Add more text styles for dark theme
    ),
    // Add more dark theme properties here
  );
}
