import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/time_of_day.dart';
import 'package:hapi/quest/active/athan/tod.dart';
import 'package:timezone/timezone.dart' show Location, TZDateTime;

/// Controls Islamic Times Of Day, e.g. Fajr, Duha, Sunset/Maghrib, etc. that
/// many pages rely on for the current time.
class ZamanController extends GetxHapi {
  static ZamanController get to => Get.find();

  TOD _currTOD = TOD.Dhuhr;
  TOD _nextTOD = TOD.Asr;
  DateTime _currTODTime = DUMMY_TIME;
  DateTime _nextTODTime = DUMMY_TIME;
  TOD get currTOD => _currTOD;
  TOD get nextTOD => _nextTOD;
  DateTime get currTODTime => _currTODTime;
  DateTime get nextTODTime => _nextTODTime;

  final RxString _nextZaman = '-'.obs;
  String get timeToNextZaman => _nextZaman.value;

  bool forceSalahRecalculation = false;

  @override
  void onInit() {
    super.onInit();

    initLocation();
  }

  initLocation() async {
    await TimeController.to.reinitTime(); // TODO call before timer runs down?

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

    var params = CalculationParams(
      calcMethod.params,
      madhab,
      kerahatSunRisingMins,
      kerahatSunZawalMins,
      kerahatSunSettingMins,
      HighLatitudeRule.MiddleOfTheNight, // TODO give user a way to change this
      {
        // TODO give user a way to tune salah times
        SalahAdjust.fajr: 0,
        SalahAdjust.sunrise: 0,
        SalahAdjust.dhuhr: 0,
        SalahAdjust.asr: 0,
        SalahAdjust.maghrib: 0,
        SalahAdjust.isha: 0
      },
    );

    // TODO precision and salah settings
    // TODO fix all this, date should change at FAJR_TOMORROW hit only?
    TimeOfDay tod = TimeOfDay(
        LocationController.to.lastKnownCord, date, params, timezoneLoc, false);
    // TODO asdf fdsa should not need to do this since it's main area is now set a few lines down:
    ActiveQuestsController.to.tod = tod;

    _currTOD = tod.getCurrZaman(date);
    _currTODTime = tod.getZamanTime(_currTOD);

    _nextTOD = tod.getNextZaman(date);
    _nextTODTime = tod.getZamanTime(_nextTOD);

    l.d('_currTODTime: $_currTODTime ($_currTOD)');
    l.d('_nextTODTime: $_nextTODTime ($_nextTOD)');

    // TODO asdf fdsa, this is broken: reset at Maghrib time:
    // reset day:
    if (currTOD == TOD.Fajr_Tomorrow) {
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

      Duration timeToNextZaman = nextTODTime.difference(
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
        } else if (timeToNextZaman.inSeconds % 300 == 0) {
          TimeController.to.reinitTime(); // TODO check cheater every 5 mins?
        }
        _nextZaman.value = _printHourMinuteSeconds(timeToNextZaman);
        update();
      }
    }
  }

  String _printHourMinuteSeconds(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
