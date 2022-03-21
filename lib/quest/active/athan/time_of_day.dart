import 'package:hapi/helpers/cord.dart';
import 'package:hapi/helpers/date_utils.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/astronomical/astronomical.dart';
import 'package:hapi/quest/active/athan/astronomical/solar_time.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/tod.dart';
import 'package:timezone/timezone.dart';

/// TODO Test against other athan libraries and software.
class TimeOfDay {
  final Cord cord;
  final DateTime date;
  final CalculationParams params;
  final Location tzLoc; // timezone
  final bool precision;

  late DateTime _fajr_01;
  late DateTime _kerahatAdkharSunrise_02; // sunrise - kerahat 1
  late DateTime _ishraqPrayer_03;
  late DateTime _duhaPrayer_04;
  late DateTime _kerahatAdkharZawal_05; // sun zenith/peak - kerahat 2
  late DateTime _dhuhr_06;
  late DateTime _asr_07;
  late DateTime _kerahatAdkharSunSetting_08; // sun begins setting - kerahat 3
  late DateTime _maghrib_09; // actual sunset
  late DateTime _isha_10;
  late DateTime _middleOfNight_11;
  late DateTime _last3rdOfNight_12;
  late DateTime _fajrTomorrow_13;
  late DateTime _sunriseTomorrow_14;
  DateTime get fajr => _fajr_01;
  DateTime get sunrise => _kerahatAdkharSunrise_02;
  DateTime get ishraq => _ishraqPrayer_03;
  DateTime get duha => _duhaPrayer_04;
  DateTime get zawal => _kerahatAdkharZawal_05;
  DateTime get dhuhr => _dhuhr_06;
  DateTime get asr => _asr_07;
  DateTime get sunSetting => _kerahatAdkharSunSetting_08;
  DateTime get maghrib => _maghrib_09;
  DateTime get isha => _isha_10;
  DateTime get middleOfNight => _middleOfNight_11;
  DateTime get last3rdOfNight => _last3rdOfNight_12;
  DateTime get fajrTomorrow => _fajrTomorrow_13;
  DateTime get sunriseTomorrow => _sunriseTomorrow_14;

  // TODO: added precision
  // rounded nightfraction
  TimeOfDay(
    this.cord,
    this.date,
    this.params,
    this.tzLoc,
    this.precision,
  ) {
    CalcMethodParams method = params.method;

    SolarTime solarTime = SolarTime(date, cord);

    // DateTime dateYesterday = date.subtract(Duration(days: 1));
    // SolarTime solarTimeYesterday = SolarTime(dateYesterday, coordinates);

    DateTime dateTomorrow = date.add(const Duration(days: 1));
    SolarTime solarTimeTomorrow = SolarTime(dateTomorrow, cord);

    // todo
    // print(calculationParameters.ishaAngle);
    //DateTime ishaYesterdayTime;
    DateTime fajrTime;
    DateTime asrTime;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime fajrTomorrowTime;

    double? nightFraction;

    DateTime dhuhrTime = TimeComponent(solarTime.transit)
        .utcDate(date.year, date.month, date.day);
    DateTime sunriseTime = TimeComponent(solarTime.sunrise)
        .utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = TimeComponent(solarTime.sunset)
        .utcDate(date.year, date.month, date.day);

    DateTime sunriseTimeTomorrow = TimeComponent(solarTimeTomorrow.sunrise)
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);
    // DateTime sunsetTimeYesteray = TimeComponents(solarTimeYesterday.sunset)
    //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);

    asrTime = TimeComponent(solarTime.afternoon(params.madhab.shadowLength))
        .utcDate(date.year, date.month, date.day);

    int nightDurationInSecs =
        (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;

    fajrTime =
        TimeComponent(solarTime.hourAngle(-1 * params.method.fajrAngle, false))
            .utcDate(date.year, date.month, date.day);

    fajrTomorrowTime =
        TimeComponent(solarTimeTomorrow.hourAngle(-1 * method.fajrAngle, false))
            .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);

    // special case for moonsighting committee above latitude 55
    if (method.calcMethod == CalcMethod.Moonsight_Committee &&
        cord.latitude >= 55) {
      nightFraction = nightDurationInSecs / 7;
      fajrTime = dateByAddingSeconds(sunriseTime, -nightFraction.round());
      fajrTomorrowTime =
          dateByAddingSeconds(sunriseTimeTomorrow, -nightFraction.round());
    }

    DateTime safeFajr(DateTime day) {
      if (method.calcMethod == CalcMethod.Moonsight_Committee) {
        return Astronomical.seasonAdjustedMorningTwilight(
            cord.latitude, dayOfYear(day), day.year, sunriseTime);
      } else {
        double portion = params.nightPortions()[SalahAdjust.fajr]!;
        nightFraction = portion * nightDurationInSecs;
        return dateByAddingSeconds(sunriseTime, -nightFraction!.round());
      }
    }

    if (fajrTime.millisecondsSinceEpoch == double.nan ||
        safeFajr(date).isAfter(fajrTime)) {
      fajrTime = safeFajr(date);
    }

    if (fajrTomorrowTime.millisecondsSinceEpoch == double.nan ||
        safeFajr(dateTomorrow).isAfter(fajrTomorrowTime)) {
      fajrTomorrowTime = safeFajr(dateTomorrow);
    }

    if (method.ishaIntervalMins > 0) {
      ishaTime = dateByAddingMinutes(sunsetTime, method.ishaIntervalMins);
      // ishaYesterdayTime = dateByAddingMinutes(
      //     sunsetTimeYesteray, calculationParameters.ishaInterval);
    } else {
      ishaTime = TimeComponent(solarTime.hourAngle(-1 * method.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      // ishaYesterdayTime = TimeComponents(solarTimeYesterday.hourAngle(
      //         -1 * calculationParameters.ishaAngle, true))
      //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);
      // special case for moonsighting committee above latitude 55
      if (method.calcMethod == CalcMethod.Moonsight_Committee &&
          cord.latitude >= 55) {
        nightFraction = nightDurationInSecs / 7;
        ishaTime = dateByAddingSeconds(sunsetTime, nightFraction!.round());
        // ishaYesterdayTime =
        //     dateByAddingSeconds(sunsetTimeYesteray, nightFraction!.round());
      }

      DateTime safeIsha(DateTime day) {
        if (method.calcMethod == CalcMethod.Moonsight_Committee) {
          return Astronomical.seasonAdjustedEveningTwilight(
              cord.latitude, dayOfYear(day), day.year, sunsetTime);
        } else {
          double portion = params.nightPortions()[SalahAdjust.isha]!;
          nightFraction = portion * nightDurationInSecs;
          return dateByAddingSeconds(sunsetTime, nightFraction!.round());
        }
      }

      if (ishaTime.millisecondsSinceEpoch == double.nan ||
          safeIsha(date).isBefore(ishaTime)) {
        ishaTime = safeIsha(date);
      }

      // if (ishaYesterdayTime.millisecondsSinceEpoch == double.nan ||
      //     safeIsha(dateYesterday).isBefore(ishaYesterdayTime)) {
      //   ishaYesterdayTime = safeIsha(dateYesterday);
      // }
    }

    maghribTime = sunsetTime;
    if (method.maghribAngle > 0.0) {
      DateTime angleBasedMaghrib =
          TimeComponent(solarTime.hourAngle(-1 * method.maghribAngle, true))
              .utcDate(date.year, date.month, date.day);
      if (sunsetTime.isBefore(angleBasedMaghrib) &&
          ishaTime.isAfter(angleBasedMaghrib)) {
        maghribTime = angleBasedMaghrib;
      }
    }

    final Map<SalahAdjust, int> salahAdjustments = {};
    for (SalahAdjust salahAdjust in SalahAdjust.values) {
      salahAdjustments[salahAdjust] = params.adjustments[salahAdjust]! +
          method.methodAdjustments[salahAdjust]!;
    }

    // _ishaYesterday = getTime(ishaYesterdayTime, ishaAdjustment);

    _fajr_01 = getTime(fajrTime, salahAdjustments[SalahAdjust.fajr]!);
    _kerahatAdkharSunrise_02 =
        getTime(sunriseTime, salahAdjustments[SalahAdjust.sunrise]!);
    _ishraqPrayer_03 = getTZ(_kerahatAdkharSunrise_02.add(
      Duration(minutes: params.kerahatSunRisingMins),
    ));
    _duhaPrayer_04 = getTZ(_ishraqPrayer_03.add(
      const Duration(minutes: 10), // TODO 10 minutes good?
    ));
    _dhuhr_06 = getTime(dhuhrTime, salahAdjustments[SalahAdjust.dhuhr]!);
    _kerahatAdkharZawal_05 = getTZ(_dhuhr_06.subtract(
      Duration(minutes: params.kerahatSunZawalMins),
    ));
    _asr_07 = getTime(asrTime, salahAdjustments[SalahAdjust.asr]!);
    _maghrib_09 = getTime(maghribTime, salahAdjustments[SalahAdjust.maghrib]!);
    _kerahatAdkharSunSetting_08 = _maghrib_09.subtract(
      Duration(minutes: params.kerahatSunSettingMins),
    );
    _isha_10 = getTime(ishaTime, salahAdjustments[SalahAdjust.isha]!);

    _fajrTomorrow_13 =
        getTime(fajrTomorrowTime, salahAdjustments[SalahAdjust.fajr]!);
    _sunriseTomorrow_14 =
        getTime(sunriseTimeTomorrow, salahAdjustments[SalahAdjust.sunrise]!);

    // Sunnah Times
    Duration nightDuration = _fajrTomorrow_13.difference(_maghrib_09);
    _middleOfNight_11 = roundedMinute(
        dateByAddingSeconds(_maghrib_09, (nightDuration.inSeconds / 2).floor()),
        precision: precision);
    _last3rdOfNight_12 = roundedMinute(
        dateByAddingSeconds(
            _maghrib_09, (nightDuration.inSeconds * (2 / 3)).floor()),
        precision: precision);

    // Convenience Utilities
    l.v('***** Current Local Time: $date');
    l.v('***** Time Zone: "${date.timeZoneName}"');

    l.v('***** Times Of Day:');
    //v('isha yesterday:   $_ishaYesterday');
    l.v('fajr:             $_fajr_01');
    l.v('sunrise:          $_kerahatAdkharSunrise_02');
    l.v('ishrak:           $_ishraqPrayer_03');
    l.v('duha:             $_duhaPrayer_04');
    l.v('zawal:            $_kerahatAdkharZawal_05');
    l.v('dhuhr:            $_dhuhr_06');
    l.v('asr:              $_asr_07');
    l.v('sunset:           $_kerahatAdkharSunSetting_08');
    l.v('maghrib:          $_maghrib_09');
    l.v('isha:             $_isha_10');
    l.v('middleOfight:     $_middleOfNight_11');
    l.v('last3rdOfNight:   $_last3rdOfNight_12');
    l.v('fajr tomorrow:    $_fajrTomorrow_13');
    l.v('sunrise tomorrow: $_sunriseTomorrow_14');
  }

  DateTime getTime(DateTime date, int adjustment) {
    return getTZ(roundedMinute(dateByAddingMinutes(date, adjustment),
        precision: precision));
  }

  DateTime getTZ(DateTime date) {
    return TZDateTime.from(date, tzLoc);
  }

  DateTime getZamanTime(TOD tod) {
    if (tod == TOD.Fajr) {
      return _fajr_01;
    } else if (tod == TOD.Kerahat_Sunrise) {
      return _kerahatAdkharSunrise_02;
    } else if (tod == TOD.Ishraq) {
      return _ishraqPrayer_03;
    } else if (tod == TOD.Duha) {
      return _duhaPrayer_04;
    } else if (tod == TOD.Kerahat_Zawal) {
      return _kerahatAdkharZawal_05;
    } else if (tod == TOD.Dhuhr) {
      return _dhuhr_06;
    } else if (tod == TOD.Asr) {
      return _asr_07;
    } else if (tod == TOD.Kerahat_Sun_Setting) {
      return _kerahatAdkharSunSetting_08;
    } else if (tod == TOD.Maghrib) {
      return _maghrib_09;
    } else if (tod == TOD.Isha) {
      return _isha_10;
    } else if (tod == TOD.Night__2) {
      return _middleOfNight_11;
    } else if (tod == TOD.Night__3) {
      return _last3rdOfNight_12;
    } else if (tod == TOD.Fajr_Tomorrow) {
      return _fajrTomorrow_13;
    } else if (tod == TOD.Sunrise_Tomorrow) {
      return _sunriseTomorrow_14;
    } else {
      l.e('TimeOfDay:getZamanTime: unknown zaman: "$tod"');
      return _dhuhr_06;
    }
  }

  TOD getCurrZaman(DateTime date) {
    final ActiveQuestsController c = ActiveQuestsController.to;

    if (date.isAfter(_sunriseTomorrow_14)) {
      return TOD.Sunrise_Tomorrow;
    } else if (date.isAfter(_fajrTomorrow_13)) {
      return TOD.Fajr_Tomorrow;
    } else if (c.showLast3rdOfNight && date.isAfter(_last3rdOfNight_12)) {
      return TOD.Night__3;
    } else if (!c.showLast3rdOfNight && date.isAfter(_middleOfNight_11)) {
      return TOD.Night__2;
    } else if (date.isAfter(_isha_10)) {
      return TOD.Isha;
    } else if (date.isAfter(_maghrib_09)) {
      return TOD.Maghrib;
    } else if (date.isAfter(_kerahatAdkharSunSetting_08)) {
      return TOD.Kerahat_Sun_Setting;
    } else if (date.isAfter(_asr_07)) {
      return TOD.Asr;
    } else if (date.isAfter(_dhuhr_06)) {
      return TOD.Dhuhr;
    } else if (date.isAfter(_kerahatAdkharZawal_05)) {
      return TOD.Kerahat_Zawal;
    } else if (date.isAfter(_duhaPrayer_04)) {
      return TOD.Duha;
    } else if (date.isAfter(_ishraqPrayer_03)) {
      return TOD.Ishraq;
    } else if (date.isAfter(_kerahatAdkharSunrise_02)) {
      return TOD.Kerahat_Sunrise;
    } else if (date.isAfter(_fajr_01)) {
      return TOD.Fajr;
    } else {
      l.e('getCurrZaman $date is not after fajr');
      return TOD.Fajr;
    }
  }

  TOD getNextZaman(DateTime date) {
    final ActiveQuestsController c = ActiveQuestsController.to;

    if (date.isAfter(_fajrTomorrow_13)) {
      return TOD.Sunrise_Tomorrow;
    } else if (c.showLast3rdOfNight && date.isAfter(_last3rdOfNight_12)) {
      return TOD.Fajr_Tomorrow;
    } else if (!c.showLast3rdOfNight && date.isAfter(_middleOfNight_11)) {
      return TOD.Fajr_Tomorrow;
    } else if (c.showLast3rdOfNight && date.isAfter(_isha_10)) {
      return TOD.Night__3; // 1/3 of night mode
    } else if (!c.showLast3rdOfNight && date.isAfter(_isha_10)) {
      return TOD.Night__2; // middle of night mode
    } else if (date.isAfter(_maghrib_09)) {
      return TOD.Isha;
    } else if (date.isAfter(_kerahatAdkharSunSetting_08)) {
      return TOD.Maghrib;
    } else if (date.isAfter(_asr_07)) {
      return TOD.Kerahat_Sun_Setting;
    } else if (date.isAfter(_dhuhr_06)) {
      return TOD.Asr;
    } else if (date.isAfter(_kerahatAdkharZawal_05)) {
      return TOD.Dhuhr;
    } else if (date.isAfter(_duhaPrayer_04)) {
      return TOD.Kerahat_Zawal;
    } else if (date.isAfter(_ishraqPrayer_03)) {
      return TOD.Duha;
    } else if (date.isAfter(_kerahatAdkharSunrise_02)) {
      return TOD.Ishraq;
    } else if (date.isAfter(_fajr_01)) {
      return TOD.Kerahat_Sunrise;
    } else {
      l.e('getNextZaman $date is not after fajr');
      return TOD.Kerahat_Sunrise;
    }
  }
}
