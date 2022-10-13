import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/onboard/onboard_ui.dart';
import 'package:hapi/tarikh/event/event_c.dart';

/// NOTE ABOUT WHAT'S IN THIS FILE:
/// We put common code across multiple app functionality in this Controller,
///   e.g.:
///     - Orientation control (Portrait/Landscape mode)
///     - L -> Logging
///     - S -> Storage (Persisting variables to disk between app instances)
///     - UI text: Translations, Number Conversions, Formatting, etc.

/// DART POWER/MAGIC: All enums inside the Project will get this functionality!
/// To use, import in same file your Enums live:
///   import 'package:hapi/main_c.dart';
extension GlobalEnumUtil on Enum {
  /// Renames enum to an arabic name with the following rules:
  ///     _a  -> "'" (replaces if enum.name starts with "_a" only)
  ///     _a_ -> "'" (Typically Arabic Ayn Symbol)
  ///     __  -> "-"
  ///     _   -> " "
  String get isim {
    String isim = name;

    // Enum if starts with "_" is private so we make "a_"-> "'":
    if (isim.startsWith('a_')) isim = isim.replaceFirst('a_', "'");

    return isim
        .replaceFirst('_a_', "'")
        .replaceFirst('__', '-')
        .replaceFirst('_', ' ');
  }

  /// Get an "a." tk from an Arabic/Arabee/Transliterated enum name/isim.
  String get tkIsimA => 'a.$isim';

  /// Renames enum to a nice name using the following rules:
  ///     ____ -> " ("
  ///     ___  -> ")"
  ///     __   -> "-"
  ///     _    -> " " (space)
  String get tkNiceName {
    return name
        .replaceFirst('____', ' (')
        .replaceFirst('___', ')')
        .replaceFirst('__', '-')
        .replaceAll('_', ' ');
  }
}

/// Handles Sign In/Out, Screen orientation/rotation
/// TODO Not used as typical controller anywhere, currently doesn't need GetxHapi
class MainC extends GetxHapi {
  static MainC get to => Get.find();

  /// Gives main menu FAB ability to show/hide in an animated way.
  bool _showMainMenuFab = true; // TODO asdf false, hide on splash screen?
  bool initNeeded = true;

  bool isSignedIn = false;
  bool isPortrait = true; // MUST LEAVE TRUE FOR APP TO START
  // bool _isOrientationChanged = false;

  @override
  void onInit() {
    super.onInit();
    // Hide keyboard at app init, in case it was showing before restart
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  bool get isMainMenuFabShowing => _showMainMenuFab;

  showMainMenuFab() {
    if (!_showMainMenuFab) {
      _showMainMenuFab = true;
      MenuC.to.update(); // needed to show FAB (MenuC has FAB logic)
    }
  }

  hideMainMenuFab() {
    if (_showMainMenuFab) {
      _showMainMenuFab = false;
      MenuC.to.update(); // needed to hide FAB (MenuC has FAB logic)
    }
  }

  signIn() {
    isSignedIn = true;

    showMainMenuFab();

    MenuC.to.initAppsFirstPage();
  }

  signOut() {
    isSignedIn = false;
    MenuC.to.hideMenu(); // reset FAB (for sign back in)
    MenuC.to.clearSubPageStack(); // reset FAB (for sign back in)

    showMainMenuFab();

    AuthC.to.signOut(); // Sign out of Auth

    // TODO asdf check onboarding logic
    MenuC.to.navigateToOnboardPage(); // show Onboarding page
  }

  setOrientation(bool isPortrait) {
    // don't proceed with any auto-orientation yet
    if (this.isPortrait && isPortrait) return l.d('Still in portrait');
    if (!this.isPortrait && !isPortrait) return l.d('Still in landscape');

    if (isPortrait) {
      l.i('ORIENTATION: Switched to portrait');
    } else {
      l.i('ORIENTATION: Switched to landscape');
    }

    this.isPortrait = isPortrait;
    // _isOrientationChanged = true;

    if (!OnboardUI.rotatedScreen) {
      OnboardUI.rotatedScreen = true;
      NavPageC.to.updateOnThread1Ms();
    }

    // this is expensive on orientation change but realistically we don't do it
    // much, we optimizing common case of accessing event text often instead.
    if (initNeeded == false) {
      if (isSignedIn) {
        // TODO good enough check, should check events inited?
        EventC.to.reinitAllEventsTexts(); // only call if app init and signed in
      }
    }
    initNeeded = false;

    if (MenuC.to.isAnySubPageShowing()) {
      update(); // notify watchers
    } else {
      // TODO only do this to fix slide menu for now
      MenuC.to.navigateToNavPageResetFAB(MenuC.to.getLastNavPage());
    }
  }

  // /// Used to tell a UI that orientation changed
  // bool get isOrientationChanged {
  //   bool isOrientationChanged = _isOrientationChanged;
  //   _isOrientationChanged = false; // clear if it was set
  //   return isOrientationChanged;
  // }
}

/// Golden Ratio
const GR = 1.618033; // GOLDEN RATIO

/// "l" short for Log, use for all logging in app.
Log l = Log();

/// Log is used to globally write logs. TODO write logs to cloud
class Log {
  /// Current log level (ll).
  static const int ll = llD4;

  /// ll->LOG LEVELS, higher the level the more logs you will see.
  static const int llO0 = 0; // Off     - turn off logging
  static const int llE1 = 1; // Error   - error messages
  static const int llW2 = 2; // Warn    - warning messages
  static const int llI3 = 3; // Info    - informative messages
  static const int llD4 = 4; // Debug   - debug level messages
  static const int llV5 = 5; // Verbose - verbose/spam messages

  /// Use these to not build heavy verbose Strings that won't event print anyway.
  get isVerboseMode => ll > llD4;
  get isNotVerboseMode => ll < llV5;

  /// Prints error (if log level permits) and throws exception.
  E(String msg) {
    if (kDebugMode) {
      if (ll > llO0) debugPrint('H_ERR: $msg');
      throw 'H_ERR: $msg'; // Don't throw error in production, GOOD LUCK!
    }
  }

  /// e->error/failures, w->warn, i->info, d->debug, v->verbose:
  e(String m) => {if (kDebugMode && ll > llO0) debugPrint('H_ERROR!!!: $m')};
  w(String m) => {if (kDebugMode && ll > llE1) debugPrint('H_WARNING!!!: $m')};
  i(String m) => {if (kDebugMode && ll > llW2) debugPrint('H_INF0: $m')};
  d(String m) => {if (kDebugMode && ll > llI3) debugPrint('H_DBUG: $m')};
  v(String m) => {if (kDebugMode && ll > llD4) debugPrint('H_VRBS: $m')};
}

/// "s" short for Storage, use for all Storage access in app.
Storage s = Storage();

/// TODO echo these settings to db?
/// Storage is used to globally read/write to local app storage.
class Storage {
  Storage() {
    // GetStorage key persisted so we always know last uidKey
    _uidKey = box.read('uidKey') ?? 'noLogin'; // no more than 7 chars
  }

  final GetStorage box = GetStorage();

  // TODO asdf not working to save email on sign out/log back in
  String _uidKey = 'noLogin';

  /// Used so _uidKey so we can support multiple user sign in/out user settings
  void setUidKey(String newKey) async {
    if (newKey.length > 5) newKey = newKey.substring(0, 7); // shorten key
    l.d('storage: s.setUIDKey: old="$_uidKey", new="$newKey"');
    await box.write('uidKey', newKey);
    _uidKey = newKey;
  }

  T? rd<T>(String key) {
    // if (_uidKey.isEmpty) {
    //   l.w('WARNING: storage: _uidKey is empty, not reading setting, returning null');
    //   return null;
    // }
    key = '${_uidKey}_$key';
    dynamic rv = box.read(key);
    l.d('storage: s.rd($key)="$rv"');
    return rv;
  }

  Future<void> wr(String key, dynamic value) async {
    // if (_uidKey.isEmpty) {
    //   l.w('WARNING: storage: _uidKey is empty, not writing setting');
    // }
    key = '${_uidKey}_$key';
    l.d('storage: s.wr($key)="$value"');
    return box.write(key, value);
  }
}

/// TS = TextStyle - helper class to make init code shorter
class TS extends TextStyle {
  const TS(
    Color color, {
    FontWeight fontWeight = FontWeight.normal,
    String fontFamily = 'Roboto',
  }) : super(
          color: color,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          decoration: TextDecoration.none, // makes yellow underlines go away
        );
}

/// Commonly used TextStyles: tsB (Bold), tsN (Normal), tsRe (Red):
// TODO ts and tsB don't work on light/dark change:
const TS tsNB = TS(AppThemes.ldTextColor, fontWeight: FontWeight.bold);
const TS tsN = TS(AppThemes.ldTextColor);
const TS tsRe = TS(Colors.red);
const TS tsGr = TS(Colors.green);
TS get ts => Get.isDarkMode ? tsWi : _tsBl; // TODO make constant
TS get tsB => Get.isDarkMode ? _tsWiB : _tsBlB;
const TS tsWi = TS(Colors.white);
const TS _tsBl = TS(Colors.black);
const TS _tsWiB = TS(Colors.white, fontWeight: FontWeight.bold);
const TS _tsBlB = TS(Colors.black, fontWeight: FontWeight.bold);

// TODO change to TK - Translate tk, and TV - Translate tvue
/// "T"/"t" short for Text, use to translate or fit text in UI.
///
/// NOTE 1: When wrapped in Center this broke Swiper UI
/// NOTE 2: Looks like height is not taken into account unless you wrap caller
///         in a Center() too. So if you want to constraint on height do that.
class T extends StatelessWidget {
  const T(
    this.tkOrVal,
    this.style, {
    this.alignment = Alignment.center,
    this.w,
    this.h = 25,
    this.boxFit = BoxFit.contain, // BoxFit.fitHeight, BoxFit.fitWidth
    this.tv = false,
  });
  final String tkOrVal;
  final TextStyle? style;
  final Alignment alignment;
  final double? w;
  final double h;
  final BoxFit boxFit;
  final bool tv; // set to true if tkOrVal comes in already translated

  @override
  Widget build(BuildContext context) {
    double? width = w;
    width ??= wm(context); // if not specified take up most of the screen width
    //width -= 10; // text always designed to take up full width, add 10% padding

    return SizedBox(
      width: width,
      height: h,
      child: FittedBox(
        fit: boxFit,
        alignment: alignment,
        child: Text(tv ? tkOrVal : a(tkOrVal), style: style),
      ),
    );
  }
}

/// Holds "a" user data in a map where:
///   - The key is transliteration of "a.<transliteration>" which value is:
///      1. null   - User has learned word and wants transliteration
///      2. String - User has learned word and wants Arabic alphabet
Map<String, String?> aMap = {
  'Saat': null,
  'Daqayiq': 'الدقائق',
  'Thawani': null,
};

/// a = Arabic Translation/Transliteration: Uses "a.<Arabic Transliteration>"
/// convention keys to translate, transliterate or show Arabic text for the
/// given key. This depends on if the user has learned the key and also turned
/// the transliterate or show arabic script feature on.
///
/// Ideally we want to see the user learn Arabic through these steps:
///    Native Lang Word -> Transliterated Arabic -> Arabic Alphabet
///
/// So eventually their app will look of a mix of their native language and
/// Arabic script.
String a(String tk) {
  if (!tk.startsWith('a.')) return tk.tr; // no "a" key, tr and return
  // if (kDebugMode && !tk.startsWith('a.')) {
  //   return l.E('a(): must pass in "a.", key got "$tk"');
  // }
  //
  // List<String> keySplit = tk.split('.');
  // if (keySplit.length == 1) return tk.tr;

  String transliteration = tk.split('.')[1]; // transliteration is aMap's key
  bool containsKey = aMap.containsKey(transliteration);
  if (containsKey) {
    String? rv = aMap[transliteration];
    if (rv == null) return transliteration; // user wants transliteration only
    return rv; // user wants Arabic alphabet
  }
  return tk.tr; // not found in aMap, translate to en/tr/etc.
}

/// at = Arabic Translate/Template. Use "at." template tk to insert other
///   tks (Can also be tagged like "p." or "a." if need to a() those too),
///   e.g.:
///     From this tk template, replace {x}'s:
///       'Time until "{0}" ends and "{1}" begins'
///     With tksToInsert list's values [zc.currZ.tk, zc.nextZ.tk], so:
///       'Time until "Dhuhr" ends and "Asr" begins'
///
/// Note: tksToInsert should have only "a." tks passed in.
String at(String tkTemplate, List<String> tksToInsert) {
  String rv = a(tkTemplate); // does normal tr or "a." a() tr
  // String rv =
  //     tkTemplate.startsWith('a.') ? a(tkTemplate) : tkTemplate.tr;

  // loop through translated text and add arabic/transliteration text:
  for (int idx = 0; idx < tksToInsert.length; idx++) {
    rv = rv.replaceFirst('{$idx}', a(tksToInsert[idx]));
  }

  return rv;
}

showSnackBar(
  String tkTitle,
  String tkMsg, {
  int durationSec = 3,
  bool isRed = false,
}) {
  Color? colorText = Get.theme.snackBarTheme.actionTextColor;
  if (isRed) colorText = Colors.red;

  // only allow one snackbar to show at a time
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

  Get.snackbar(
    tkTitle.tr,
    tkMsg.tr,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: durationSec),
    backgroundColor: Get.theme.snackBarTheme.backgroundColor,
    colorText: colorText,
    isDismissible: !isRed, // can't swipe away away error/red messages
  );
}

/// Common utility/helper functions so we don't have to type so much:
///   wm - width most (of screen) - screen width minus some fixed margin
///   w  - width (of screen)
///   h  - height (of screen)
///   cb - theme color background
///   cf - theme color foreground
///   ct - theme color text
double wm(BuildContext context) => MediaQuery.of(context).size.width - 40;
double w(BuildContext context) => MediaQuery.of(context).size.width;
double h(BuildContext context) => MediaQuery.of(context).size.height;
Color cb(BuildContext context) => Theme.of(context).backgroundColor;
Color cf(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
Color ct(BuildContext context) => Theme.of(context).textTheme.headline6!.color!;

/// cni = Convert Number Integer, int to other numeral system string, if needed.
String cni(int input) {
  if (LangC.to.isEnNumerals) return input.toString(); // no need

  // single digit, easy conversion
  if (input < 10 && input > -1) return LangC.to.curNumerals[input];

  // if got here, then there is more than one digit entered so call cns()
  return cns(input.toString());
}

/// cns = Convert Number String, Replaces all digits to another number system,
/// like Arabic and Farsi.  Only done, if current language needs it.
String cns(String input) {
  if (LangC.to.isEnNumerals) return input; // no need to convert

  // replace all found digits in the input string
  List<String> nonEnNumerals = LangC.to.curNumerals;
  for (int idx = 0; idx < 10; idx++) {
    input = input.replaceAll(idx.toString(), nonEnNumerals[idx]);
  }

  return input;
}
