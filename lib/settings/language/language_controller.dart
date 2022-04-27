import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/settings/settings_option.dart';

// TODO update to match google spreadsheet languages
//List of languages that are supported.  Used in selector.
//Follow this plugin for translating a google sheet to languages
//https://github.com/aloisdeniel/flutter_sheet_localization
//Flutter App translations google sheet
//https://docs.google.com/spreadsheets/d/1oS7iJ6ocrZBA53SxRfKF0CG9HAaXeKtzvsTBhgG4Zzk/edit?usp=sharing
final List<SettingsOption> languageOptions = [
  SettingsOption('sq', 'Albanian - Shqip'), // Albanian
  SettingsOption('ar', 'Arabic - عربي'), // Arabic
  SettingsOption('az', 'Azerbaijani - Azərbaycanlı'), // Azerbaijani
  SettingsOption('bn', 'Bengali - বাংলা'), // Bengali
  SettingsOption('bg', 'Bulgarian - български'), // Bulgarian
  SettingsOption('zh', 'Chinese - 中国人'), // Chinese
  SettingsOption('da', 'Danish - dansk'), // Danish
  SettingsOption('nl', 'Dutch - Nederlands'), // Dutch
  SettingsOption('en', 'English'), // English
  SettingsOption('fr', 'French - Français'), // French
  SettingsOption('de', 'German - Deutsch'), // German
  SettingsOption('gu', 'Gujarati - ગુજરાત'), // Gujarati
  SettingsOption('hi', 'Hindi - हिन्दी'), // Hindi
  SettingsOption('in', 'Indonesian - bahasa Indonesia'), // Indonesian
  SettingsOption('it', 'Italian - Italiano'), // Italian
  SettingsOption('ja', 'Japanese - 日本語'), //Japanese
  SettingsOption('kk', 'Kazakh - Қазақ'), // Kazakh
  SettingsOption('ky', 'Kirghiz - Киргизский'), // Kirghiz
  SettingsOption('ku', 'Kurdish - Kurdî'), // Kurdish
  SettingsOption('ms', 'Malay - Melayu'), // Malay
  SettingsOption('ps', 'Pashto - پښتو'), // Pashto
  SettingsOption('fa', 'Persian - فارسی'), // Persian
  SettingsOption('pt', 'Portuguese - Português'), //Portuguese
  SettingsOption('pa', 'Punjabi - ਪੰਜਾਬੀ'), // Punjabi
  SettingsOption('ro', 'Romanian - Română'), // Romanian
  SettingsOption('ru', 'Russian - Русский'), // Russian
  SettingsOption('so', 'Somali - Soomaali'), // Somali
  SettingsOption('es', 'Spanish - español'), // Spanish
  SettingsOption('su', 'Sudanese - Sudan'), // Sudanese
  SettingsOption('tg', 'Tajik - Тоҷик'), // Tajik
  SettingsOption('tt', 'Tatar - Татар'), // Tatar
  SettingsOption('th', 'Thai - ไทย'), // Thai
  SettingsOption('tr', 'Turkish - Türkçe'), // Turkish
  SettingsOption('tk', 'Turkmen - Türkmenler'), // Turkmen
  SettingsOption('ur', 'Urdu - اردو'), // Urdu
  SettingsOption('uz', 'Uzbek - O\'zbek tili'), // Uzbek
];

/// saves and loads our selected language.
class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final String defaultLanguage = 'en';

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
      l.d('setInitialLocalLanguage: ui.window.locale="$deviceLanguage"');

      //only get 1st 2 characters
      if (deviceLanguage.length > 2) {
        l.w('Device language "$deviceLanguage" is longer than 2 characters, shortening it.');
        deviceLanguage = deviceLanguage.substring(0, 2);
      }
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

  bool isNotSupportedLanguage(String language) {
    for (SettingsOption optionModel in languageOptions) {
      if (optionModel.key == language) return false; // language is supported
    }
    return true; // not found, language is no supported
  }

  /// updates the language stored
  Future<void> updateLanguage(String newLanguage) async {
    if (isNotSupportedLanguage(newLanguage)) {
      l.e('The language "$newLanguage", is not supported, using default $defaultLanguage');
      newLanguage = defaultLanguage;
    }

    await s.wr('language', newLanguage);
    _currentLanguage = newLanguage;

    // TODO what does this do, needed/wanted?
    if (getLocale != null) {
      Get.updateLocale(getLocale!);
    }

    update();
  }
}
