// theme_model.dart, retrieves and updates light and dark color themes.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import '../main.dart' show prefs;

/// This class is used to retrieve and update theme data.
class ThemeModel extends ChangeNotifier {
  ThemeModel();

  /// Return the theme based on the current light/dark setting.
  ThemeData getTheme() {
    final isDark = prefs.getBool('dark_theme') ?? false;
    return isDark ? darkTheme : lightTheme;
  }

  /// Update the themes throughout the app.
  void updateTheme() {
    notifyListeners();
  }

  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      // Primary used for various built-in highlights.
      primary: Color(0xff03045e),
      onPrimary: Colors.white,
      // Primary container used for selected rows.
      primaryContainer: Color(0xff03045e),
      onPrimaryContainer: Colors.white,
      // Secondary used for table headers (same as appBar).
      secondary: Color(0xff0077b6),
      onSecondary: Colors.white,
      // Tertiary used for text field editor labels (if active).
      tertiary: Color(0xff023e8a),
      onTertiary: Colors.white,
      // Tertiary Container used for text field editor labels (if inactive).
      tertiaryContainer: Color(0xff023e8a),
      onTertiaryContainer: Color(0xffadb5bd),
      // Background is used for static background areas.
      background: Color(0xfff3d5b5),
      onBackground: Colors.black,
      // Surface used for field editors and tables (if active).
      surface: Color(0xffffedd8),
      onSurface: Colors.black,
      // Surface used for field editors (if inactive).
      surfaceVariant: Color(0xffffedd8),
      onSurfaceVariant: Color(0xffcccccc),
      // Used on a surface for highlighted (not selected) items.
      surfaceTint: Color(0xff0077b6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff0077b6),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        color: Colors.black,
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      // Primary used for various built-in highlights.
      primary: Color(0xff00b4d8),
      onPrimary: Colors.black,
      // Primary container used for selected rows.
      primaryContainer: Color(0xff03045e),
      onPrimaryContainer: Colors.white,
      // Secondary used for table headers (same as appBar).
      secondary: Colors.black,
      onSecondary: Color(0xff00b4d8),
      // Tertiary used for text field editor labels (if active).
      tertiary: Color(0xff023e8a),
      onTertiary: Colors.white,
      // Tertiary Container used for text field editor labels (if inactive).
      tertiaryContainer: Color(0xff023e8a),
      onTertiaryContainer: Color(0xffadb5bd),
      // Background is used for static background areas.
      background: Color(0xff343a40),
      onBackground: Colors.black,
      // Surface used for field editors and tables (if active).
      surface: Color(0xff212529),
      onSurface: Color(0xffe9ecef),
      // Surface used for field editors (if inactive).
      surfaceVariant: Color(0xff212529),
      onSurfaceVariant: Color(0xff444444),
      // Used on a surface for highlighted (not selected) items.
      surfaceTint: Color(0xff0077b6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Color(0xff00b4d8),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    useMaterial3: true,
  );
}
