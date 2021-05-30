import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/quest/athan/CalculationMethod.dart';
import 'package:hapi/quest/athan/CalculationParameters.dart';
import 'package:hapi/quest/athan/Coordinates.dart';
import 'package:hapi/quest/athan/Madhab.dart';
import 'package:hapi/quest/athan/PrayerTimes.dart';
import 'package:hapi/quest/athan/Qibla.dart';
import 'package:hapi/quest/athan/SunnahTimes.dart';
import 'package:hapi/quest/quest_model.dart';
import 'package:hapi/services/database.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' show Location, TZDateTime, getLocation;

final QuestController cQust = Get.find();

enum DAY_OF_WEEK {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}

enum FARD_SALAH {
  Fajr,
  Dhuhr,
  Asr,
  Maghrib,
  Isha,
}

DAY_OF_WEEK getDayOfWeek() {
  String day = DateFormat('EEEE').format(DateTime.now());
  for (var dayOfWeek in DAY_OF_WEEK.values) {
    if (day == dayOfWeek.toString().split('.').last) {
      return dayOfWeek;
    }
  }
  return DAY_OF_WEEK.Friday; // TODO throw e?
}

class QuestController extends GetxController {
  Rx<List<QuestModel>> questList = Rx<List<QuestModel>>([]);
  Rxn<User> firebaseUser = Rxn<User>();

  List<QuestModel> get quests => questList.value;

  Rx<DAY_OF_WEEK> _dayOfWeek = getDayOfWeek().obs;
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek.value;
  void updateDayOfWeek() => _dayOfWeek.value = getDayOfWeek();

  bool isFriday() => _dayOfWeek.value == DAY_OF_WEEK.Friday;

  RxBool _showSunnahMuak = true.obs;
  RxBool _showSunnahNafl = false.obs;
  RxBool _showSunnahJummah = true.obs; // switches between dhur and jummah view
  RxBool _show12HourClock = true.obs; // false = 24 hour clock/military time

  Rx<FARD_SALAH> _activeSalah = FARD_SALAH.Maghrib.obs;
  FARD_SALAH get activeSalah => _activeSalah.value;

  DateTime? _fajr;
  DateTime? _sunrise;
  DateTime? _dhuhr;
  DateTime? _asr;
  DateTime? _maghrib;
  DateTime? _isha;
  DateTime? _ishaBefore;
  DateTime? _fajrAfter;
  String? _currPrayerName;
  DateTime? _currPrayer;
  String? _nextPrayerName;
  DateTime? _nextPrayer;
  DateTime? _middleOfTheNight;
  DateTime? _lastThirdOfTheNight;
  double? _qiblaDirection;
  RxString _nextPrayerTime = '-'.obs;
  int _secsToNextPrayer = 86401; // make big so first call doesn' retrigger init

  DateTime? get fajr => _fajr;
  DateTime? get sunrise => _sunrise;
  DateTime? get dhuhr => _dhuhr;
  DateTime? get asr => _asr;
  DateTime? get maghrib => _maghrib;
  DateTime? get isha => _isha;
  DateTime? get ishaBefore => _ishaBefore;
  DateTime? get fajrAfter => _fajrAfter;
  String? get currentPrayerName => _currPrayerName;
  DateTime? get currentPrayer => _currPrayer;
  String? get nextPrayerName => _nextPrayerName;
  DateTime? get nextPrayer => _nextPrayer;
  DateTime? get middleOfTheNight => _middleOfTheNight;
  DateTime? get lastThirdOfTheNight => _lastThirdOfTheNight;
  double? get qiblaDirection => _qiblaDirection;
  String get timeToNextPrayer => _nextPrayerTime.value;

  Location? _timeZone;
  Coordinates _gps = Coordinates(36.950663449472, -122.05716133118);

  @override
  void onInit() {
    initializeTimeZones();

    initLocation();

    _showSunnahMuak.value = s.read('showSunnahMuak') ?? true;
    _showSunnahNafl.value = s.read('showSunnahNafl') ?? false;
    _showSunnahJummah.value = s.read('showSunnahJummah') ?? true;
    _show12HourClock.value = s.read('show12HourClock') ?? true;

    // TODO this looks unreliable:
    String uid = Get.find<AuthController>().firebaseUser.value!.uid;
    print('QuestController.onInit: binding to db with uid=$uid');
    questList.bindStream(Database().questStream(uid)); //stream from firebase

    super.onInit();
  }

  bool get showSunnahMuak => _showSunnahMuak.value;
  bool get showSunnahNafl => _showSunnahNafl.value;
  bool get showSunnahJummah => _showSunnahJummah.value;
  bool get show12HourClock => _show12HourClock.value;

  void toggleShowSunnahMuak() {
    _showSunnahMuak.value = !_showSunnahMuak.value;
    s.write('showSunnahMuak', _showSunnahMuak.value);
    update();
  }

  void toggleShowSunnahNafl() {
    _showSunnahNafl.value = !_showSunnahNafl.value;
    s.write('showSunnahNafl', _showSunnahNafl.value);
    update();
  }

  void toggleShowSunnahJummah() {
    _showSunnahJummah.value = !_showSunnahJummah.value;
    s.write('showSunnahJummah', _showSunnahJummah.value);
    update();
  }

  void toggleShow12HourClock() {
    _show12HourClock.value = !_show12HourClock.value;
    s.write('show12HourClock', _show12HourClock.value);
    update();
  }

  void toggleSalahAlarm(FARD_SALAH fardSalah) {
    // TODO asdf
  }

  initLocation() async {
    String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    print('***** Time Zone: "$timeZone"');

    _timeZone = getLocation(timeZone); // 'America/Los_Angeles'
    _gps = Coordinates(37.3382, -121.8863); // San Jose // TODO

    _qiblaDirection = Qibla.qibla(_gps); // Qibla Direction TODO

    // TODO precision and salah settings
    DateTime date = TZDateTime.from(DateTime.now(), _timeZone!);
    CalculationParameters params = CalculationMethod.NorthAmerica();
    params.madhab = Madhab.Hanafi;
    PrayerTimes prayerTimes = PrayerTimes(_gps, date, params, precision: false);

    initSalahTimes(date, prayerTimes, _timeZone!);
  }

  initSalahTimes(DateTime date, PrayerTimes prayerTimes, Location tz) async {
    // Prayer times
    _fajr = TZDateTime.from(prayerTimes.fajr!, tz);
    _sunrise = TZDateTime.from(prayerTimes.sunrise!, tz);
    _dhuhr = TZDateTime.from(prayerTimes.dhuhr!, tz);
    _asr = TZDateTime.from(prayerTimes.asr!, tz);
    _maghrib = TZDateTime.from(prayerTimes.maghrib!, tz);
    _isha = TZDateTime.from(prayerTimes.isha!, tz);

    _ishaBefore = TZDateTime.from(prayerTimes.ishabefore!, tz);
    _fajrAfter = TZDateTime.from(prayerTimes.fajrafter!, tz);

    // Convenience Utilities
    _currPrayerName = prayerTimes.currentPrayer(date);
    _currPrayer =
        TZDateTime.from(prayerTimes.timeForPrayer(_currPrayerName!)!, tz);

    _nextPrayerName = prayerTimes.nextPrayer(date);
    _nextPrayer =
        TZDateTime.from(prayerTimes.timeForPrayer(_nextPrayerName!)!, tz);

    // Sunnah Times
    SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);
    _middleOfTheNight = TZDateTime.from(sunnahTimes.middleOfTheNight, tz);
    _lastThirdOfTheNight = TZDateTime.from(sunnahTimes.lastThirdOfTheNight, tz);

    switch (_currPrayerName) {
      // TODO what to do with these?
      // 'sunrise';
      // 'ishabefore';
      // 'fajrafter';
      // 'none';
      case ('none'):
      case ('fajr'):
      case ('sunrise'):
      case ('fajrafter'):
        {
          _activeSalah.value = FARD_SALAH.Fajr;
          break;
        }
      case ('dhuhr'):
        {
          _activeSalah.value = FARD_SALAH.Dhuhr;
          break;
        }
      case ('asr'):
        {
          _activeSalah.value = FARD_SALAH.Asr;
          break;
        }
      case ('maghrib'):
        {
          _activeSalah.value = FARD_SALAH.Maghrib;
          break;
        }
      case ('isha'):
      case ('ishabefore'):
        {
          _activeSalah.value = FARD_SALAH.Isha;
          break;
        }
    }

    print('***** Current Local Time: $date');
    print('***** Time Zone: "${date.timeZoneName}"');

    print('***** Prayer Times:');
    print('fajr:        $_fajr');
    print('sunrise:     $_sunrise');
    print('dhuhr:       $_dhuhr');
    print('asr:         $_asr');
    print('maghrib:     $_maghrib');
    print('isha:        $_isha');
    print('isha before: $_ishaBefore');
    print('fajr after:  $_fajrAfter');

    print('***** Convenience Utilities:');
    print('current: $_currPrayer ($_currPrayerName)');
    print('next:    $_nextPrayer ($_nextPrayerName)');

    print('***** Sunnah Times:');
    print('middleOfTheNight:    $_middleOfTheNight');
    print('lastThirdOfTheNight: $_lastThirdOfTheNight');

    print('***** Qibla Direction:');
    print('qibla: $_qiblaDirection');

    update(); // update UI with above changes (needed at app init)

    startNextPrayerCountdownTimer();
  }

  // TODO put timer in another controller for optimization?
  void startNextPrayerCountdownTimer() {
    Timer(Duration(seconds: 1), () {
      DateTime date = TZDateTime.from(DateTime.now(), _timeZone!);
      Duration nextPrayerDuration = _nextPrayer!.difference(date);

      // if we hit the end of a timer we recalculate all prayer times
      if (nextPrayerDuration.inSeconds > _secsToNextPrayer) {
        _secsToNextPrayer = nextPrayerDuration.inSeconds;
        initLocation(); // does startNextPrayerCountdownTimer();
      } else {
        _secsToNextPrayer = nextPrayerDuration.inSeconds;
        _nextPrayerTime.value = _printHourMinuteSeconds(nextPrayerDuration);
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
