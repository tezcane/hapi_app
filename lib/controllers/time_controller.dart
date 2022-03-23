import 'dart:core';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/connectivity_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:timezone/timezone.dart'
    show Location, LocationNotFoundException, getLocation;

// Params to init values so we don't have to worry about NPE/null checks
final DateTime DUMMY_TIME = DateTime.utc(2022, 2, 22, 22, 222, 222); // 2's day
const int DUMMY_NTP_OFFSET = 222222222222222;
const String DUMMY_TIMEZONE = 'America/Los_Angeles'; // TODO random Antartica?

enum DAY_OF_WEEK {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}

DAY_OF_WEEK getDayOfWeek(DateTime dateTime) {
  // TODO test in other locales also // TODO test, used to be DateTime now()
  String day = DateFormat('EEEE').format(dateTime);
  for (var dayOfWeek in DAY_OF_WEEK.values) {
    if (day == dayOfWeek.name) {
      return dayOfWeek;
    }
  }

  DAY_OF_WEEK defaultDayOfWeek = DAY_OF_WEEK.Monday;
  l.e('getDayOfWeek: Invalid day of week, defaulting to; method found: $defaultDayOfWeek');
  return defaultDayOfWeek;
}

/// Used to get accurate server UTC/NTP based time in case user's clock is off
class TimeController extends GetxHapi {
  static TimeController get to => Get.find();

  // TODO don't need Rx here and other controllers?
  int _ntpOffset = DUMMY_NTP_OFFSET;

  DateTime _lastNtpTime = DUMMY_TIME;
  DateTime get lastUtcTime => _lastNtpTime;

  bool forceSalahRecalculation = false;

  /// NOTE: Can run only because tz.initializeTimeZones() completes in main.dart
  /// Used to calculate Zaman times
  Location _tzLoc = getLocation(DUMMY_TIMEZONE);
  Location get tzLoc => _tzLoc;

  DAY_OF_WEEK _dayOfWeek = getDayOfWeek(DUMMY_TIME);
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek;
  _updateDayOfWeek() async =>
      _dayOfWeek = getDayOfWeek(await TimeController.to.now());
  bool isFriday() => _dayOfWeek == DAY_OF_WEEK.Friday;

  @override
  void onInit() async {
    super.onInit();

    await initTime(); // TODO do during splash screen?
  }

  /// Call to update time TODO use to detect irregular clock movement
  Future<void> initTime() async {
    l.d('initTime called tz=$tzLoc, DateTime=${DateTime.now()}, ntpOffset=$_ntpOffset, dayOfWeek=$_dayOfWeek');
    await _updateNtpTime();
    await getTimezoneLocation();
    await _updateDayOfWeek();
    l.d('initTime done tz=$tzLoc, DateTime=${DateTime.now()}, ntpOffset=$_ntpOffset}, dayOfWeek=$_dayOfWeek');
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
      _lastNtpTime = appTime.add(Duration(milliseconds: _ntpOffset));

      l.d('cTime:updateNtpTime: NTP DateTime offset align (ntpOffset=$_ntpOffset):');
      l.d('cTime:updateNtpTime: locTime was=${appTime.toLocal()}');
      l.d('cTime:updateNtpTime: ntpTime now=${_lastNtpTime.toLocal()}');
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
    return time.toLocal();
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
    return time.toLocal();
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

        l.e('$err\ntimezone "$tzName" not found by getLocation, using defualt: $DUMMY_TIMEZONE');
        tzLocation = getLocation(DUMMY_TIMEZONE);
      }
    }

    return Future<Location>.value(tzLocation);
  }

  Future<Location> getTimezoneLocation() async {
    Location? tzLocation = await _getTimezoneLocFromSystem();
    _tzLoc = tzLocation ?? await _getTimezoneLocFromTimeDate();
    return Future<Location>.value(_tzLoc);
  }
}
