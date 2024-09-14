import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _themeColor = Colors.orange; // Default color

  Color get themeColor => _themeColor;

  // Load theme color from SharedPreferences
  Future<void> loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getInt('themeColor') ?? _themeColor.value;
    _themeColor = Color(savedColor);
    notifyListeners();
  }

  // Save theme color to SharedPreferences
  Future<void> saveThemeColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.value);
    _themeColor = color;
    notifyListeners();
  }
}
