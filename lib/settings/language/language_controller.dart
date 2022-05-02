import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/settings/settings_option.dart';
import 'package:hijri/hijri_calendar.dart';

/// List of languages that are supported. Used in selector and google tr sheet.
/// TODO load from file: https://stackoverflow.com/questions/70394427/flutter-getx-put-internalition-translations-in-different-files-for-each-language
/// TODO Arabic text too small, use textScaleFactor?: https://stackoverflow.com/questions/50535185/right-to-left-rtl-in-flutter
final List<SettingsOption> languageOptions = [
  SettingsOption('sq', 'Albanian - Shqip'), // Albanian
  SettingsOption('ar', 'Arabic - عربي'), // Arabic
  SettingsOption('az', 'Azerbaijani - Azərbaycanlı'), // Azerbaijani
  SettingsOption('bn', 'Bengali - বাংলা'), // Bengali
//SettingsOption('  ', 'Bosnian - '), // Bosnian TODO
  SettingsOption('bg', 'Bulgarian - български'), // Bulgarian
  SettingsOption('zh', 'Chinese - 中国人'), // Chinese
  SettingsOption('da', 'Danish - dansk'), // Danish
  SettingsOption('nl', 'Dutch - Nederlands'), // Dutch
  SettingsOption('en', 'English'), // English
  SettingsOption('fr', 'French - Français'), // French
  SettingsOption('de', 'German - Deutsch'), // German
  SettingsOption('gu', 'Gujarati - ગુજરાત'), // Gujarati
//SettingsOption('he', 'Hebrew - '), // Hebrew TODO
  SettingsOption('hi', 'Hindi - हिन्दी'), // Hindi-Devanagari
  SettingsOption('in', 'Indonesian - Bahasa Indonesia'), // Indonesian
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
//SettingsOption('bo', 'Tibetan - '), // Tibetan TODO
  SettingsOption('tr', 'Turkish - Türkçe'), // Turkish
  SettingsOption('tk', 'Turkmen - Türkmenler'), // Turkmen
  SettingsOption('ur', 'Urdu - اردو'), // Urdu
  SettingsOption('uz', 'Uzbek - O\'zbek tili'), // Uzbek
];

/// saves and loads our selected language.
class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final String defaultLangKey = 'en';

  /// Always a 2 character language key, e.g. "ar", "en", etc.
  String _currLangKey = '';
  String get currLangKey => _currLangKey;

  // TODO more right to left languages: Azeri, Dhivehi/Maldivian, Hebrew, Kurdish (Sorani)
  final Map<String, bool> _nonLeftToRightLangs = {
    'ar': true, // Arabic
    'ps': true, // Pashto
    'fa': true, // Persian Numerals
    'ur': true, // Urdu
    'he': true, // Hebrew
  };
  bool _isRightToLeftLang = false;
  bool get isRightToLeftLang => _isRightToLeftLang;

  /// Use these prefect hash arrays to convert numeral systems (en->ar/ps/etc.).
  /// Note: labeled "en" but are Arabic Numerals (a.k.a. Hindi-Arabic Numerals).
  static const _enNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final Map<String, List<String>> _nonEnNumeralLangs = {
//        ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']; // en/hindi-arabic
    'ar': ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'], // Arabic  (w. ar)
    'ps': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'], // Pashto  (e. ar)
    'fa': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'], // Persian (e. ar)
    'ur': ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'], // Urdu    (e. ar)
    'bn': ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'], // Bengali
    'gu': ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'], // Gujarati
    'hi': ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'], //Hindi-Devanagari
    'th': ['๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'], // Thai
    'bo': ['༠', '༡', '༢', '༣', '༤', '༥', '༦', '༧', '༨', '༩'], // Tibetan
//  Not used for day to day use:
//  'he': ['-', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'], // Hebrew
  };
  List<String> _curNumerals = _enNumerals; // defaults to English
  List<String> get curNumerals => _curNumerals;
  bool _isEnNumerals = true;
  bool get isEnNumerals => _isEnNumerals;

  String _am = ' AM';
  String get am => _am;
  String _pm = ' PM';
  String get pm => _pm;

  @override
  void onInit() {
    super.onInit();
    updateLanguage(_findLanguage());
  }

  /// Retrieves and Sets language based on device settings
  String _findLanguage() {
    String? currentLanguage = s.rd('language');

    // search for code if none is known yet (TODO research more ways)
    currentLanguage ??= _findLangCode(1, ui.window.locale.toString());
    Locale? deviceLocal = Get.deviceLocale;
    if (deviceLocal != null) {
      currentLanguage ??= _findLangCode(2, deviceLocal.toLanguageTag());
      currentLanguage ??= _findLangCode(3, deviceLocal.languageCode);
      currentLanguage ??= _findLangCode(3, deviceLocal.scriptCode);
      currentLanguage ??= _findLangCode(3, deviceLocal.countryCode);
      currentLanguage ??= _findLangCode(3, deviceLocal.toString());
    }

    if (currentLanguage == null) {
      l.e('LanguageController:_setInitialLocalLanguage: Could not find device language, using default "$defaultLangKey"');
      currentLanguage = defaultLangKey;
    }

    return currentLanguage;
  }

  /// Based on code input, we search for the first match of a language key.
  String? _findLangCode(int trackIdx, String? code) {
    if (code == null) {
      l.d('LanguageController:_findLangCode($trackIdx, "$code") was null');
      return null;
    }
    code = code.toLowerCase(); // our language key tags are all lowercase
    if (code.length < 2) {
      l.d('LanguageController:_findLangCode($trackIdx, "$code") code length < 2 characters.');
      return null;
    }
    if (code.length > 2) {
      l.d('LanguageController:_findLangCode($trackIdx, "$code") code length > 2 characters, shortening it.');
      code = code.substring(0, 2); //only get 1st 2 characters
    }
    if (_isNotSupportedLanguage(code)) {
      l.d('LanguageController:_findLangCode($trackIdx, "$code"): not supported');
      return null;
    }
    l.i('LanguageController:_findLangCode($trackIdx, "$code"): found a supported code');
    return code;
  }

  bool _isNotSupportedLanguage(String language) {
    for (SettingsOption languageOption in languageOptions) {
      if (languageOption.key == language) return false; // language is supported
    }
    return true; // language NOT supported
  }

  /// Updates the language used in the app, instantly changes all text.
  updateLanguage(String newLangKey) async {
    if (_isNotSupportedLanguage(newLangKey)) {
      l.e('LanguageController:updateLanguage: The language key "$newLangKey" is not supported, will call _findLanguage() next');
      newLangKey = _findLanguage();
    }

    try {
      await Get.updateLocale(Locale(newLangKey)); // calls Get.forceAppUpdate()
    } catch (error) {
      l.e('updateLanguage: updateLocale call failed, the language "$newLangKey" is not supported, using default "$defaultLangKey"');
      newLangKey = defaultLangKey;
      await Get.updateLocale(Locale(newLangKey)); // calls Get.forceAppUpdate()
    }

    _initLocaleValues(newLangKey);

    _currLangKey = newLangKey;
    s.wr('language', _currLangKey);
    l.i('updateLanguage: Setting currLangKey=$_currLangKey, isEnNumerals=$_isEnNumerals, isRightToLeftLang=$_isRightToLeftLang');

    // update athan time translations by refreshing active quests UI
    ActiveQuestsController.to.update();

    update(); // notify watchers
  }

  /// Setup special language variables now
  _initLocaleValues(String newLangKey) {
    if (newLangKey == 'ar' || newLangKey == 'en') {
      HijriCalendar.setLocal(newLangKey); // supports ar and en only
    }

    _isRightToLeftLang = _nonLeftToRightLangs[newLangKey] ?? false;
    _isEnNumerals = _nonEnNumeralLangs[newLangKey] == null;
    if (_isEnNumerals) {
      _curNumerals = _enNumerals;
    } else {
      _curNumerals = _nonEnNumeralLangs[newLangKey]!;
    }
    _am = ' ' + 'i.AM'.tr; // tr ok
    _pm = ' ' + 'i.PM'.tr; // tr ok
  }
}
