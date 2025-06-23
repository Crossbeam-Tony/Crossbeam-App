import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFFF9800); // Material Orange
  static const secondaryColor = Color(0xFF2196F3); // Material Blue
  static const errorColor = Color(0xFFE53935); // Material Red
  static const backgroundColor = Colors.white;
  static const darkBackgroundColor = Color(0xFF121212);

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: Colors.transparent),
        unselectedIconTheme: IconThemeData(color: Colors.transparent),
        selectedLabelTextStyle: TextStyle(color: primaryColor, fontSize: 14),
        unselectedLabelTextStyle:
            TextStyle(color: Colors.black87, fontSize: 14),
        indicatorColor: Colors.transparent,
        useIndicator: false,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkBackgroundColor,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: Colors.transparent),
        unselectedIconTheme: IconThemeData(color: Colors.transparent),
        selectedLabelTextStyle: TextStyle(color: primaryColor, fontSize: 14),
        unselectedLabelTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        indicatorColor: Colors.transparent,
        useIndicator: false,
      ),
    );
  }
}
