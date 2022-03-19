import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/settings/settings_option_model.dart';

// TODO update to match google spreadsheet languages
//List of languages that are supported.  Used in selector.
//Follow this plugin for translating a google sheet to languages
//https://github.com/aloisdeniel/flutter_sheet_localization
//Flutter App translations google sheet
//https://docs.google.com/spreadsheets/d/1oS7iJ6ocrZBA53SxRfKF0CG9HAaXeKtzvsTBhgG4Zzk/edit?usp=sharing
final List<SettingsOptionModel> languageOptions = [
  SettingsOptionModel(key: 'zh', value: '中文'), //Chinese
  SettingsOptionModel(key: 'de', value: 'Deutsche'), //German
  SettingsOptionModel(key: 'en', value: 'English'), //English
  SettingsOptionModel(key: 'es', value: 'Español'), //Spanish
  SettingsOptionModel(key: 'fr', value: 'Français'), //French
  SettingsOptionModel(key: 'hi', value: 'हिन्दी'), //Hindi
  SettingsOptionModel(key: 'ja', value: '日本語'), //Japanese
  SettingsOptionModel(key: 'pt', value: 'Português'), //Portuguese
  SettingsOptionModel(key: 'ru', value: 'русский'), //Russian
];

/// saves and loads our selected language.
class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  static const String defaultLanguage = 'en';

  String _currentLanguage = '';
  String get currentLanguage => _currentLanguage;

  LanguageController() {
    setInitialLocalLanguage();
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   setInitialLocalLanguage();
  // }

  /// Gets current language stored, or return blank
  String get _currentLanguageStore => s.rd('language') ?? '';

  /// Retrieves and Sets language based on device settings
  setInitialLocalLanguage() {
    String currentLanguage = _currentLanguageStore;
    if (currentLanguage == '') {
      String deviceLanguage = ui.window.locale.toString();
      //only get 1st 2 characters
      if (deviceLanguage.length > 2) {
        l.w('Device language "$deviceLanguage" is longer than 2 characters, shortening it.');
        deviceLanguage = deviceLanguage.substring(0, 2);
      }
      l.d('setInitialLocalLanguage: ui.window.locale="${ui.window.locale.toString()}"');
      updateLanguage(deviceLanguage);
    } else {
      updateLanguage(currentLanguage);
    }
  }

  /// gets the language locale app is set to
  Locale? get getLocale {
    String currentLanguage = _currentLanguageStore;
    if (currentLanguage != '') {
      //set the stored string country code to the locale
      return Locale(currentLanguage);
    }

    // gets the default language key for the system.
    return Get.deviceLocale;
  }

  /// updates the language stored
  Future<void> updateLanguage(String value) async {
    await s.wr('language', value);
    _currentLanguage = value;
    if (getLocale != null) {
      Get.updateLocale(getLocale!);
    }
    update();
  }
}
