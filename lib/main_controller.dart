import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';

class MainController extends GetxHapi {
  static MainController get to => Get.find();

  bool isAppInitDone = false;

  bool isPortrait = true; // MUST LEAVE TRUE FOR APP TO START

  @override
  void onInit() {
    super.onInit();
    // Hide keyboard at app init, in case it was showing before restart
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void setAppInitDone() {
    // Splash animations done, now allow screen rotations for the rest of time:
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Disable all OS overlay bars (e.g. top status and bottom navigation bar):
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    isAppInitDone = true;
  }

  void setOrientation(bool isPortrait) {
    // don't proceed with any auto-orientation yet
    if (!isAppInitDone) {
      l.w('ORIENTATION: App is not initialized yet.');
      return;
    }

    if (this.isPortrait && isPortrait) {
      l.d('ORIENTATION: Still in portrait');
      return;
    }

    // if still in landscape mode return
    if (!this.isPortrait && !isPortrait) {
      l.d('ORIENTATION: Still in landscape');
      return;
    }

    if (isPortrait) {
      l.i('ORIENTATION: Switched to portrait');
    } else {
      l.i('ORIENTATION: Switched to landscape');
    }

    this.isPortrait = isPortrait;

    if (MenuController.to.isAnySubPageShowing()) {
      update(); // notify watchers
    } else {
      // TODO only do this to fix slide menu for now
      if (MenuController.to.isMenuShowing) {
        MenuController.to.hideMenu();
      }
      MenuController.to.navigateToNavPage(MenuController.to.getLastNavPage());
    }
  }
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

  /// Prints error (if log level permits) and throws exception.
  E(String msg) {
    if (ll > llO0) debugPrint('H_ERR: $msg');
    throw 'H_ERR: $msg';
  }

  /// e->error/failures, w->warn, i->info, d->debug, v->verbose:
  e(String msg) => {if (ll > llO0) debugPrint('H_ERR: $msg')};
  w(String msg) => {if (ll > llE1) debugPrint('H_WRN: $msg')};
  i(String msg) => {if (ll > llW2) debugPrint('H_INF: $msg')};
  d(String msg) => {if (ll > llI3) debugPrint('H_DBG: $msg')};
  v(String msg) => {if (ll > llD4) debugPrint('H_VRB: $msg')};
}

/// "s" short for Storage, use for all Storage access in app.
Storage s = Storage();

/// TODO echo these settings to db?
/// Storage is used to globally read/write to local app storage.
class Storage {
  Storage() {
    // GetStorage key persisted so we always know last uidKey
    _uidKey = box.read('uidKey') ?? '';
  }

  final GetStorage box = GetStorage();
  String _uidKey = '';

  /// Used so _uidKey so we can support multiple user sign in/out user settings
  void setUidKey(String newKey) async {
    if (newKey.length > 5) {
      newKey = newKey.substring(0, 5); // don't need such a long key
    }
    l.d('storage: s.setUIDKey: old="$_uidKey", new="$newKey"');
    await box.write('uidKey', newKey);
    _uidKey = newKey;
  }

  T? rd<T>(String key) {
    if (_uidKey.isEmpty) {
      l.w('WARNING: storage: _uidKey is empty, not reading setting, returning null');
      return null;
    }
    key = '${_uidKey}_$key';
    dynamic rv = box.read(key);
    l.d('storage: s.rd($key)="$rv"');
    return rv;
  }

  Future<void> wr(String key, dynamic value) async {
    if (_uidKey.isEmpty) {
      l.w('WARNING: storage: _uidKey is empty, not writing setting');
    }
    key = '${_uidKey}_$key';
    l.d('storage: s.wr($key)="$value"');
    return box.write(key, value);
  }
}

/// "T"/"t" short for Text, use to translate or fit text in UI.
class T extends StatelessWidget {
  const T(
    this.trKey,
    this.style, {
    this.alignment = Alignment.center,
    this.w = 80,
    this.h = 21, // Slightly smaller than salah header, and fits Tahajjud nicely
    this.boxFit = BoxFit.contain, // BoxFit.fitHeight, BoxFit.fitWidth
  });

  final String trKey;
  final TextStyle? style;
  final Alignment alignment;
  final double w;
  final double h;
  final BoxFit boxFit;

  @override
  Widget build(BuildContext context) {
    // NOTE: wrap with center to prevent expand into container broke SWIPER UI
    return SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: boxFit,
        alignment: alignment, // use to align text,
        child: Text(trKey.tr, style: style), // NOTE: Translation done here
      ),
    );
  }
}

/// TS = TextStyle - helper class to make init code shorter
class TS extends TextStyle {
  const TS(
    Color color, {
    FontWeight fontWeight = FontWeight.normal,
  }) : super(color: color, fontWeight: fontWeight);
}

showSnackBar(
  String trKeyTitle,
  String trKeyMsg, {
  int durationSec = 3,
  bool isError = false,
}) {
  Color? colorText = Get.theme.snackBarTheme.actionTextColor;
  if (isError) colorText = Colors.red;
  Get.snackbar(
    trKeyTitle.tr,
    trKeyMsg.tr,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: durationSec),
    backgroundColor: Get.theme.snackBarTheme.backgroundColor,
    colorText: colorText,
  );
}

/// Common utility/helper functions so we don't have to type so much:
///   wm - width (of screen) minus some margin when we want long text
///   w  - width (of screen)
///   h  - height (of screen)
///   cb - theme color background
///   cs - theme color scaffold
///   ct - theme color text
double wm(BuildContext context) => MediaQuery.of(context).size.width - 40;
double w(BuildContext context) => MediaQuery.of(context).size.width;
double h(BuildContext context) => MediaQuery.of(context).size.height;
Color cb(BuildContext context) => Theme.of(context).backgroundColor;
Color cs(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
Color ct(BuildContext context) => Theme.of(context).textTheme.headline6!.color!;

/// cni = Convert Number Integer, int to other numeral system string, if needed.
String cni(int input) {
  if (LanguageController.to.isEnNumerals) return input.toString(); // no need

  // single digit, easy conversion
  if (input < 10 && input > -1) return LanguageController.to.curNumerals[input];

  // if got here, then there is more than one digit entered so call cns()
  return cns(input.toString());
}

/// cns = Convert Number String, Replaces all digits to another number system,
/// like Arabic and Farsi.  Only done, if current language needs it.
String cns(String input) {
  if (LanguageController.to.isEnNumerals) return input; // no need to convert

  // replace all found digits in the input string
  List<String> nonEnNumerals = LanguageController.to.curNumerals;
  for (int idx = 0; idx < 10; idx++) {
    input = input.replaceAll(idx.toString(), nonEnNumerals[idx]);
  }

  return input;
}
