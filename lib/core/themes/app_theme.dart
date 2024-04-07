import 'package:flutter/material.dart' show Color;

/// Abstract class [AppThemes] serves as a blueprint for defining theme-specific properties
/// within the application. It ensures that all themes implement a consistent set of properties,
/// such as [fontFamily], and a comprehensive list of color names used across the app's UI.
/// This approach facilitates the creation of new themes by providing a structured template,
/// thereby preventing omissions of key color definitions and maintaining visual consistency.
/// Developers extending this class are required to define all abstract properties, ensuring
/// that each theme is complete and aligned with the app's design standards.

abstract class AppThemes {
  String get themeName;

  String get fontFamily;

  Color get primaryColor;

  Color get fontColor;
}

