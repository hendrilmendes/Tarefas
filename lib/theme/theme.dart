import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isDynamicColorsEnabled = true;
  ThemeModeType _themeMode = ThemeModeType.light;

  final List<MaterialColor> availableAccentColors = [
    Colors.amber,
    Colors.blue,
    Colors.brown,
    Colors.green,
    Colors.grey,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.yellow,
  ];
  late MaterialColor _primaryColor;

  static const String darkModeKey = 'darkModeEnabled';
  static const String dynamicColorsKey = 'dynamicColorsEnabled';
  static const String themeModeKey = 'themeMode';

  static const String primaryColorKey = 'primaryColorIndex';

  ThemeModel() {
    _primaryColor = availableAccentColors[1];
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;
  ThemeModeType get themeMode => _themeMode;

  MaterialColor get primaryColor => _primaryColor;

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

  void setPrimaryColor(MaterialColor color) {
    _primaryColor = color;
    int colorIndex = availableAccentColors.indexOf(color);
    _savePreference(primaryColorKey, colorIndex);
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(darkModeKey) ?? true;
    _isDynamicColorsEnabled = prefs.getBool(dynamicColorsKey) ?? true;
    _themeMode = _getSavedThemeMode(prefs.getString(themeModeKey));

    int colorIndex = prefs.getInt(primaryColorKey) ?? 1;
    if (colorIndex >= 0 && colorIndex < availableAccentColors.length) {
      _primaryColor = availableAccentColors[colorIndex];
    }

    notifyListeners();
  }

  Future<void> _savePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
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
