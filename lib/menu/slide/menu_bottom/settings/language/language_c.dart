import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_option.dart';
import 'package:hapi/quest/active/active_quests_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_c.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

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
  SettingsOption('en', 'English - إنجليزي'), // English
  SettingsOption('fr', 'French - Français'), // French
  SettingsOption('de', 'German - Deutsch'), // German
  SettingsOption('gu', 'Gujarati - ગુજરાત'), // Gujarati
//SettingsOption('he', 'Hebrew - '), // Hebrew TODO
  SettingsOption('hi', 'Hindi - हिन्दी'), // Hindi-Devanagari
  SettingsOption('id', 'Indonesian - Bahasa Indonesia'), // Indonesian
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
class LanguageC extends GetxHapi {
  static LanguageC get to => Get.find();

  static NumberFormat numCompactFormatter = NumberFormat.compact(locale: 'en');

  final String defaultLangKey = 'en';

  /// Always a 2 character language key, e.g. "ar", "en", etc.
  String currLangKey = '';

  /// Holds all a.json Arabic "transileration"->"Arabic" variables that the app
  /// uses to teach Arabic to the user.
  late final Map<String, String> aMap;

  final Map<String, bool> _arabicScriptLangs = {
    'ar': true, // Arabic
    'ps': true, // Pashto
    'fa': true, // Persian Numerals
    'ur': true, // Urdu
  };

  // TODO more right to left languages: Azeri, Dhivehi/Maldivian, Hebrew, Kurdish (Sorani)
  final Map<String, bool> _nonLeftToRightLangs = {
    'ar': true, // Arabic
    'ps': true, // Pashto
    'fa': true, // Persian Numerals
    'ur': true, // Urdu
    'he': true, // Hebrew
  };
  bool _isRightToLeftLang = false;
  bool get isRTL => _isRightToLeftLang;
  bool get isLTR => !_isRightToLeftLang;

  /// Arabic and other RTL language Alignment values are opposite to LTR
  /// languages so we make it easier by using these utility functions. So just
  /// use the naming conventions for left/right of LTR langs her and by doing so
  /// your RTL langs will also get the right Alignment() values.
  Alignment get centerLeft =>
      _isRightToLeftLang ? Alignment.centerRight : Alignment.centerLeft;
  Alignment get centerRight =>
      _isRightToLeftLang ? Alignment.centerLeft : Alignment.centerRight;
  MainAxisAlignment get axisStart =>
      _isRightToLeftLang ? MainAxisAlignment.end : MainAxisAlignment.start;
  MainAxisAlignment get axisEnd =>
      _isRightToLeftLang ? MainAxisAlignment.start : MainAxisAlignment.end;

  m.TextDirection get textDirection =>
      isLTR ? m.TextDirection.ltr : m.TextDirection.rtl;

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

  bool initNeeded = true;

  @override
  void onInit() async {
    super.onInit();
    aMap = await _getTrMap('', 'a');
    await updateLanguage(_findLanguage());
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
      currentLanguage ??= _findLangCode(4, deviceLocal.scriptCode);
      currentLanguage ??= _findLangCode(5, deviceLocal.countryCode);
      currentLanguage ??= _findLangCode(6, deviceLocal.toString());
    }

    if (currentLanguage == null) {
      l.e('_findLanguage: Could not find device language, using default "$defaultLangKey"');
      currentLanguage = defaultLangKey;
    }

    return currentLanguage;
  }

  /// Based on code input, we search for the first match of a language key.
  String? _findLangCode(int trackIdx, String? code) {
    if (code == null) {
      l.d('_findLanguage($trackIdx, "$code") was null');
      return null;
    }
    code = code.toLowerCase(); // our language key tags are all lowercase
    if (code.length < 2) {
      l.d('_findLanguage($trackIdx, "$code") code length < 2 characters.');
      return null;
    }
    if (code.length > 2) {
      l.d('_findLanguage($trackIdx, "$code") code length > 2 characters, shortening it.');
      code = code.substring(0, 2); //only get 1st 2 characters
    }
    if (_isNotSupportedLanguage(code)) {
      l.d('_findLanguage($trackIdx, "$code"): not supported');
      return null;
    }
    l.i('_findLanguage($trackIdx, "$code"): found a supported code');
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
      l.e('updateLanguage: The language key "$newLangKey" is not supported, will call _findLanguage() next');
      newLangKey = _findLanguage();
    }

    try {
      await _clearOldAndLoadNewLangFile(newLangKey);
      await Get.updateLocale(Locale(newLangKey)); // calls Get.forceAppUpdate()
    } catch (error) {
      l.e('updateLanguage: updateLocale call failed, the language "$newLangKey" is not supported, using default "$defaultLangKey"');
      newLangKey = defaultLangKey;
      _clearOldAndLoadNewLangFile(newLangKey);
      await Get.updateLocale(Locale(newLangKey)); // calls Get.forceAppUpdate()
    }

    _initLocaleValues(newLangKey);

    currLangKey = newLangKey;
    s.wr('language', currLangKey);
    l.i('updateLanguage: Setting currLangKey=$currLangKey, isEnNumerals=$_isEnNumerals, isRightToLeftLang=$_isRightToLeftLang');

    // update athan time translations by refreshing active quests UI
    ActiveQuestsC.to.update();

    update(); // notify watchers
  }

  /// Setup special language variables now
  _initLocaleValues(String newLangKey) {
    _arabicScriptLangs[newLangKey] ?? false
        ? HijriCalendar.setLocal('ar') // supports ar or en only
        : HijriCalendar.setLocal('en'); // switch out Arabic script, if was set

    try {
      numCompactFormatter = NumberFormat.compact(locale: newLangKey);
    } catch (e) {
      // TODO improve this catch (e)?
      l.e('$newLangKey is not supported by NumberFormat, default to use "en"');
      numCompactFormatter = NumberFormat.compact(locale: 'en');
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

    TimeC.to.updateDaysOfWeek(); // needed to convert SunRing dates

    if (initNeeded == false) {
      // call only if user changes lang, not at init
      EventC.to.reinitAllEventsTexts();
    }
    initNeeded = false;
  }

  /// Get translation map.
  Future<Map<String, String>> _getTrMap(String path, String langKey) async {
    final String jsonData =
        await rootBundle.loadString('assets/i18n/$path$langKey.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    return Map<String, String>.from(jsonMap);
  }

  /// Must call before Get.updateLocale() or translation it's janky
  _clearOldAndLoadNewLangFile(String newLangKey) async {
    final Map<String, String> trMap = await _getTrMap('', newLangKey);
    Get.clearTranslations();
    Get.addTranslations({newLangKey: trMap});
  }

  /// Load translations from disk to save memory. The trVal is returned from the
  /// currLangKey lookup, e.g. if Timeline Event calls this and lang is Turkish
  /// tarikh_articles/tr.json will be parsed and returned.
  Future<String> trValArticle(EVENT_TYPE eventType, String trKey) async {
    String trFilePath;
    String trKeyLeadingTag;
    if (eventType == EVENT_TYPE.Relic) {
      trFilePath = 'relic/anbiya';
      trKeyLeadingTag = 'pq.';
      return Future.value('i.Coming Soon'); // TODO asdf
    } else {
      trFilePath = 'tarikh_articles/';
      trKeyLeadingTag = 't.';
    }

    trKey = trKey.replaceFirst('i.', trKeyLeadingTag);
    if (!trKey.startsWith(trKeyLeadingTag)) {
      trKey = trKey.replaceFirst('a.', trKeyLeadingTag);
    }

    return (await _getTrMap(trFilePath, currLangKey))[trKey]!;
  }

  /// Give "a.<transliteration> and get Arabic script translation back
  String ar(String trKey) => aMap[trKey]!;
}
