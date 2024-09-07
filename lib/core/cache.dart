import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _themeColor = Colors.green; // اللون الافتراضي

  Color get themeColor => _themeColor;

  void changeThemeColor(Color color) async {
    _themeColor = color;
    notifyListeners();

    // حفظ اللون في SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.value);
  }

  // استرجاع اللون المحفوظ
  Future<void> loadThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('themeColor');
    if (colorValue != null) {
      _themeColor = Color(colorValue);
      notifyListeners();
    }
  }
}
