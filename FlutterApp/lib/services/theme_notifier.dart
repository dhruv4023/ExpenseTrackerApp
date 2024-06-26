import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  iconTheme: IconThemeData(color: Colors.black),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  iconTheme: IconThemeData(color: Colors.white),
);

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme;
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode)
      : _currentTheme = _isDarkMode ? darkTheme : lightTheme;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode; 

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}
