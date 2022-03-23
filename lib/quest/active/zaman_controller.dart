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
  Z _nextZ = Z.Asr;
  Z get currZ => _currZ;
  Z get nextZ => _nextZ;

  /// Next zaman Timestamp used to countdown to and update the UI accordingly.
  DateTime _nextZTime = DUMMY_TIME;
  String _timeToNextZaman = '-';
  String get timeToNextZaman => _timeToNextZaman;

  bool forceSalahRecalculation = false;

  Athan? _athan;
  Athan? get athan => _athan;
  // set athan(Athan? athan) {
  //   _athan = athan;
  //   update();
  // }

  @override
  void onInit() {
    super.onInit();

    initLocation();
  }

  initLocation() async {
    await TimeController.to.initTime(); // TODO call before timer runs down?

    // TODO is this even needed, getTime gets local time of user?
    Location timezoneLoc = await TimeController.to.getTimezoneLocation();
    DateTime date = TZDateTime.from(await TimeController.to.now(), timezoneLoc);

    var calcMethod =
        CalcMethod.values[ActiveQuestsController.to.salahCalcMethod];

    var madhab = Madhab.Hanafi;
    if (!ActiveQuestsController.to.salahAsrSafe) {
      madhab = Madhab.Shafi;
    }

    int kerahatSunRisingMins = 40;
    int kerahatSunZawalMins = 30;
    int kerahatSunSettingMins = 40;
    if (!ActiveQuestsController.to.salahKerahatSafe) {
      kerahatSunRisingMins = 20;
      kerahatSunZawalMins = 15;
      kerahatSunSettingMins = 20;
    }

    // TODO give user a way to change:
    //   HighLatitudeRule, SalahAdjust, and precision
    var params = CalculationParams(
      calcMethod.params,
      madhab,
      kerahatSunRisingMins,
      kerahatSunZawalMins,
      kerahatSunSettingMins,
      HighLatitudeRule.MiddleOfTheNight,
      {
        SalahAdjust.fajr: 0,
        SalahAdjust.sunrise: 0,
        SalahAdjust.dhuhr: 0,
        SalahAdjust.asr: 0,
        SalahAdjust.maghrib: 0,
        SalahAdjust.isha: 0
      },
    );

    bool precision = false;
    Athan athan = Athan(
      LocationController.to.lastKnownCord,
      date,
      params,
      timezoneLoc,
      precision,
    );
    _athan = athan;
    _currZ = athan.getCurrZaman(date);
    _nextZ = athan.getNextZaman(date);

    _nextZTime = athan.getZamanTime(_nextZ);
    l.d('_currZTime: $_currZ');
    l.d('_nextZTime: $_nextZ');

    // TODO asdf fdsa, this is broken: reset at Maghrib time:
    // reset day:
    if (currZ == Z.Fajr_Tomorrow) {
      ActiveQuestsAjrController.to.clearAllQuests();
    }
    // For next prayer/day, set any missed quests and do other quest setup:
    ActiveQuestsAjrController.to.initCurrQuest();

    update(); // update UI with above changes (needed at app init)

    startNextZamanCountdownTimer();
  }

  void startNextZamanCountdownTimer() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      Duration timeToNextZaman = _nextZTime.difference(
        TZDateTime.from(
          await TimeController.to.now(),
          TimeController.to.tzLoc,
        ),
      );

      // if we hit the end of a timer (or forced), recalculate zaman times:
      if (forceSalahRecalculation || timeToNextZaman.inSeconds <= 0) {
        l.d('This zaman is over, going to next zaman: '
            '${timeToNextZaman.inSeconds} secs left');
        forceSalahRecalculation = false;
        initLocation(); // does eventually call startNextZamanCountdownTimer();
        return;
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // print once a minute to show thread is alive
          l.i('Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        } else if (timeToNextZaman.inSeconds % 3600 == 0) {
          TimeController.to.initTime(); // TODO check cheater every hour?
        }
        _timeToNextZaman = _printHourMinuteSeconds(timeToNextZaman);
        update();
      }
    }
  }

  String _printHourMinuteSeconds(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  }

  /// Iterate through given Zs for a given salah row, see if it matches curr Z.
  bool isSalahRowActive(Z z) {
    List<Z> zs;

    switch (z) {
      case Z.Fajr:
        zs = [Z.Fajr, Z.Fajr_Tomorrow];
        break;
      case Z.Duha:
        zs = [Z.Kerahat_Sunrise, Z.Ishraq, Z.Duha, Z.Kerahat_Zawal];
        break;
      case Z.Dhuhr:
        zs = [Z.Dhuhr];
        break;
      case Z.Asr:
        zs = [Z.Asr, Z.Kerahat_Sun_Setting];
        break;
      case Z.Maghrib:
        zs = [Z.Maghrib];
        break;
      case Z.Isha:
        zs = [Z.Isha];
        break;
      case Z.Night__3:
        zs = [Z.Isha, Z.Night__2, Z.Night__3];
        break;
      default:
        var e = 'Invalid Zaman ($z) given when in isSalahRowActive called';
        l.e(e);
        throw e;
    }

    for (Z z in zs) {
      if (z == _currZ) return true; // time of day is active
    }

    return false; // this time of day is not active
  }
}
