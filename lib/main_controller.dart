import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/menu/menu_controller.dart';

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

/// "l" short for Log, use for all logging in app.
Log l = Log();

/// Log is used to globally write logs. TODO write logs to cloud
class Log {
  /// ll->LOG LEVELS, higher the level the more logs you will see.
  static const int llO0 = 0; // Off     - turn off logging
  static const int llI1 = 1; // Info    - informative messages
  static const int llW2 = 2; // Warn    - warning messages
  static const int llE3 = 3; // Error   - error messages
  static const int llD4 = 4; // Debug   - debug level messages
  static const int llV5 = 5; // Verbose - verbose/spam messages

  /// Current log level. Add 1 as a minor optimization (use > instead of >=).
  static const int ll = 1 + llV5;

  /// i->info, w->warn, e->error/failures, d->debug, v->verbose:
  i(String msg) => {if (ll > llI1) debugPrint('HAPI_INFO: $msg')};
  w(String msg) => {if (ll > llW2) debugPrint('HAPI_WARN: $msg')};
  e(String msg) => {if (ll > llE3) debugPrint('HAPI_ERRR: $msg')};
  d(String msg) => {if (ll > llD4) debugPrint('HAPI_DBUG: $msg')};
  v(String msg) => {if (ll > llV5) debugPrint('HAPI_VRBS: $msg')};
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
    this.t,
    this.style, {
    this.alignment = Alignment.center,
    this.width = 80,
    this.height = 30,
  });

  final String t;
  final TextStyle style;
  final Alignment alignment;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain, // BoxFit.fitHeight,
        alignment: alignment, // use to align text,
        child: Text(
          t.tr,
          style: style,
          //textAlign: textAlign,
        ),
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
