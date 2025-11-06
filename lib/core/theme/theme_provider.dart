import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeProvider(this._prefs) {
    _loadTheme();
  }
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> _loadTheme() async {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.light,
      );
      notifyListeners();
    }
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }
}


