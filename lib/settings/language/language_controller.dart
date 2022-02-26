import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main.dart';
import 'package:hapi/settings/settings_option_model.dart';

// TODO update to match google spreadsheet languages
//List of languages that are supported.  Used in selector.
//Follow this plugin for translating a google sheet to languages
//https://github.com/aloisdeniel/flutter_sheet_localization
//Flutter App translations google sheet
//https://docs.google.com/spreadsheets/d/1oS7iJ6ocrZBA53SxRfKF0CG9HAaXeKtzvsTBhgG4Zzk/edit?usp=sharing
final List<SettingsOptionModel> languageOptions = [
  SettingsOptionModel(key: "zh", value: "中文"), //Chinese
  SettingsOptionModel(key: "de", value: "Deutsche"), //German
  SettingsOptionModel(key: "en", value: "English"), //English
  SettingsOptionModel(key: "es", value: "Español"), //Spanish
  SettingsOptionModel(key: "fr", value: "Français"), //French
  SettingsOptionModel(key: "hi", value: "हिन्दी"), //Hindi
  SettingsOptionModel(key: "ja", value: "日本語"), //Japanese
  SettingsOptionModel(key: "pt", value: "Português"), //Portuguese
  SettingsOptionModel(key: "ru", value: "русский"), //Russian
];

/// saves and loads our selected language.
class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final language = "".obs;

  static const String defaultLanguage = 'en';

  String get currentLanguage => language.value;

  @override
  void onInit() {
    super.onInit();
    setInitialLocalLanguage();
  }

  /// Retrieves and Sets language based on device settings
  setInitialLocalLanguage() {
    if (currentLanguageStore.value == '') {
      String _deviceLanguage = ui.window.locale.toString();
      _deviceLanguage =
          _deviceLanguage.substring(0, 2); //only get 1st 2 characters
      print(ui.window.locale.toString());
      updateLanguage(_deviceLanguage);
    }
  }

  /// Gets current language stored
  RxString get currentLanguageStore {
    language.value = s.read('language') ?? '';
    return language;
  }

  /// gets the language locale app is set to
  Locale? get getLocale {
    if (currentLanguageStore.value == '') {
      language.value = defaultLanguage;
      updateLanguage(defaultLanguage);
    } else if (currentLanguageStore.value != '') {
      //set the stored string country code to the locale
      return Locale(currentLanguageStore.value);
    }
    // gets the default language key for the system.
    return Get.deviceLocale;
  }

  /// updates the language stored
  Future<void> updateLanguage(String value) async {
    language.value = value;
    await s.write('language', value);
    if (getLocale != null) {
      Get.updateLocale(getLocale!);
    }
    update();
  }
}
