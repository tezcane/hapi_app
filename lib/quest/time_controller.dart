import 'dart:async';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/quest/athan/CalculationMethod.dart';
import 'package:hapi/quest/athan/CalculationParameters.dart';
import 'package:hapi/quest/athan/Coordinates.dart';
import 'package:hapi/quest/athan/Madhab.dart';
import 'package:hapi/quest/athan/PrayerTimes.dart';
import 'package:hapi/quest/athan/Qibla.dart';
import 'package:hapi/quest/quest_controller.dart';
import 'package:timezone/data/latest.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' show Location, TZDateTime, getLocation;

final TimeController cTime = Get.find();

class TimeController extends GetxController {
  RxString _nextPrayerTime = '-'.obs;
  String get timeToNextPrayer => _nextPrayerTime.value;

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
        CalculationMethod.getMethod(SalahMethod.values[cQust.salahCalcMethod]);

    if (cQust.salahAsrSafe) {
      params.madhab = Madhab.Hanafi;
    } else {
      params.madhab = Madhab.Shafi;
    }

    if (cQust.salahKerahatSafe) {
      params.kerahatSunRisingMins = 40;
      params.kerahatSunZawalMins = 40;
      params.kerahatSunSettingMins = 40;
    } else {
      params.kerahatSunRisingMins = 20;
      params.kerahatSunZawalMins = 15;
      params.kerahatSunSettingMins = 20;
    }
    cQust.prayerTimes = PrayerTimes(_gps, date, params, _timeZone!, false);

    update(); // update UI with above changes (needed at app init)

    startNextPrayerCountdownTimer();
  }

  void startNextPrayerCountdownTimer() {
    Timer(Duration(seconds: 1), () {
      Duration timeToNextPrayer = cQust.prayerTimes!.nextPrayerDate
          .difference(TZDateTime.from(DateTime.now(), _timeZone!));

      // if we hit the end of a timer we recalculate all prayer times
      if (forceSalahRecalculation || timeToNextPrayer.inSeconds <= 0) {
        print('This prayer is over, going to next prayer: '
            '${timeToNextPrayer.inSeconds} secs left');
        forceSalahRecalculation = false;
        initLocation(); // does startNextPrayerCountdownTimer();
      } else {
        if (timeToNextPrayer.inSeconds % 60 == 0) {
          // print once a minute
          print('Next Prayer Timer Minute Tick: ${timeToNextPrayer.inSeconds} '
              'secs left (${timeToNextPrayer.inSeconds / 60} minutes)');
        }
        _nextPrayerTime.value = _printHourMinuteSeconds(timeToNextPrayer);
        update();
        startNextPrayerCountdownTimer();
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
