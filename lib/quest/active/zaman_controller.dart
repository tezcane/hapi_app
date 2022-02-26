import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/CalculationMethod.dart';
import 'package:hapi/quest/active/athan/CalculationParameters.dart';
import 'package:hapi/quest/active/athan/Coordinates.dart';
import 'package:hapi/quest/active/athan/Madhab.dart';
import 'package:hapi/quest/active/athan/Qibla.dart';
import 'package:hapi/quest/active/athan/TOD.dart';
import 'package:hapi/quest/active/athan/TimeOfDay.dart';
import 'package:timezone/timezone.dart' show Location, TZDateTime;

/// Controls Islamic Times Of Day, e.g. Fajr, Duha, Sunset/Maghrib, etc.
class ZamanController extends GetxHapi {
  static ZamanController get to => Get.find();

  final RxString _nextZaman = '-'.obs;
  String get timeToNextZaman => _nextZaman.value;

  Coordinates _gps = Coordinates(36.950663449472, -122.05716133118);
  double? _qiblaDirection;
  double? get qiblaDirection => _qiblaDirection;

  bool forceSalahRecalculation = false;

  @override
  void onInit() {
    super.onInit();

    initLocation();
  }

  initLocation() async {
    await TimeController.to.reinitTime();

    // TODO call this before timer fully runs down

    // TODO move to location controller
    _gps = Coordinates(37.3382, -121.8863); // San Jose // TODO
    _qiblaDirection = Qibla.qibla(_gps); // Qibla Direction TODO
    print('***** Qibla Direction:');
    print('qibla: $_qiblaDirection');

    // TODO is this even needed, getTime gets local time of user?
    Location timezoneLoc = await TimeController.to.getTimezoneLocation();
    DateTime date = TZDateTime.from(await TimeController.to.now(), timezoneLoc);

    final ActiveQuestsController cQstA = ActiveQuestsController.to;

    CalculationParameters params =
        CalculationMethod.getMethod(SalahMethod.values[cQstA.salahCalcMethod]);

    if (cQstA.salahAsrSafe) {
      params.madhab = Madhab.Hanafi;
    } else {
      params.madhab = Madhab.Shafi;
    }

    if (cQstA.salahKerahatSafe) {
      params.kerahatSunRisingMins = 40;
      params.kerahatSunZawalMins = 30;
      params.kerahatSunSettingMins = 40;
    } else {
      params.kerahatSunRisingMins = 20;
      params.kerahatSunZawalMins = 15;
      params.kerahatSunSettingMins = 20;
    }
    // TODO precision and salah settings
    // TODO fix all this, date should change at FAJR_TOMORROW hit only?
    cQstA.tod = TimeOfDay(_gps, date, params, timezoneLoc, false);

    // reset day:
    if (cQstA.tod!.currTOD == TOD.Fajr_Tomorrow) {
      ActiveQuestsAjrController.to.clearAllQuests();
    }
    // For next prayer/day, set any missed quests and do other quest setup:
    ActiveQuestsAjrController.to.initCurrQuest();

    update(); // update UI with above changes (needed at app init)

    startNextZamanCountdownTimer();
  }

  void startNextZamanCountdownTimer() {
    Timer(const Duration(seconds: 1), () async {
      final ActiveQuestsController cQstA = ActiveQuestsController.to;

      Duration timeToNextZaman = cQstA.tod!.nextTODTime.difference(
          TZDateTime.from(
              await TimeController.to.now(), TimeController.to.tzLoc));

      // if we hit the end of a timer (or forced), recalculate zaman times:
      if (forceSalahRecalculation || timeToNextZaman.inSeconds <= 0) {
        print('This zaman is over, going to next zaman: '
            '${timeToNextZaman.inSeconds} secs left');
        forceSalahRecalculation = false;
        initLocation(); // does eventually call startNextZamanCountdownTimer();
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // print once a minute to show thread is alive
          print('Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        } else if (timeToNextZaman.inSeconds % 300 == 0) {
          TimeController.to.reinitTime(); // TODO check cheater every 5 mins?
        }
        _nextZaman.value = _printHourMinuteSeconds(timeToNextZaman);
        update();
        startNextZamanCountdownTimer();
      }
    });
  }

  String _printHourMinuteSeconds(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
