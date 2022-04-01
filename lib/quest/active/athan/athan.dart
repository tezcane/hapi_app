import 'package:flutter/material.dart';
import 'package:hapi/helpers/cord.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/astronomical/astronomical.dart';
import 'package:hapi/quest/active/athan/astronomical/solar_time.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:timezone/timezone.dart';

/// Get all the prayer and other times needed to track important salah and
/// islamic activity around a single day.
class Athan {
  Athan(this.params, this.date, this.cord, this.tzLoc, this.precision) {
    _calculateTimes();
  }

  final CalculationParams params;
  final DateTime date;
  final Cord cord;
  final Location tzLoc; // timezone
  final bool precision;

  // _calculateTimes() must initialize all this:
  late final DateTime _fajr_01;
  late final DateTime _karahatAdkharSunrise_02; // sunrise - karahat 1
  late final DateTime _ishraqPrayer_03;
  late final DateTime _duhaPrayer_04;
  late final DateTime _karahatAdkharZawal_05; // sun zenith/peak - karahat 2
  late final DateTime _highNoon; // used for radian correction
  late final DateTime _dhuhr_06;
  late final DateTime _asrEarlier_07;
  late final DateTime _asrLater_08;
  late final DateTime _karahatAdkharSunSetting_09; // sun setting - karahat 3
  late final DateTime _maghrib_10; // actual sunset
  late final DateTime _isha_11;
  late final DateTime _middleOfNight_12;
  late final DateTime _last3rdOfNight_13;
  late final DateTime _fajrTomorrow_14;
  DateTime get fajr => _fajr_01;
  DateTime get sunrise => _karahatAdkharSunrise_02;
  DateTime get ishraq => _ishraqPrayer_03;
  DateTime get duha => _duhaPrayer_04;
  DateTime get zawal => _karahatAdkharZawal_05;
  DateTime get highNoon => _highNoon;
  DateTime get dhuhr => _dhuhr_06;
  DateTime get asr =>
      params.madhab == Madhab.Hanafi ? _asrLater_08 : _asrEarlier_07;
  DateTime get asrEarlier => _asrEarlier_07;
  DateTime get asrLater => _asrLater_08;
  DateTime get sunSetting => _karahatAdkharSunSetting_09;
  DateTime get maghrib => _maghrib_10;
  DateTime get isha => _isha_11;
  DateTime get layl => ActiveQuestsController.to.showLast3rdOfNight
      ? _last3rdOfNight_13
      : _middleOfNight_12;
  DateTime get middleOfNight => _middleOfNight_12;
  DateTime get last3rdOfNight => _last3rdOfNight_13;
  DateTime get fajrTomorrow => _fajrTomorrow_14;

  void _calculateTimes() {
    CalcMethodParams method = params.method;

    SolarTime solarTime = SolarTime(date, cord);

    // DateTime dateYesterday = date.subtract(Duration(days: 1));
    // SolarTime solarTimeYesterday = SolarTime(dateYesterday, coordinates);

    DateTime dateTomorrow = date.add(const Duration(days: 1));
    SolarTime solarTimeTomorrow = SolarTime(dateTomorrow, cord);

    //DateTime ishaYesterdayTime;
    DateTime fajrTime;
    DateTime asrTimeEarlier;
    DateTime asrTimeLater;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime fajrTomorrowTime;

    // sun at zenith
    _highNoon = _TimeComponent(solarTime.transit)
        .utcDate(date.year, date.month, date.day);
    DateTime sunriseTime = _TimeComponent(solarTime.sunrise)
        .utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = _TimeComponent(solarTime.sunset)
        .utcDate(date.year, date.month, date.day);

    DateTime sunriseTimeTomorrow = _TimeComponent(solarTimeTomorrow.sunrise)
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);
    // DateTime sunsetTimeYesterday = TimeComponents(solarTimeYesterday.sunset)
    //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);

    asrTimeEarlier =
        _TimeComponent(solarTime.afternoon(Madhab.Shafi.asrShadowLength))
            .utcDate(date.year, date.month, date.day);
    asrTimeLater =
        _TimeComponent(solarTime.afternoon(Madhab.Hanafi.asrShadowLength))
            .utcDate(date.year, date.month, date.day);

    fajrTime = _TimeComponent(solarTime.hourAngle(-1 * method.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);

    fajrTomorrowTime = _TimeComponent(
            solarTimeTomorrow.hourAngle(-1 * method.fajrAngle, false))
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);

    // special case for moonsighting committee above latitude 55
    if (method.calcMethod == CalcMethod.Moonsight_Committee &&
        cord.latitude >= 55) {
      int nightDurationInSecs =
          (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;
      double nightFraction = nightDurationInSecs / 7;
      fajrTime = sunriseTime.subtract(Duration(seconds: nightFraction.round()));
      fajrTomorrowTime = sunriseTimeTomorrow
          .subtract(Duration(seconds: nightFraction.round()));
    }

    DateTime safeFajrTime =
        _safeFajr(date, sunriseTime, sunsetTime, sunriseTimeTomorrow);
    if (fajrTime.millisecondsSinceEpoch == double.nan ||
        safeFajrTime.isAfter(fajrTime)) {
      l.w('Using safe Fajr time=$safeFajrTime (is after fajrTime=$fajrTime)');
      fajrTime = safeFajrTime;
    }

    DateTime safeFajrTomorrowTime =
        _safeFajr(dateTomorrow, sunriseTime, sunsetTime, sunriseTimeTomorrow);
    if (fajrTomorrowTime.millisecondsSinceEpoch == double.nan ||
        safeFajrTomorrowTime.isAfter(fajrTomorrowTime)) {
      l.w('Using Safe Fajr Tomorrow Time=$safeFajrTomorrowTime (is after fajrTomorrowTime=$fajrTomorrowTime)');
      fajrTomorrowTime = safeFajrTomorrowTime;
    }

    if (method.ishaIntervalMins > 0) {
      ishaTime =
          sunsetTime.add(Duration(seconds: method.ishaIntervalMins * 60));
      // ishaYesterdayTime = dateByAddingMinutes(
      //     sunsetTimeYesterday, calculationParameters.ishaInterval);
    } else {
      ishaTime = _TimeComponent(solarTime.hourAngle(-method.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      // ishaYesterdayTime = TimeComponents(solarTimeYesterday.hourAngle(
      //         -1 * calculationParameters.ishaAngle, true))
      //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);
      // special case for moonsighting committee above latitude 55
      if (method.calcMethod == CalcMethod.Moonsight_Committee &&
          cord.latitude >= 55) {
        int nightDurationInSecs =
            (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;
        double nightFraction = nightDurationInSecs / 7;
        ishaTime = sunsetTime.add(Duration(seconds: nightFraction.round()));
        // ishaYesterdayTime =
        //     dateByAddingSeconds(sunsetTimeYesterday, nightFraction.round());
      }

      DateTime safeIshaTime = _safeIsha(date, sunsetTime, sunriseTimeTomorrow);
      if (ishaTime.millisecondsSinceEpoch == double.nan ||
          safeIshaTime.isBefore(ishaTime)) {
        l.w('Using safe Isha time=$safeIshaTime (is before ishaTime=$ishaTime)');
        ishaTime = safeIshaTime;
      }

      // if (ishaYesterdayTime.millisecondsSinceEpoch == double.nan ||
      //     safeIsha(dateYesterday).isBefore(ishaYesterdayTime)) {
      //   ishaYesterdayTime = safeIsha(dateYesterday);
      // }
    }

    maghribTime = sunsetTime;
    if (method.maghribAngle > 0.0) {
      DateTime angleBasedMaghrib =
          _TimeComponent(solarTime.hourAngle(-method.maghribAngle, true))
              .utcDate(date.year, date.month, date.day);
      if (sunsetTime.isBefore(angleBasedMaghrib) &&
          ishaTime.isAfter(angleBasedMaghrib)) {
        l.w('Using angle based maghrib time=$angleBasedMaghrib  (sunsetTime=$sunsetTime is before it and ishaTime=$ishaTime is after it)');
        maghribTime = angleBasedMaghrib;
      }
    }

    // _ishaYesterday = getTime(ishaYesterdayTime, ishaAdjustment);

    _fajr_01 = _addSecsRoundUpAndGetTZ(
      fajrTime,
      method.adjustSecs[Salah.fajr]!,
    );
    _karahatAdkharSunrise_02 = _addSecsRoundDnAndGetTZ(
      sunriseTime,
      method.adjustSecs[Salah.sunrise]!,
    );
    _ishraqPrayer_03 = _addSecsRoundUpAndGetTZ(
      _karahatAdkharSunrise_02,
      params.karahatSunRisingSecs,
    );
    _duhaPrayer_04 = _addSecsRoundUpAndGetTZ(
      _ishraqPrayer_03,
      900, // 15 mins (15 * 60 = 900), TODO 15 minutes good?
    );

    // NOTE: Subtracts half of karahat time from zenith/high noon
    _karahatAdkharZawal_05 = _subtractSecsRoundDnAndGetTZ(
      _highNoon,
      -method.adjustSecs[Salah.dhuhr]! + (params.karahatSunZawalSecs ~/ 2),
    );
    _dhuhr_06 = _addSecsRoundUpAndGetTZ(
      _karahatAdkharZawal_05,
      params.karahatSunZawalSecs, // dhuhr starts after karahat time ends
    );

    _asrEarlier_07 = _addSecsRoundUpAndGetTZ(
      asrTimeEarlier,
      method.adjustSecs[Salah.asr]!,
    );

    _asrLater_08 = _addSecsRoundUpAndGetTZ(
      asrTimeLater,
      method.adjustSecs[Salah.asr]!,
    );

    _karahatAdkharSunSetting_09 = _subtractSecsRoundDnAndGetTZ(
      maghribTime,
      -method.adjustSecs[Salah.maghrib]! + params.karahatSunSettingSecs,
    );
    _maghrib_10 = _addSecsRoundUpAndGetTZ(
      _karahatAdkharSunSetting_09,
      params.karahatSunSettingSecs,
    );

    _isha_11 = _addSecsRoundUpAndGetTZ(
      ishaTime,
      method.adjustSecs[Salah.isha]!,
    );

    _fajrTomorrow_14 = _addSecsRoundUpAndGetTZ(
      fajrTomorrowTime,
      method.adjustSecs[Salah.fajr]!,
    );

    // Sunnah Times
    // Note: nightDuration starts from maghrib time
    Duration nightDuration = _fajrTomorrow_14.difference(_maghrib_10);
    _middleOfNight_12 = _addSecsRoundUpAndGetTZ(
      _maghrib_10,
      (nightDuration.inSeconds / 2).ceil(),
    );
    _last3rdOfNight_13 = _addSecsRoundUpAndGetTZ(
      _maghrib_10,
      (nightDuration.inSeconds * (2 / 3)).ceil(),
    );

    // Convenience Utilities
    l.d('***** Current Local Time: $date *****');
    l.d('***** Time Zone: "${date.timeZoneName}" *****');
    l.d('***** Times Of Day: *****');
    //d('isha yesterday:   $_ishaYesterday');
    l.d('fajr:             $_fajr_01');
    l.d('sunrise:          $_karahatAdkharSunrise_02');
    l.d('ishrak:           $_ishraqPrayer_03');
    l.d('duha:             $_duhaPrayer_04');
    l.d('zawal:            $_karahatAdkharZawal_05');
    l.d('dhuhr:            $_dhuhr_06');
    l.d('asr earlier:      $_asrEarlier_07');
    l.d('asr later:        $_asrLater_08');
    l.d('sunset:           $_karahatAdkharSunSetting_09');
    l.d('maghrib:          $_maghrib_10');
    l.d('isha:             $_isha_11');
    l.d('middleOfNight:    $_middleOfNight_12');
    l.d('last3rdOfNight:   $_last3rdOfNight_13');
    l.d('fajr tomorrow:    $_fajrTomorrow_14');
  }

  DateTime _safeFajr(
    DateTime day,
    DateTime sunriseTime,
    DateTime sunsetTime,
    DateTime sunriseTimeTomorrow,
  ) {
    if (params.method.calcMethod == CalcMethod.Moonsight_Committee) {
      return Astronomical.seasonAdjustedMorningTwilight(
          cord.latitude, _dayOfYear(day), day.year, sunriseTime);
    } else {
      int nightDurationInSecs =
          (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;
      double portion = params.nightPortions()[Salah.fajr]!;
      double nightFraction = portion * nightDurationInSecs;
      return sunriseTime.subtract(Duration(seconds: nightFraction.round()));
    }
  }

  DateTime _safeIsha(
    DateTime day,
    DateTime sunsetTime,
    DateTime sunriseTimeTomorrow,
  ) {
    if (params.method.calcMethod == CalcMethod.Moonsight_Committee) {
      return Astronomical.seasonAdjustedEveningTwilight(
          cord.latitude, _dayOfYear(day), day.year, sunsetTime);
    } else {
      int nightDurationInSecs =
          (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;
      double portion = params.nightPortions()[Salah.isha]!;
      double nightFraction = portion * nightDurationInSecs;
      return sunsetTime.add(Duration(seconds: nightFraction.round()));
    }
  }

  DateTime _addSecsRoundUpAndGetTZ(DateTime date, int adjustSecs) =>
      TZDateTime.from(
        _roundMinuteUp(
          date.add(Duration(seconds: adjustSecs)),
        ),
        tzLoc,
      );

  DateTime _addSecsRoundDnAndGetTZ(DateTime date, int adjustSecs) =>
      TZDateTime.from(
        _roundMinuteDn(
          date.add(Duration(seconds: adjustSecs)),
        ),
        tzLoc,
      );

  DateTime _subtractSecsRoundDnAndGetTZ(DateTime date, int adjustSecs) =>
      TZDateTime.from(
        _roundMinuteDn(
          date.subtract(Duration(seconds: adjustSecs)),
        ),
        tzLoc,
      );

  /// Round time to up to next minute if there is any remaining seconds.
  /// If precision true, don't round up time to next minute
  DateTime _roundMinuteUp(DateTime date) {
    if (precision) return date;

    int offsetSecs = date.second % 60;
    if (offsetSecs == 0) {
      return date; // no time to add
    } else {
      return date.add(Duration(seconds: 60 - offsetSecs));
    }
  }

  /// Round time to down to previous minute if there is any remaining seconds.
  /// If precision true, don't round down time to previous minute
  DateTime _roundMinuteDn(DateTime date) {
    if (precision) return date;

    int offsetSecs = date.second % 60;
    if (offsetSecs == 0) {
      return date; // no time to add
    } else {
      return date.subtract(Duration(seconds: offsetSecs));
    }
  }

  int _dayOfYear(DateTime date) {
    Duration diff = date.difference(DateTime(date.year, 1, 1, 0, 0));
    int returnedDayOfYear = diff.inDays + 1; // 1st Jan should be day 1
    return returnedDayOfYear;
  }

  /// Returns Object[] - idx 0 = Z's DateTime, index 1 = sun mover circle color.
  List<Object> getZamanTime(Z z) {
    if (z == Z.Fajr) {
      return [_fajr_01, Colors.blue.shade700];
    } else if (z == Z.Karahat_Morning_Adhkar) {
      return [_karahatAdkharSunrise_02, Colors.red];
    } else if (z == Z.Ishraq) {
      return [_ishraqPrayer_03, Colors.green];
    } else if (z == Z.Duha) {
      return [_duhaPrayer_04, Colors.yellow.shade600];
    } else if (z == Z.Karahat_Zawal) {
      return [_karahatAdkharZawal_05, Colors.red.shade700];
    } else if (z == Z.Dhuhr) {
      return [_dhuhr_06, Colors.yellow.shade700];
    } else if (z == Z.Asr_Earlier) {
      return [_asrEarlier_07, Colors.yellow.shade800];
    } else if (z == Z.Asr_Later) {
      return [_asrLater_08, Colors.yellow.shade900];
    } else if (z == Z.Karahat_Evening_Adhkar) {
      return [_karahatAdkharSunSetting_09, Colors.red.shade800];
    } else if (z == Z.Maghrib) {
      return [_maghrib_10, Colors.blue.shade800];
    } else if (z == Z.Isha) {
      return [_isha_11, Colors.purple.shade700];
    } else if (z == Z.Night__2) {
      return [_middleOfNight_12, Colors.purple.shade800];
    } else if (z == Z.Night__3) {
      return [_last3rdOfNight_13, Colors.purple.shade900];
    } else if (z == Z.Fajr_Tomorrow) {
      return [_fajrTomorrow_14, Colors.pink]; // should never show
    } else {
      l.e('TimeOfDay:getZamanTime: unknown zaman: "$z"');
      return [_dhuhr_06, Colors.yellow.shade800];
    }
  }

  /// Each salah header on active quests has a start time, return it here.
  DateTime getStartTime(Z z) {
    switch (z) {
      case (Z.Fajr):
        return _fajr_01;
      case (Z.Duha):
        return _karahatAdkharSunrise_02;
      case (Z.Dhuhr):
        return _dhuhr_06;
      case (Z.Asr_Earlier):
        return _asrEarlier_07;
      case (Z.Asr_Later):
        return _asrLater_08;
      case (Z.Maghrib):
        return _maghrib_10;
      case (Z.Isha):
        return _isha_11;
      case (Z.Night__2):
        return _middleOfNight_12;
      case (Z.Night__3):
        return _last3rdOfNight_13;
      default:
        String e = 'TimeOfDay:getStartTime: unexpected zaman given: "$z"';
        l.e(e);
        throw e;
    }
  }

  Z getCurrZaman(DateTime date) {
    final ActiveQuestsController c = ActiveQuestsController.to;

    if (date.isAfter(_fajrTomorrow_14)) {
      return Z.Fajr_Tomorrow;
    } else if (c.showLast3rdOfNight && date.isAfter(_last3rdOfNight_13)) {
      return Z.Night__3;
    } else if (!c.showLast3rdOfNight && date.isAfter(_middleOfNight_12)) {
      return Z.Night__2;
    } else if (date.isAfter(_isha_11)) {
      return Z.Isha;
    } else if (date.isAfter(_maghrib_10)) {
      return Z.Maghrib;
    } else if (date.isAfter(_karahatAdkharSunSetting_09)) {
      return Z.Karahat_Evening_Adhkar;
    } else if (c.salahAsrSafe && date.isAfter(_asrLater_08)) {
      return Z.Asr_Later;
    } else if (!c.salahAsrSafe && date.isAfter(_asrEarlier_07)) {
      return Z.Asr_Earlier;
    } else if (date.isAfter(_dhuhr_06)) {
      return Z.Dhuhr;
    } else if (date.isAfter(_karahatAdkharZawal_05)) {
      return Z.Karahat_Zawal;
    } else if (date.isAfter(_duhaPrayer_04)) {
      return Z.Duha;
    } else if (date.isAfter(_ishraqPrayer_03)) {
      return Z.Ishraq;
    } else if (date.isAfter(_karahatAdkharSunrise_02)) {
      return Z.Karahat_Morning_Adhkar;
    } else if (date.isAfter(_fajr_01)) {
      return Z.Fajr;
    } else {
      l.e('getCurrZaman $date is not after fajr');
      return Z.Fajr;
    }
  }

  Z getNextZaman(DateTime date) {
    final ActiveQuestsController c = ActiveQuestsController.to;

    if (c.showLast3rdOfNight && date.isAfter(_last3rdOfNight_13)) {
      return Z.Fajr_Tomorrow;
    } else if (!c.showLast3rdOfNight && date.isAfter(_middleOfNight_12)) {
      return Z.Fajr_Tomorrow;
    } else if (c.showLast3rdOfNight && date.isAfter(_isha_11)) {
      return Z.Night__3; // 1/3 of night mode
    } else if (!c.showLast3rdOfNight && date.isAfter(_isha_11)) {
      return Z.Night__2; // middle of night mode
    } else if (date.isAfter(_maghrib_10)) {
      return Z.Isha;
    } else if (date.isAfter(_karahatAdkharSunSetting_09)) {
      return Z.Maghrib;
    } else if (c.salahAsrSafe && date.isAfter(_asrLater_08)) {
      return Z.Karahat_Evening_Adhkar;
    } else if (!c.salahAsrSafe && date.isAfter(_asrEarlier_07)) {
      return Z.Karahat_Evening_Adhkar;
    } else if (c.salahAsrSafe && date.isAfter(_dhuhr_06)) {
      return Z.Asr_Later;
    } else if (!c.salahAsrSafe && date.isAfter(_dhuhr_06)) {
      return Z.Asr_Earlier;
    } else if (date.isAfter(_karahatAdkharZawal_05)) {
      return Z.Dhuhr;
    } else if (date.isAfter(_duhaPrayer_04)) {
      return Z.Karahat_Zawal;
    } else if (date.isAfter(_ishraqPrayer_03)) {
      return Z.Duha;
    } else if (date.isAfter(_karahatAdkharSunrise_02)) {
      return Z.Ishraq;
    } else if (date.isAfter(_fajr_01)) {
      return Z.Karahat_Morning_Adhkar;
    } else {
      l.e('getNextZaman $date is not after fajr');
      return Z.Karahat_Morning_Adhkar;
    }
  }
}

class _TimeComponent {
  late final int hours;
  late final int minutes;
  late final int seconds;

  _TimeComponent(double number) {
    hours = number.floor();
    minutes = ((number - hours) * 60).floor();
    seconds = ((number - (hours + minutes / 60)) * 3600).floor();
  }

  DateTime utcDate(int year, int month, int date) =>
      DateTime.utc(year, month, date, hours, minutes, seconds);
}
