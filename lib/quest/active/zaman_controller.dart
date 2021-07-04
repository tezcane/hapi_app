import 'dart:async';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/CalculationMethod.dart';
import 'package:hapi/quest/active/athan/CalculationParameters.dart';
import 'package:hapi/quest/active/athan/Coordinates.dart';
import 'package:hapi/quest/active/athan/Madhab.dart';
import 'package:hapi/quest/active/athan/PrayerTimes.dart';
import 'package:hapi/quest/active/athan/Qibla.dart';
import 'package:hapi/quest/active/athan/Zaman.dart';
import 'package:timezone/data/latest.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' show Location, TZDateTime, getLocation;

final ZamanController cZamn = Get.find();

class ZamanController extends GetxController {
  RxString _nextZaman = '-'.obs;
  String get timeToNextZaman => _nextZaman.value;

  Location? _timeZone;
  Coordinates _gps = Coordinates(36.950663449472, -122.05716133118);
  double? _qiblaDirection;
  double? get qiblaDirection => _qiblaDirection;

  bool forceSalahRecalculation = false;

  @override
  void onInit() {
    initializeTimeZones();

    initLocation();

    super.onInit();
  }

  initLocation() async {
    // TODO detect and report bad timezones
    String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    print('***** Time Zone: "$timeZone"');

    _timeZone = getLocation(timeZone); // 'America/Los_Angeles'
    _gps = Coordinates(37.3382, -121.8863); // San Jose // TODO

    _qiblaDirection = Qibla.qibla(_gps); // Qibla Direction TODO
    print('***** Qibla Direction:');
    print('qibla: $_qiblaDirection');

    // TODO precision and salah settings
    DateTime date = TZDateTime.from(DateTime.now(), _timeZone!);
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
    // TODO fix all this, date should change at FAJR_TOMORROW hit only?
    cQstA.prayerTimes = PrayerTimes(_gps, date, params, _timeZone!, false);

    // reset day:
    if (cQstA.prayerTimes!.currZaman == Zaman.Fajr_Tomorrow) {
      cAjrA.clearAllQuests();
    }
    // For next prayer/day, set any missed quests and do other quest setup:
    cAjrA.initCurrQuest();

    update(); // update UI with above changes (needed at app init)

    startNextZamanCountdownTimer();
  }

  void startNextZamanCountdownTimer() {
    Timer(Duration(seconds: 1), () {
      Duration timeToNextZaman = cQstA.prayerTimes!.nextZamanTime
          .difference(TZDateTime.from(DateTime.now(), _timeZone!));

      // if we hit the end of a timer (or forced), recalculate zaman times:
      if (forceSalahRecalculation || timeToNextZaman.inSeconds <= 0) {
        print('This zaman is over, going to next zaman: '
            '${timeToNextZaman.inSeconds} secs left');
        forceSalahRecalculation = false;
        initLocation(); // does eventually call startNextZamanCountdownTimer();
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // print once a minute
          print('Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
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
