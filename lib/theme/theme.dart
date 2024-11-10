import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isDynamicColorsEnabled = true;
  ThemeModeType _themeMode = ThemeModeType.light;

  static const String darkModeKey = 'darkModeEnabled';
  static const String dynamicColorsKey = 'dynamicColorsEnabled';
  static const String themeModeKey = 'themeMode';

  ThemeModel() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;
  ThemeModeType get themeMode => _themeMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePreference(darkModeKey, _isDarkMode);
    notifyListeners();
  }

  void toggleDynamicColors() {
    _isDynamicColorsEnabled = !_isDynamicColorsEnabled;
    _savePreference(dynamicColorsKey, _isDynamicColorsEnabled);
    notifyListeners();
  }

  void changeThemeMode(ThemeModeType mode) {
    _themeMode = mode;
    _savePreference(themeModeKey, mode.toString());
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(darkModeKey) ?? true;
    _isDynamicColorsEnabled = prefs.getBool(dynamicColorsKey) ?? true;
    _themeMode = _getSavedThemeMode(prefs.getString(themeModeKey));
    notifyListeners();
  }

  Future<void> _savePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }

  ThemeModeType _getSavedThemeMode(String? mode) {
    switch (mode) {
      case 'ThemeModeType.light':
        return ThemeModeType.light;
      case 'ThemeModeType.dark':
        return ThemeModeType.dark;
      case 'ThemeModeType.system':
        return ThemeModeType.system;
      default:
        return ThemeModeType.system;
    }
  }
}
