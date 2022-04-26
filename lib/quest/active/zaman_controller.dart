import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/notification_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/services/db.dart';
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
  updateZaman(bool initUpdate) async {
    Athan athan;

    if (forceSalahRecalculation) {
      l.d('ZamanController:updateZaman: forceSalahRecalculation was called.');
      athan = generateNewAthan(TimeController.to.currDayDate);
    } else {
      if (_athan != null) {
        athan = _athan!; // already exists and don't need to reinit
      } else {
        athan = generateNewAthan(TimeController.to.currDayDate); // first init
      }
    }

    DateTime now = await TimeController.to.now();
    Z currZCheck = athan.getCurrZaman(now);
    l.d('ZamanController:updateZaman: currZCheck=$currZCheck');

    // For next prayer/day, set any missed quests and do other quest setup:
    await ActiveQuestsAjrController.to.initCurrQuest(currZCheck, initUpdate);

    // check if we are still on the same day
    if (currZCheck == Z.Fajr_Tomorrow) {
      await _handleNewDaySetup();
      return;
    }

    _currZ = currZCheck; // now safe as currZ can't be Z.Fajr_Tomorrow.
    _nextZ = athan.getNextZaman(now);
    l.d('ZamanController:updateZaman: _nextZ: $_nextZ');
    _nextZTime = athan.getZamanTime(_nextZ)[0] as DateTime;
    l.d('ZamanController:updateZaman: _nextZTime: $_nextZTime');

    // Now all init is done, set athan value (needed for init to prevent NPE)
    _athan = athan;

    if (forceSalahRecalculation) {
      forceSalahRecalculation = false;

      // Must update notification after _athan is force changed
      NotificationController.to.resetNotifications();

      // Must update the ActiveQuestsController here after athan is updated.
      // Was a bug where when forceSalahRecalculation = true was set in
      // ActiveQuestsController, it's update() was called before athan updated.
      ActiveQuestsController.to.update();
    } else if (initUpdate) {
      ActiveQuestsController.to.update(); // so UI shows up
    }

    update(); // update UI with above changes (needed at app init)

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
        updateZaman(false);
        return; // quits while loop, starts again in updateZaman()
      } else if (forceSalahRecalculation || timeToNextZaman.inSeconds <= 0) {
        l.d('ZamanController:_startNextZamanCountdownTimer: This zaman $currZ is over, going to next zaman $nextZ.');
        updateZaman(false);
        return; // quits while loop, starts again in updateZaman()
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // heartbeat prints once a minute to show thread is alive
          l.i('ZamanController:_startNextZamanCountdownTimer: Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        }
        // this is displayed on UI:
        _timeToNextZaman = _printHourMinuteSeconds(timeToNextZaman);
        update();
      }
    }
  }

  _handleNewDaySetup() async {
    l.d('ZamanController:_handleNewDaySetup: New day is being setup.');
    // Reset day, Fajr Tom. is always 1 (or more) days after currDay:
    await TimeController.to.updateTime(true);
    ActiveQuestsAjrController.to.clearAllQuests();
    await Db.setActiveQuest(
      ActiveQuestModel(
        day: TimeController.to.currDay,
        done: 0,
        skip: 0,
        miss: 0,
      ),
    );

    forceSalahRecalculation = true; // time to update _athan

    // now, currZ won't equal Z.Fajr_Tomorrow as currDay updated
    updateZaman(false);
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
      if (z == _currZ) {
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
