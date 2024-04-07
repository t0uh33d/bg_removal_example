import 'default_theme.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'app_theme.dart';

class ThemeHandler with ChangeNotifier {
  static final ThemeHandler i = ThemeHandler._i();

  ThemeHandler._i();

  factory ThemeHandler() => i;

  static late AppThemes _currentTheme;

  static AppThemes get currentTheme => _currentTheme;

  void updateTheme(AppThemes theme) {
    _currentTheme = theme;
  }

  Future<void> initializeTheme() async {
    _currentTheme = DefaultTheme();
  }

  AppThemes? getStaticThemeInstance(String? themeName) {
    if (themeName == null) return null;
    List<AppThemes> preDefinedThemes = [DefaultTheme()];

    return preDefinedThemes.firstWhere(
      (element) => element.themeName == themeName,
      orElse: () => DefaultTheme(),
    );
  }
}
