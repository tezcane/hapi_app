import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/notification_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:timezone/timezone.dart' show TZDateTime;

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

  bool get isInitialized => _athan != null;

  CalculationParams _getCalculationParams() {
    var calcMethod =
        CalcMethod.values[ActiveQuestsController.to.salahCalcMethod];

    var madhab = Madhab.Hanafi;
    if (!ActiveQuestsController.to.salahAsrSafe) madhab = Madhab.Shafi;

    int karahatSunRisingSecs = 25 * 60;
    int karahatSunIstiwaSecs = 15 * 60;
    int karahatSunSettingSecs = 25 * 60;
    if (!ActiveQuestsController.to.salahKarahatSafe) {
      karahatSunRisingSecs = 20 * 60;
      karahatSunIstiwaSecs = 10 * 60;
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

  Athan generateNewAthan(DateTime day) {
    return Athan(
      _getCalculationParams(),
      day,
      LocationController.to.lastKnownCord,
      TimeController.to.tzLoc,
      ActiveQuestsController.to.showSecPrecision,
    );
  }

  /// Does init for app items then calls itself again on more init needed or
  /// startNextZamanCountdownTimer() to start next countdown timer.
  updateZaman() async {
    Athan athan;

    if (forceSalahRecalculation) {
      l.d('ZamanController:updateZaman: forceSalahRecalculation was called.');
      athan = generateNewAthan(TimeController.to.currDayDate);
    } else {
      if (isInitialized) {
        athan = _athan!; // don't calculate athan each time
      } else {
        athan = generateNewAthan(TimeController.to.currDayDate); // first init
      }
    }

    DateTime now = await TimeController.to.now();
    Z currZ = athan.getCurrZaman(now);
    l.d('ZamanController:updateZaman: starting, currZ=$currZ, now=$now');

    // check if we are still on the same day
    if (currZ == Z.Fajr_Tomorrow) {
      await _handleNewDaySetup();
      return;
    }

    // Safe to now set/flush missed quests and do other quest setup:
    await ActiveQuestsAjrController.to.initCurrQuest(currZ, !isInitialized);

    _currZ = currZ; // now safe as currZ can't be Z.Fajr_Tomorrow.
    _nextZ = athan.getNextZaman(now);
    l.d('ZamanController:updateZaman: _nextZ: $_nextZ');
    _nextZTime = athan.getZamanTime(_nextZ)[0] as DateTime;
    l.d('ZamanController:updateZaman: _nextZTime: $_nextZTime');

    // Now all init is done, set athan value (needed for init to prevent NPE)
    _athan = athan;

    if (_currZ == Z.Maghrib || forceSalahRecalculation || !isInitialized) {
      await TimeController.to.updateDaysOfWeek(); // sunset = new hijri day
    }

    if (forceSalahRecalculation) {
      forceSalahRecalculation = false;
      NotificationController.to.resetNotifications(); // _athan updated so reset
    }

    // Always refresh ActiveQuestsController as _currZ is updated and multiple
    // UI's watch for this (e.g. ActiveQuestsUI and ActiveQuestActionsUI.
    // Must update the ActiveQuestsController here after athan is updated.
    // Fixes bug where forceSalahRecalculation = true set in
    // ActiveQuestsController, it's update() was called before athan updated.
    ActiveQuestsController.to.update(); // even needed at app init to show UI

    _startNextZamanCountdownTimer();
  }

  /// Loop counts down until zaman is over or forceSalahRecalculation called
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

      if (forceSalahRecalculation) {
        l.d('ZamanController:_startNextZamanCountdownTimer: forceSalahRecalculation was called.');
        updateZaman();
        return; // quits while loop, starts again in updateZaman()
      } else if (timeToNextZaman.inSeconds <= 0) {
        l.d('ZamanController:_startNextZamanCountdownTimer: This zaman $currZ is over, going to next zaman $nextZ.');
        // just in case, give a little time for nextZ to come in.
        await Future.delayed(const Duration(milliseconds: 16));
        updateZaman();
        return; // quits while loop, starts again in updateZaman()
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // heartbeat prints once a minute to show thread is alive
          l.i('ZamanController:_startNextZamanCountdownTimer: Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        }
        // this is displayed on UI:
        _timeToNextZaman = _printHourMinuteSeconds(timeToNextZaman);
        update(); // only time ZamanController is updated
      }
    }
  }

  _handleNewDaySetup() async {
    l.d('ZamanController:_handleNewDaySetup: New day is being setup.');
    if (isInitialized) {
      // flush any missed quests
      await ActiveQuestsAjrController.to.initCurrQuest(Z.Fajr_Tomorrow, true);
    }

    await TimeController.to.updateTime();
    await TimeController.to.updateCurrDay();

    // Load or init this next day quests
    await ActiveQuestsAjrController.to.initCurrQuest(Z.Fajr, true);

    forceSalahRecalculation = true; // time to update _athan

    // now, currZ won't equal Z.Fajr_Tomorrow as currDay updated
    updateZaman();
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
      case Z.Layl__3:
      case Z.Layl__2:
        zs = [Z.Isha, Z.Layl__2, Z.Layl__3]; // Isha/Layl are anytime at night
        break;
      default:
        return l.E('Invalid Zaman "$z" given when in isSalahRowActive called');
    }

    for (Z z1 in zs) {
      if (z1 == _currZ) {
        bool isActive = true;

        // Special case for isha/layl as they share same time frame
        if (z == Z.Isha) {
          isActive &= !ActiveQuestsAjrController.to.isIshaIbadahComplete;
        } else if (z == Z.Layl__2 || z == Z.Layl__3) {
          isActive &= ActiveQuestsAjrController.to.isIshaIbadahComplete;
        }

        return isActive; // time of day is active if true
      }
    }

    return false;
  }

  // /// See if next salah row of given Z, will be the next active/curr Z time.
  // bool isNextSalahRowActive(Z z) {
  //   switch (z) {
  //     case Z.Fajr:
  //       return isSalahRowActive(Z.Duha);
  //     case Z.Duha:
  //       return isSalahRowActive(Z.Dhuhr);
  //     case Z.Dhuhr:
  //       return isSalahRowActive(Z.Asr_Later);
  //     case Z.Asr_Later:
  //     case Z.Asr_Earlier:
  //       return isSalahRowActive(Z.Maghrib);
  //     case Z.Maghrib:
  //       return isSalahRowActive(Z.Isha);
  //     case Z.Isha:
  //       return isSalahRowActive(Z.Layl__3);
  //     case Z.Layl__3:
  //     case Z.Layl__2:
  //       return isSalahRowActive(Z.Layl__3);
  //     default:
  //       var e = 'Invalid Zaman "$z" given when in isNextSalahRowActive called';
  //       l.e(e);
  //       throw e;
  //   }
  // }
}
