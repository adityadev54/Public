import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  final SharedPreferences preferences;
  late ThemeMode themeMode;
  late bool animate;
  SettingsController(this.preferences) {
    final stored = preferences.getString('shaderx.theme');
    themeMode =
        ThemeMode.values.where((mode) => mode.name == stored).firstOrNull ??
        ThemeMode.dark;
    animate = preferences.getBool('shaderx.animate') ?? true;
  }
  Future<void> setTheme(ThemeMode value) async {
    if (!await preferences.setString('shaderx.theme', value.name)) {
      throw StateError('Preference save failed');
    }
    themeMode = value;
    notifyListeners();
  }

  Future<void> setAnimate(bool value) async {
    if (!await preferences.setBool('shaderx.animate', value)) {
      throw StateError('Preference save failed');
    }
    animate = value;
    notifyListeners();
  }
}
