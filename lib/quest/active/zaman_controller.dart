import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:timezone/timezone.dart' show Location, TZDateTime;

/// Controls Islamic Times Of Day, e.g. Fajr, Duha, Sunset/Maghrib, etc. that
/// many pages rely on for the current time.
class ZamanController extends GetxHapi {
  static ZamanController get to => Get.find();

  Z _currZ = Z.Dhuhr;
  Z _nextZ = Z.Asr_Later;
  Z get currZ => _currZ;
  Z get nextZ => _nextZ;

  /// Next zaman Timestamp used to countdown to and update the UI accordingly.
  DateTime _nextZTime = DUMMY_TIME;
  String _timeToNextZaman = '-';
  String get timeToNextZaman => _timeToNextZaman;

  int _secsSinceFajr = 0;
  int get secsSinceFajr => _secsSinceFajr;

  bool forceSalahRecalculation = false;

  Athan? _athan;
  Athan? get athan => _athan;

  @override
  void onInit() {
    super.onInit();
  }

  bool get isInitialized => _athan != null;

  CalculationParams _getCalculationParams() {
    var calcMethod =
        CalcMethod.values[ActiveQuestsController.to.salahCalcMethod];

    var madhab = Madhab.Hanafi;
    if (!ActiveQuestsController.to.salahAsrSafe) madhab = Madhab.Shafi;

    int karahatSunRisingSecs = 40 * 60;
    int karahatSunIstiwaSecs = 30 * 60;
    int karahatSunSettingSecs = 40 * 60;
    if (!ActiveQuestsController.to.salahKarahatSafe) {
      karahatSunRisingSecs = 20 * 60;
      karahatSunIstiwaSecs = 15 * 60;
      karahatSunSettingSecs = 20 * 60;
    }

    // TODO give user a way to change:
    //   HighLatitudeRule, SalahAdjust
    return CalculationParams(
      calcMethod.params,
      madhab,
      karahatSunRisingSecs,
      karahatSunIstiwaSecs,
      karahatSunSettingSecs,
      HighLatitudeRule.MiddleOfTheNight,
    );
  }

  updateZaman() async {
    Athan athan = Athan(
      _getCalculationParams(),
      TimeController.to.currDayDate,
      LocationController.to.lastKnownCord,
      TimeController.to.tzLoc,
      ActiveQuestsController.to.showSecPrecision,
    );

    DateTime now = await TimeController.to.now();
    Z currZCheck = athan.getCurrZaman(now);
    l.d('currZCheck: $currZCheck');
    if (currZCheck == Z.Fajr_Tomorrow) {
      l.d('ZamanController: _initLocation: New day detected.');
      // Reset day, Fajr Tom. is day after currDay so safe to do next actions:
      await TimeController.to.updateTime(true);
      ActiveQuestsAjrController.to.clearAllQuests();
      updateZaman(); // on next call no longer: currZ == Z.Fajr_Tomorrow
      return;
    }
    _currZ = currZCheck; // now safe to do this.

    _nextZ = athan.getNextZaman(now);
    l.d('_nextZ: $_nextZ');
    _nextZTime = athan.getZamanTime(_nextZ)[0] as DateTime;
    l.d('_nextZTime: $_nextZTime');

    // For next prayer/day, set any missed quests and do other quest setup:
    ActiveQuestsAjrController.to.initCurrQuest();

    // Now all init is done, set athan value (needed for init to prevent NPE)
    _athan = athan;

    update(); // update UI with above changes (needed at app init)

    // We need to update the ActiveQuestsController here after athan is updated
    // Was a bug where when forceSalahRecalculation = true was set in
    // ActiveQuestsController, it's update() was called before athan updated.
    ActiveQuestsController.to.update();

    _startNextZamanCountdownTimer();
  }

  _startNextZamanCountdownTimer() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      DateTime now = await TimeController.to.now();
      Duration timeToNextZaman = _nextZTime.difference(
        TZDateTime.from(now, TimeController.to.tzLoc),
      );

      _secsSinceFajr = now
          .difference(TZDateTime.from(_athan!.fajr, TimeController.to.tzLoc))
          .inSeconds;

      // if we hit the end of a timer (or forced), recalculate zaman times:
      if (forceSalahRecalculation || timeToNextZaman.inSeconds <= 0) {
        l.d('This zaman is over, going to next zaman: '
            '${timeToNextZaman.inSeconds} secs left');
        forceSalahRecalculation = false;
        updateZaman(); // does eventually call startNextZamanCountdownTimer();
        return; // quits this while loop, wills tart again in initLocation()
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // print once a minute to show thread is alive
          l.i('Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        }
        // this is displayed on UI:
        _timeToNextZaman = _printHourMinuteSeconds(timeToNextZaman);
        update();
      }
    }
  }

  // TODO can optimize this
  String _printHourMinuteSeconds(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  }

  /// See if given salah row is currently active/current Z time.
  bool isSalahRowActive(Z z) {
    List<Z> zs;

    switch (z) {
      case Z.Fajr:
        zs = [Z.Fajr, Z.Fajr_Tomorrow];
        break;
      case Z.Duha:
        zs = [Z.Karahat_Morning_Adhkar, Z.Ishraq, Z.Duha, Z.Karahat_Istiwa];
        break;
      case Z.Dhuhr:
        zs = [Z.Dhuhr];
        break;
      case Z.Asr_Later:
      case Z.Asr_Earlier:
        zs = [Z.Asr_Earlier, Z.Asr_Later, Z.Karahat_Evening_Adhkar];
        break;
      case Z.Maghrib:
        zs = [Z.Maghrib];
        break;
      case Z.Isha:
        zs = [Z.Isha];
        break;
      case Z.Layl__3:
      case Z.Layl__2:
        zs = [Z.Isha, Z.Layl__2, Z.Layl__3]; // Isha still valid for layl
        break;
      default:
        var e = 'Invalid Zaman "$z" given when in isSalahRowActive called';
        l.e(e);
        throw e;
    }

    for (Z z in zs) {
      if (z == _currZ) return true; // time of day is active
    }

    return false; // gets here from isNextSalahRowActive search
  }

  /// See if next salah row of given Z, will be the next active/curr Z time.
  bool isNextSalahRowActive(Z z) {
    switch (z) {
      case Z.Fajr:
        return isSalahRowActive(Z.Duha);
      case Z.Duha:
        return isSalahRowActive(Z.Dhuhr);
      case Z.Dhuhr:
        return isSalahRowActive(Z.Asr_Later);
      case Z.Asr_Later:
      case Z.Asr_Earlier:
        return isSalahRowActive(Z.Maghrib);
      case Z.Maghrib:
        return isSalahRowActive(Z.Isha);
      case Z.Isha:
        return isSalahRowActive(Z.Layl__3);
      case Z.Layl__3:
      case Z.Layl__2:
        return isSalahRowActive(Z.Layl__3);
      default:
        var e = 'Invalid Zaman "$z" given when in isNextSalahRowActive called';
        l.e(e);
        throw e;
    }
  }
}
