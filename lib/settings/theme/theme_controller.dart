import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';

// https://gist.github.com/RodBr/37310335c6639f486bb3c8a628052405
// https://medium.com/swlh/flutter-dynamic-themes-in-3-lines-c3b375f292e3

/// saves and loads our selected theme.
class ThemeController extends GetxHapi {
  static ThemeController get to => Get.find();

  String theme = 'dark';
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  String get currentTheme => theme;

  Future<void> setThemeMode(String value) async {
    theme = value;
    _themeMode = getThemeModeFromString(value);
    Get.changeThemeMode(_themeMode);
    await s.wr('theme', value);
    update();
  }

  ThemeMode getThemeModeFromString(String themeString) {
    ThemeMode _setThemeMode = ThemeMode.dark;
    if (themeString == 'light') {
      _setThemeMode = ThemeMode.light;
    }
    return _setThemeMode;
  }

  getThemeModeFromStore() async {
    String _themeString = s.rd('theme') ?? 'dark';
    setThemeMode(_themeString);
  }

  // checks whether dark mode is set via system or previously by user
  bool get isDarkModeOn {
    if (WidgetsBinding.instance.window.platformBrightness == Brightness.dark) {
      return true;
    }

    if (currentTheme == 'dark') {
      return true;
    }

    return false;
  }
}
