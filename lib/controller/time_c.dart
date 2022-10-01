import 'dart:core';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/connectivity_c.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/zaman_c.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:timezone/timezone.dart'
    show Location, TZDateTime, LocationNotFoundException, getLocation;

// Params to init values so we don't have to worry about NPE/null checks
final DateTime DUMMY_TIME1 = DateTime.utc(2022, 2, 22); // 2's day
final DateTime DUMMY_TIME2 = DateTime.utc(2022, 2, 23); // 2's day + 1 day
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
  Sunday,
}

extension EnumUtil on DAY_OF_WEEK {
  String get tk {
    String transliteration = name;
    switch (this) {
      case (DAY_OF_WEEK.Monday):
        transliteration = 'Aliathnayn';
        break;
      case (DAY_OF_WEEK.Tuesday):
        transliteration = "Althulatha'";
        break;
      case (DAY_OF_WEEK.Wednesday):
        transliteration = "Al'arbiea'";
        break;
      case (DAY_OF_WEEK.Thursday):
        transliteration = 'Alkhamis';
        break;
      case (DAY_OF_WEEK.Friday):
        transliteration = 'Jumah';
        break;
      case (DAY_OF_WEEK.Saturday):
        transliteration = 'Alsabt';
        break;
      case (DAY_OF_WEEK.Sunday):
        transliteration = "Al'ahad";
        break;
    }
    return 'a.$transliteration';
  }
}

enum MONTH {
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December,
}

extension EnumUtil2 on MONTH {
  String get tk {
    String transliteration = name;
    switch (this) {
      case (MONTH.January):
        transliteration = 'Kānūn aṯ-Ṯānī';
        break;
      case (MONTH.February):
        transliteration = 'Šubāṭ';
        break;
      case (MONTH.March):
        transliteration = "'Āḏār";
        break;
      case (MONTH.April):
        transliteration = 'Naysān';
        break;
      case (MONTH.May):
        transliteration = "'Ayyār";
        break;
      case (MONTH.June):
        transliteration = 'Ḥazīrān';
        break;
      case (MONTH.July):
        transliteration = 'Tammūz';
        break;
      case (MONTH.August):
        transliteration = "'Āb";
        break;
      case (MONTH.September):
        transliteration = "'Aylūl";
        break;
      case (MONTH.October):
        transliteration = "Tišrīn al-'Awwal";
        break;
      case (MONTH.November):
        transliteration = 'Tišrīn aṯ-Ṯānī';
        break;
      case (MONTH.December):
        transliteration = "Kānūn al-'Awwal";
        break;
    }
    return 'a.$transliteration';
  }
}

/// Used to get accurate server UTC/NTP based time in case user's clock is off
class TimeC extends GetxHapi {
  static TimeC get to => Get.find();

  static DAY_OF_WEEK defaultDayOfWeek = DAY_OF_WEEK.Monday;
  static int thisYear = TimeC.to.now2().year;

  int _ntpOffset = DUMMY_NTP_OFFSET;

  /// NOTE: Can run only because tz.initializeTimeZones() completes in main.dart
  /// Used to calculate Zaman times
  Location tzLoc = getLocation(DUMMY_TIMEZONE);

  /// Holds the current day in 'yyyy-MM-dd' used for current day's calculations.
  String currDay = DUMMY_TIME_STR;
  DateTime currDayDate = DUMMY_TIME1;
  DAY_OF_WEEK currDayOfWeek = defaultDayOfWeek;
  DateTime nextDayDate = DUMMY_TIME2;

  DAY_OF_WEEK _dayOfWeekHijri = defaultDayOfWeek;
  DAY_OF_WEEK _dayOfWeekGrego = defaultDayOfWeek;
  DAY_OF_WEEK get dayOfWeekHijri => _dayOfWeekHijri;
  DAY_OF_WEEK get dayOfWeekGrego => _dayOfWeekGrego;

  int _hijriMonth = 1;
  bool get isMonthMuharram => _hijriMonth == 1;
  bool get isMonthSafar => _hijriMonth == 2;
  bool get isMonthRabiAlAwwal => _hijriMonth == 3;
  bool get isMonthRabiAlThani => _hijriMonth == 4;
  bool get isMonthJumadaAlAwwal => _hijriMonth == 5;
  bool get isMonthJumadaAlThani => _hijriMonth == 6;
  bool get isMonthRajab => _hijriMonth == 7;
  bool get isMonthShaaban => _hijriMonth == 8;
  bool get isMonthRamadan => _hijriMonth == 9;
  bool get isMonthShawwal => _hijriMonth == 10;
  bool get isMonthDhuAlQidah => _hijriMonth == 11;
  bool get isMonthDhuAlHijjah => _hijriMonth == 12;

  @override
  void onInit() async {
    super.onInit();

    await updateTime(); // TODO do during splash screen?

    // Initialize currDay as yesterday in case app is started after midnight.
    // This is because Athan's isha/layl are valid through currDay to fajr of
    // the next day (past 11:59PM of currDay). So we must give user ability to
    // start/install app at night and not wait for next day fajr to start
    // performing quests.
    currDay = dateToDay(dateToYesterday(await now()));
    currDayDate = TZDateTime.from(DateTime.parse(currDay), tzLoc);
    nextDayDate = dateToTomorrow(currDayDate);

    // times should be initialized, so start Zaman Controller on initx
    if (!ZamanC.to.isInitialized) {
      // Need to wait for user login so we can init quest in zaman controller
      await AuthC.to.waitForFirebaseLogin('TimeC.onInit');
      ZamanC.to.updateZaman();
    }
  }

  DateTime dateToYesterday(DateTime dT) => dT.subtract(const Duration(days: 1));
  DateTime dateToTomorrow(DateTime dT) => dT.add(const Duration(days: 1));

  /// Call to update time TODO use to detect irregular clock movement
  Future<void> updateTime() async {
    l.d('updateTime: start: ntpOffset=$_ntpOffset, tzLoc=$tzLoc');
    await _updateNtpTime();
    await _updateTimezoneLocation();
    l.d('updateTime: after: ntpOffset=$_ntpOffset, tzLoc=$tzLoc');
    thisYear = TimeC.to.now2().year;
    update();
  }

  /// Gets NTP time from server when called, if internet is on
  Future<void> _updateNtpTime() async {
    if (!ConnectivityC.to.isInternetOn) {
      l.w('updateNtpTime: aborting NTP update, no internet connection');
      return;
    }
    l.d('updateNtpTime: Called');
    DateTime appTime = DateTime.now().toLocal();
    try {
      _ntpOffset = await NTP.getNtpOffset(
          localTime: appTime, timeout: const Duration(seconds: 3)); // TODO
      DateTime ntpTime = appTime.add(Duration(milliseconds: _ntpOffset));

      l.d('updateNtpTime: NTP DateTime offset align (ntpOffset=$_ntpOffset):');
      l.d('updateNtpTime: locTime was=${appTime.toLocal()}');
      l.d('updateNtpTime: ntpTime now=${ntpTime.toLocal()}');
    } on Exception catch (e) {
      l.e('updateNtpTime: Exception: Failed to call NTP.getNtpOffset(): $e');
    }
  }

  /// Get's local time, uses ntp offset to calculate more accurate time
  Future<DateTime> now() async {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('now: called but there is no ntp offset');
      await _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    l.v('now: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return TZDateTime.from(time.toLocal(), tzLoc);
  }

  /// Non-async version to get time now()
  DateTime now2() {
    if (_ntpOffset == DUMMY_NTP_OFFSET) {
      l.w('now2: called but there is no ntp offset');
      _updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset != DUMMY_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset));
    }
    l.v('now2: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return TZDateTime.from(time.toLocal(), tzLoc);
  }

  /// TODO Test other platforms:
  /// Gets the systems timezone, i.e. Android, iOS reported timezone, or null
  Future<Location?> _getTimezoneLocFromSystem() async {
    Location? timezoneLoc;
    try {
      String tzName = await FlutterNativeTimezone.getLocalTimezone();
      l.d('_getTimezoneFromSystem: Timezone="$tzName"');

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
    l.d('_getTimezoneFromTimeDate: Time Zone="$tzName"'); // 'America/Los_Angeles'

    try {
      tzLocation = getLocation(tzName);
    } on LocationNotFoundException catch (err) {
      if (tzLoc.name == DUMMY_TIMEZONE) {
        l.e('$err\ntimezone "$tzName" not found by getLocation, using existing: $tzLoc');
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
    tzLoc = tzLocation ?? await _getTimezoneLocFromTimeDate();
  }

  updateCurrDay() async {
    String prevDay = currDay;
    currDay = dateToDay(await now());
    currDayDate = TZDateTime.from(DateTime.parse(currDay), tzLoc);
    currDayOfWeek = _getDayOfWeekGrego(currDayDate);
    nextDayDate = dateToTomorrow(currDayDate);
    l.i('updateCurrDay: New day set ($currDay), prev day was ($prevDay)');
    update();
  }

  String dateToDay(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Updates day of week for hijri and gregorian Calendars. Must called after
  /// changing locale, maghrib time (new hijri time) and midnight 00:00 (hijri
  /// and gregorian date match again).
  updateDaysOfWeek() async {
    await _updateDayOfWeekHijri();
    await _updateDayOfWeekGrego();
    update();
  }

  _updateDayOfWeekHijri() async =>
      _dayOfWeekHijri = _getDayOfWeekHijri(await now());

  _updateDayOfWeekGrego() async =>
      _dayOfWeekGrego = _getDayOfWeekGrego(await now());

  /// Hijri calendar day starts at maghrib
  DAY_OF_WEEK _getDayOfWeekHijri(DateTime time) {
    DAY_OF_WEEK day = _getDayOfWeekGrego(time);
    if (iterateHijriDateByOne(time)) {
      int dayIndex = day.index + 1;
      if (dayIndex == 7) dayIndex = 0; // wrap around: if past Sunday -> Monday
      return DAY_OF_WEEK.values[dayIndex];
    }
    l.d('_getDayOfWeekHijri: ${day.name}');
    return day;
  }

  bool iterateHijriDateByOne(DateTime dT) {
    Athan? athan = ZamanC.to.athan;
    if (athan == null) return false; // TODO, wish we can avoid it at lang init
    return dT.isAfter(athan.maghrib) && dT.isBefore(nextDayDate);
  }

  /// Gregorian calendar day starts at Midnight (12:00AM)
  DAY_OF_WEEK _getDayOfWeekGrego(DateTime dT) {
    // TODO Force English Locale: works?
    String dayFromDate = DateFormat('EEEE').format(dT);

    DAY_OF_WEEK day = defaultDayOfWeek;
    for (var dayOfWeek in DAY_OF_WEEK.values) {
      if (dayFromDate == dayOfWeek.name) {
        day = dayOfWeek;
        break;
      }
    }
    l.d('_getDayOfWeekGrego: ${day.name}');
    return day;
  }

  /// NOTE: Use this isFriday for salah row header since currDay should match
  /// the header name.  If you use is _dayOfWeekHijri the header text will change
  /// after maghrib the day before and day of Jumah. Likewise using
  /// _dayOfWeekGreco, it changes at midnight but the salah row headers are
  /// still using the day before until Fajr Tomorrow. So these realtime values
  /// are not always desired to show the day of the week.
  bool isFriday() => currDayOfWeek == DAY_OF_WEEK.Friday;

  String trValDateHijri(bool addDayOfWeek) {
    DateTime dT = now2(); // TODO use now()?
    if (iterateHijriDateByOne(dT)) dT = dateToTomorrow(dT);
    String dayOfWeek = '';
    if (addDayOfWeek) dayOfWeek = '${a(_dayOfWeekHijri.tk)} ';

    HijriCalendar hijriCalendar = HijriCalendar.fromDate(dT);
    _hijriMonth = hijriCalendar.hMonth;
    return '$dayOfWeek${hijriCalendar.toFormat('MMMM dd, yyyy')}';
  }

  String trValDateGrego(bool addDayOfWeek) {
    String date = DateFormat('MMMM d, yyyy').format(now2());
    bool foundMonth = false;
    for (MONTH month in MONTH.values) {
      if (date.contains(month.name)) {
        date = date.replaceFirst(month.name, a(month.tk));
        foundMonth = true;
        break;
      }
    }
    if (!foundMonth) {
      l.e('trValDateGrego: Did not find month in "$date"');
    }

    String dayOfWeek = '';
    if (addDayOfWeek) dayOfWeek = '${a(_dayOfWeekGrego.tk)} ';

    return '$dayOfWeek$date';
  }

  /// Translate Duration() to a nice format in any language's numeral set.
  static String trValDurationToTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;

    String hrStr = '';
    String minStr = '';
    String secondStr = '';

    if (duration.inHours > 0) {
      hrStr = '$hours:';
      minStr = '${minutes.remainder(60).toString().padLeft(2, '0')}:';
      secondStr = seconds.remainder(60).toString().padLeft(2, '0');
    } else {
      if (minutes > 0) {
        minStr = '$minutes:';
        secondStr = seconds.remainder(60).toString().padLeft(2, '0');
      } else {
        secondStr = '$seconds';
      }
    }

    return cns('$hrStr$minStr$secondStr');
  }

  /// Translate DateTime to a nice format in any language's numeral set.
  static String trValTime(
          DateTime? time, bool show12HourClock, bool showSecPrecision) =>
      trValTimeRange(time, null, show12HourClock, showSecPrecision);

  /// Translate DateTime (or DateTime Range) to a nice format in any lang.
  static String trValTimeRange(
    DateTime? startTime,
    DateTime? endTime,
    bool show12HourClock,
    bool showSecPrecision,
  ) {
    if (startTime == null) return '-'; // still initializing

    int startHour = startTime.hour;
    String startAmPm = '';
    if (show12HourClock) {
      if (startHour >= 12) {
        startHour -= 12;
        startAmPm = LanguageC.to.pm;
      } else {
        startAmPm = LanguageC.to.am;
      }
      if (startHour == 0) startHour = 12;
    }

    String endTimeString = '';
    if (endTime != null) {
      int endHour = endTime.hour;
      int endMinute = endTime.minute;
      String endAmPm = '';

      String minutes = endMinute.toString();
      if (endMinute < 10) minutes = '0$minutes'; // pad so looks good on UI

      String seconds = '';
      if (showSecPrecision) {
        int secs = endTime.second;
        seconds = secs.toString();
        if (secs < 10) {
          seconds = ':0$seconds';
        } else {
          seconds = ':$seconds';
        }
      }

      if (show12HourClock) {
        if (endHour >= 12) {
          endHour -= 12;
          endAmPm = LanguageC.to.pm;
        } else {
          endAmPm = LanguageC.to.am;
        }
        if (endHour == 0) endHour = 12;

        endTimeString = '-${endHour.toString()}:$minutes$seconds$endAmPm';

        // if AM/PM are same, don't show twice
        if (startAmPm == endAmPm) startAmPm = '';
      } else {
        endTimeString = '-${endHour.toString()}:$minutes$seconds';
      }
    }

    // pad hour and minutes so looks good on UI
    String hour = startHour.toString();
    if (startHour < 10) hour = '  $hour'; // NOTE: double space to align

    int startMinute = startTime.minute;
    String minutes = startMinute.toString();
    if (startMinute < 10) minutes = '0$minutes'; // pad so looks good on UI

    String seconds = '';
    if (showSecPrecision) {
      int secs = startTime.second;
      seconds = secs.toString();
      if (secs < 10) {
        seconds = ':0$seconds';
      } else {
        seconds = ':$seconds';
      }
    }

    return cns('$hour:$minutes$seconds$startAmPm$endTimeString');
  }
}
