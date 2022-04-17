import 'dart:core';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/connectivity_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:timezone/timezone.dart'
    show Location, TZDateTime, LocationNotFoundException, getLocation;

// Params to init values so we don't have to worry about NPE/null checks
final DateTime DUMMY_TIME = DateTime.utc(2022, 2, 22, 22, 222, 222); // 2's day
const String DUMMY_TIME_STR = '2022-02-22';
const int DUMMY_NTP_OFFSET = 222222222222222;
const String DUMMY_TIMEZONE = 'America/Los_Angeles'; // TODO random Antarctica?

enum DAY_OF_WEEK {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}

/// Used to get accurate server UTC/NTP based time in case user's clock is off
class TimeController extends GetxHapi {
  static TimeController get to => Get.find();

  static DAY_OF_WEEK defaultDayOfWeek = DAY_OF_WEEK.Monday;

  bool forceSalahRecalculation = false;

  int _ntpOffset = DUMMY_NTP_OFFSET;

  /// NOTE: Can run only because tz.initializeTimeZones() completes in main.dart
  /// Used to calculate Zaman times
  Location _tzLoc = getLocation(DUMMY_TIMEZONE);
  Location get tzLoc => _tzLoc;

  /// Holds the current day in 'yyyy-MM-dd' used for point calculations
  String _currDay = DUMMY_TIME_STR;
  String get currDay => _currDay;
  DateTime get currDayDate => TZDateTime.from(DateTime.parse(_currDay), _tzLoc);

  DAY_OF_WEEK _dayOfWeek = defaultDayOfWeek;
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek;

  @override
  void onInit() async {
    super.onInit();

    await updateTime(false); // TODO do during splash screen?

    // times should all be updated above, so now start Zaman Controller
    if (!ZamanController.to.isInitialized) ZamanController.to.updateZaman(true);
  }

  /// Call to update time TODO use to detect irregular clock movement
  /// param updateDayIsOK - we only allow zaman controller to update the day if
  ///                       when next day zaman is hit.
  Future<void> updateTime(bool updateDayIsOk) async {
    l.d('updateTime: start: ntpOffset=$_ntpOffset, tzLoc=$tzLoc, currDay=$_currDay, dayOfWeek=$_dayOfWeek');
    await _updateNtpTime();
    await _updateTimezoneLocation();
    await _updateCurrDay(updateDayIsOk);
    await _updateDayOfWeek();
    l.d('updateTime: after: ntpOffset=$_ntpOffset, tzLoc=$tzLoc, currDay=$_currDay, dayOfWeek=$_dayOfWeek');
  }

  /// Gets NTP time from server when called, if internet is on
  Future<void> _updateNtpTime() async {
    if (!ConnectivityController.to.isInternetOn) {
      l.w('cTime:updateNtpTime: aborting NTP update, no internet connection');
      return;
    }
    l.d('cTime:updateNtpTime: Called');
    DateTime appTime = DateTime.now().toLocal();
    try {
      _ntpOffset = await NTP.getNtpOffset(
          localTime: appTime, timeout: const Duration(seconds: 3)); // TODO
      DateTime ntpTime = appTime.add(Duration(milliseconds: _ntpOffset));

      l.d('cTime:updateNtpTime: NTP DateTime offset align (ntpOffset=$_ntpOffset):');
      l.d('cTime:updateNtpTime: locTime was=${appTime.toLocal()}');
      l.d('cTime:updateNtpTime: ntpTime now=${ntpTime.toLocal()}');
    } on Exception catch (e) {
      l.e('cTime:updateNtpTime: Exception: Failed to call NTP.getNtpOffset(): $e');
    }
  }

  /// Get's local time, uses ntp offset to calculate more accurate time
  Future<DateTime> now() async {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('cTime:now: called but there is no ntp offset');
      await _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    // print('cTime:now: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return TZDateTime.from(time.toLocal(), _tzLoc);
  }

  /// Non-async version to get time now()
  DateTime now2() {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('cTime:now2: called but there is no ntp offset');
      _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    l.d('cTime.now2: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return TZDateTime.from(time.toLocal(), _tzLoc);
  }

  /// TODO Test other platforms:
  /// Gets the systems timezone, i.e. Android, iOS reported timezone, or null
  Future<Location?> _getTimezoneLocFromSystem() async {
    Location? timezoneLoc;
    try {
      String tzName = await FlutterNativeTimezone.getLocalTimezone();
      l.d('***** _getTimezoneFromSystem Timezone: "$tzName"');

      try {
        timezoneLoc = getLocation(tzName);
      } on LocationNotFoundException catch (err) {
        l.e('timezone "$tzName" not found by getLocation: $err');
      }
    } on ArgumentError catch (err) {
      l.e('failed to get sys timezone: error=$err');
    }
    return Future<Location?>.value(timezoneLoc);
  }

  /// Gets the systems timezone from parsing DateTime TODO TEST
  Future<Location> _getTimezoneLocFromTimeDate() async {
    Location tzLocation;
    String tzName = (await now()).toLocal().timeZoneName;
    l.d('***** _getTimezoneFromTimeDate Time Zone: "$tzName"'); // 'America/Los_Angeles'

    try {
      tzLocation = getLocation(tzName);
    } on LocationNotFoundException catch (err) {
      if (tzLoc.name == DUMMY_TIMEZONE) {
        l.e('$err\ntimezone "$tzName" not found by getLocation, using existing: $_tzLoc');
        tzLocation = tzLoc;
      } else {
        // TODO give prompt to user to enter their timezone:
        // All time zones are defined as offsets from Coordinated Universal Time
        // (UTC), ranging from UTC−12:00 to UTC+14:00. The offsets are usually a
        // whole number of hours, but a few zones are offset by an additional
        // 30 or 45 minutes, such as in India, South Australia and Nepal.

        l.e('$err\ntimezone "$tzName" not found by getLocation, using default: $DUMMY_TIMEZONE');
        tzLocation = getLocation(DUMMY_TIMEZONE);
      }
    }

    return Future<Location>.value(tzLocation);
  }

  _updateTimezoneLocation() async {
    Location? tzLocation = await _getTimezoneLocFromSystem();
    _tzLoc = tzLocation ?? await _getTimezoneLocFromTimeDate();
  }

  _updateCurrDay(bool updateDayIsOk) async {
    DateTime? currDayDate = DateTime.tryParse(s.rd('currDay') ?? '');
    DateTime currTimeDate = await now();

    // if currDay never initialized
    if (currDayDate == null) {
      _currDay = dateToDay(currTimeDate);
      s.wr('currDay', _currDay);
    } else {
      if (updateDayIsOk) {
        // Note: always updates time if new day is detected
        String currDay = dateToDay(currDayDate);
        String currTime = dateToDay(currTimeDate);
        if (currDay != currTime) currDay = currTime;
        if (_currDay != currDay) {
          _currDay = currDay;
          s.wr('currDay', _currDay);
        }
      } else {
        _currDay = dateToDay(currTimeDate);
      }
    }
  }

  String dateToDay(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  _updateDayOfWeek() async => _dayOfWeek = getDayOfWeek(await now());

  DAY_OF_WEEK getDayOfWeek(DateTime dateTime) {
    // TODO test in other locales also // TODO test, used to be DateTime now()
    String day = DateFormat('EEEE').format(dateTime);
    for (var dayOfWeek in DAY_OF_WEEK.values) {
      if (day == dayOfWeek.name) return dayOfWeek;
    }

    l.e('getDayOfWeek: Invalid day of week, defaulting to; method found: $defaultDayOfWeek');
    return defaultDayOfWeek;
  }

  // TODO friday should switch Thursday at Maghrib
  bool isFriday() => _dayOfWeek == DAY_OF_WEEK.Friday;
}
