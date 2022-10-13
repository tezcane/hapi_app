import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';

/// Saves and loads theme (light or dark mode).
class ThemeC extends GetxHapi {
  static ThemeC get to => Get.find();

//ThemeMode _themeMode = ThemeMode.dark;
  String _theme = 'dark';
  bool isDarkMode = true; // false is Light mode

//ThemeMode get themeMode => _themeMode;
  String get currentTheme => _theme;

  initTheme() async => setThemeMode(s.rd('theme') ?? 'dark');

  Future<void> setThemeMode(String newTheme) async {
    assert(newTheme == 'dark' || newTheme == 'light');

    _theme = newTheme;
    if (newTheme == 'light') {
      Get.changeThemeMode(ThemeMode.light);
      isDarkMode = false;
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      isDarkMode = true;
    }

    await s.wr('theme', newTheme);
    update();
  }

  // bool get systemDefaultTheme => WidgetsBinding.instance.window.platformBrightness;
}
