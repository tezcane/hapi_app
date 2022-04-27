import 'dart:core';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/connectivity_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hijri/hijri_calendar.dart';
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

  /// Holds the current day in 'yyyy-MM-dd' used for current day's calculations.
  String _currDay = DUMMY_TIME_STR;
  String get currDay => _currDay;
  DateTime get currDayDate => TZDateTime.from(DateTime.parse(_currDay), _tzLoc);

  DAY_OF_WEEK _dayOfWeekHijri = defaultDayOfWeek;
  DAY_OF_WEEK _dayOfWeekGrego = defaultDayOfWeek;
  DAY_OF_WEEK get dayOfWeekHijri => _dayOfWeekHijri;
  DAY_OF_WEEK get dayOfWeekGrego => _dayOfWeekGrego;

  @override
  void onInit() async {
    await updateTime(); // TODO do during splash screen?

    // Initialize currDay as yesterday in case app is started after midnight.
    // This is because Athan's isha/layl are valid through currDay to fajr of
    // the next day (past 11:59PM of currDay). So we must give user ability to
    // start/install app at night and not wait for next day fajr to start
    // performing quests.
    _currDay = dateToDay(dateToYesterday(await now()));

    // times should be initialized, so start Zaman Controller
    if (!ZamanController.to.isInitialized) ZamanController.to.updateZaman();

    super.onInit();
  }

  DateTime dateToYesterday(DateTime dT) => dT.subtract(const Duration(days: 1));
  DateTime dateToTomorrow(DateTime dT) => dT.add(const Duration(days: 1));

  /// Call to update time TODO use to detect irregular clock movement
  /// param updateDayIsOK - we only allow zaman controller to update the day if
  ///                       when next day zaman is hit.
  Future<void> updateTime() async {
    l.d('TimeController:updateTime: start: ntpOffset=$_ntpOffset, tzLoc=$tzLoc');
    await _updateNtpTime();
    await _updateTimezoneLocation();
    l.d('updateTime: after: ntpOffset=$_ntpOffset, tzLoc=$tzLoc');
    update();
  }

  /// Gets NTP time from server when called, if internet is on
  Future<void> _updateNtpTime() async {
    if (!ConnectivityController.to.isInternetOn) {
      l.w('TimeController:updateNtpTime: aborting NTP update, no internet connection');
      return;
    }
    l.d('TimeController:updateNtpTime: Called');
    DateTime appTime = DateTime.now().toLocal();
    try {
      _ntpOffset = await NTP.getNtpOffset(
          localTime: appTime, timeout: const Duration(seconds: 3)); // TODO
      DateTime ntpTime = appTime.add(Duration(milliseconds: _ntpOffset));

      l.d('TimeController:updateNtpTime: NTP DateTime offset align (ntpOffset=$_ntpOffset):');
      l.d('TimeController:updateNtpTime: locTime was=${appTime.toLocal()}');
      l.d('TimeController:updateNtpTime: ntpTime now=${ntpTime.toLocal()}');
    } on Exception catch (e) {
      l.e('TimeController:updateNtpTime: Exception: Failed to call NTP.getNtpOffset(): $e');
    }
  }

  /// Get's local time, uses ntp offset to calculate more accurate time
  Future<DateTime> now() async {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('TimeController:now: called but there is no ntp offset');
      await _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    // print('TimeController:now: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return TZDateTime.from(time.toLocal(), _tzLoc);
  }

  /// Non-async version to get time now()
  DateTime now2() {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('TimeController:now2: called but there is no ntp offset');
      _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    l.d('TimeController.now2: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
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

  updateCurrDay() async {
    String prevDay = dateToDay(currDayDate);
    _currDay = dateToDay(await now());
    l.i('TimeController:updateCurrDay: New day set ($_currDay), prev day was ($prevDay)');
    update();
  }

  String dateToDay(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Call to update day of week for hijri and gregorian Calendars.
  updateDaysOfWeek() async {
    await _updateDayOfWeekHijri();
    await _updateDayOfWeekGrego();
    update();
  }

  _updateDayOfWeekHijri() async {
    _dayOfWeekHijri = _getDayOfWeekHijri(await now());
  }

  _updateDayOfWeekGrego() async {
    _dayOfWeekGrego = _getDayOfWeekGrego(await now());
  }

  /// Hijri calendar day starts at maghrib
  DAY_OF_WEEK _getDayOfWeekHijri(DateTime time) {
    DAY_OF_WEEK day = _getDayOfWeekGrego(time);
    if (iterateHijriDateByOne(time)) {
      int dayIndex = day.index + 1;
      if (dayIndex == 7) dayIndex = 0; // wrap around: if past Sunday -> Monday
      return DAY_OF_WEEK.values[dayIndex];
    }
    l.d('TimeController:_getDayOfWeekHijri: ${day.name}');
    return day;
  }

  bool iterateHijriDateByOne(DateTime dT) {
    Athan athan = ZamanController.to.athan!;

    if (athan.date.year != dT.year ||
        athan.date.month != dT.month ||
        athan.date.day != dT.day) {
      l.e('TimeController:_getDayOfWeekHijri: Year/Month/Day mismatch: athan.date(${athan.date}) != now($dT), continuing anyway');
    }

    // TODO what happens at midnight?
    if (dT.isAfter(athan.maghrib)) {
      return true;
    }
    return false;
  }

  /// Gregorian calendar day starts at Midnight (12:00AM)
  DAY_OF_WEEK _getDayOfWeekGrego(DateTime dT) {
    String dayFromDate = DateFormat('EEEE').format(dT); // TODO all locales ok?

    DAY_OF_WEEK day = defaultDayOfWeek;
    for (var dayOfWeek in DAY_OF_WEEK.values) {
      if (dayFromDate == dayOfWeek.name) {
        day = dayOfWeek;
        break;
      }
    }
    l.d('TimeController:_getDayOfWeekGrego: ${day.name}');
    return day;
  }

  bool isMonday() => _dayOfWeekHijri == DAY_OF_WEEK.Monday;
  bool isTuesday() => _dayOfWeekHijri == DAY_OF_WEEK.Tuesday;
  bool isWednesday() => _dayOfWeekHijri == DAY_OF_WEEK.Wednesday;
  bool isThursday() => _dayOfWeekHijri == DAY_OF_WEEK.Thursday;
  bool isFriday() => _dayOfWeekHijri == DAY_OF_WEEK.Friday;
  bool isSaturday() => _dayOfWeekHijri == DAY_OF_WEEK.Saturday;
  bool isSunday() => _dayOfWeekHijri == DAY_OF_WEEK.Sunday;

  String getDateHijri(bool includeDayOfWeek) {
    DateTime dT = now2();
    if (iterateHijriDateByOne(dT)) dT = dateToTomorrow(dT);
    String dayOfWeek = '';
    if (includeDayOfWeek) dayOfWeek = '${_dayOfWeekHijri.name} ';
    return '$dayOfWeek${HijriCalendar.fromDate(dT).toFormat('MMMM dd, yyyy')}';
  }

  String getDateGrego(bool includeDayOfWeek) {
    String dayOfWeek = '';
    if (includeDayOfWeek) dayOfWeek = '${_dayOfWeekGrego.name} ';
    return '$dayOfWeek${DateFormat('MMMM d, yyyy').format(now2())}';
  }
}
