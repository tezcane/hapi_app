import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/Astronomical.dart';
import 'package:hapi/quest/active/athan/CalculationMethod.dart';
import 'package:hapi/quest/active/athan/CalculationParameters.dart';
import 'package:hapi/quest/active/athan/Coordinates.dart';
import 'package:hapi/quest/active/athan/DateUtils.dart';
import 'package:hapi/quest/active/athan/Madhab.dart';
import 'package:hapi/quest/active/athan/SolarTime.dart';
import 'package:hapi/quest/active/athan/TOD.dart';
import 'package:hapi/quest/active/athan/TimeComponents.dart';
import 'package:timezone/timezone.dart';

class TimeOfDay {
  final Coordinates coordinates;
  final DateTime date;
  final CalculationParameters calculationParameters;
  final Location tz; // timezone
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

  TOD _currTOD = TOD.Dhuhr;
  TOD _nextTOD = TOD.Asr;
  DateTime _currTODTime = DEFAULT_TIME;
  DateTime _nextTODTime = DEFAULT_TIME;
  TOD get currTOD => _currTOD;
  TOD get nextTOD => _nextTOD;
  DateTime get currTODTime => _currTODTime;
  DateTime get nextTODTime => _nextTODTime;

  // TODO: added precision
  // rounded nightfraction
  TimeOfDay(
    this.coordinates,
    this.date,
    this.calculationParameters,
    this.tz,
    this.precision,
  ) {
    SolarTime solarTime = SolarTime(date, coordinates);

    // DateTime dateYesterday = date.subtract(Duration(days: 1));
    // SolarTime solarTimeYesterday = SolarTime(dateYesterday, coordinates);

    DateTime dateTomorrow = date.add(const Duration(days: 1));
    SolarTime solarTimeTomorrow = SolarTime(dateTomorrow, coordinates);

    // todo
    // print(calculationParameters.ishaAngle);
    //DateTime ishaYesterdayTime;
    DateTime fajrTime;
    DateTime asrTime;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime fajrTomorrowTime;

    double? nightFraction;

    DateTime dhuhrTime = TimeComponents(solarTime.transit)
        .utcDate(date.year, date.month, date.day);
    DateTime sunriseTime = TimeComponents(solarTime.sunrise)
        .utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = TimeComponents(solarTime.sunset)
        .utcDate(date.year, date.month, date.day);

    DateTime sunriseTimeTomorrow = TimeComponents(solarTimeTomorrow.sunrise)
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);
    // DateTime sunsetTimeYesteray = TimeComponents(solarTimeYesterday.sunset)
    //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);

    asrTime = TimeComponents(
            solarTime.afternoon(shadowLength(calculationParameters.madhab)))
        .utcDate(date.year, date.month, date.day);

    int nightDurationInSecs =
        (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;

    fajrTime = TimeComponents(
            solarTime.hourAngle(-1 * calculationParameters.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);

    fajrTomorrowTime = TimeComponents(solarTimeTomorrow.hourAngle(
            -1 * calculationParameters.fajrAngle, false))
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);

    // special case for moonsighting committee above latitude 55
    if (calculationParameters.salahMethod == SalahMethod.Moonsight_Committee &&
        coordinates.latitude >= 55) {
      nightFraction = nightDurationInSecs / 7;
      fajrTime = dateByAddingSeconds(sunriseTime, -nightFraction.round());
      fajrTomorrowTime =
          dateByAddingSeconds(sunriseTimeTomorrow, -nightFraction.round());
    }

    DateTime safeFajr(DateTime day) {
      if (calculationParameters.salahMethod ==
          SalahMethod.Moonsight_Committee) {
        return Astronomical.seasonAdjustedMorningTwilight(
            coordinates.latitude, dayOfYear(day), day.year, sunriseTime);
      } else {
        var portion = calculationParameters.nightPortions()["fajr"];
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

    if (calculationParameters.ishaInterval > 0) {
      ishaTime =
          dateByAddingMinutes(sunsetTime, calculationParameters.ishaInterval);
      // ishaYesterdayTime = dateByAddingMinutes(
      //     sunsetTimeYesteray, calculationParameters.ishaInterval);
    } else {
      ishaTime = TimeComponents(
              solarTime.hourAngle(-1 * calculationParameters.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      // ishaYesterdayTime = TimeComponents(solarTimeYesterday.hourAngle(
      //         -1 * calculationParameters.ishaAngle, true))
      //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);
      // special case for moonsighting committee above latitude 55
      if (calculationParameters.salahMethod ==
              SalahMethod.Moonsight_Committee &&
          coordinates.latitude >= 55) {
        nightFraction = nightDurationInSecs / 7;
        ishaTime = dateByAddingSeconds(sunsetTime, nightFraction!.round());
        // ishaYesterdayTime =
        //     dateByAddingSeconds(sunsetTimeYesteray, nightFraction!.round());
      }

      DateTime safeIsha(DateTime day) {
        if (calculationParameters.salahMethod ==
            SalahMethod.Moonsight_Committee) {
          return Astronomical.seasonAdjustedEveningTwilight(
              coordinates.latitude, dayOfYear(day), day.year, sunsetTime);
        } else {
          var portion = calculationParameters.nightPortions()["isha"];
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
    if (calculationParameters.maghribAngle != null) {
      DateTime angleBasedMaghrib = TimeComponents(solarTime.hourAngle(
              -1 * calculationParameters.maghribAngle!, true))
          .utcDate(date.year, date.month, date.day);
      if (sunsetTime.isBefore(angleBasedMaghrib) &&
          ishaTime.isAfter(angleBasedMaghrib)) {
        maghribTime = angleBasedMaghrib;
      }
    }

    int fajrAdjustment = (calculationParameters.adjustments["fajr"] ?? 0) +
        (calculationParameters.methodAdjustments["fajr"] ?? 0);
    int sunriseAdjustment =
        (calculationParameters.adjustments["sunrise"] ?? 0) +
            (calculationParameters.methodAdjustments["sunrise"] ?? 0);
    int dhuhrAdjustment = (calculationParameters.adjustments["dhuhr"] ?? 0) +
        (calculationParameters.methodAdjustments["dhuhr"] ?? 0);
    int asrAdjustment = (calculationParameters.adjustments["asr"] ?? 0) +
        (calculationParameters.methodAdjustments["asr"] ?? 0);
    int maghribAdjustment =
        (calculationParameters.adjustments["maghrib"] ?? 0) +
            (calculationParameters.methodAdjustments["maghrib"] ?? 0);
    int ishaAdjustment = (calculationParameters.adjustments["isha"] ?? 0) +
        (calculationParameters.methodAdjustments["isha"] ?? 0);

    // _ishaYesterday = getTime(ishaYesterdayTime, ishaAdjustment);

    _fajr_01 = getTime(fajrTime, fajrAdjustment);
    _kerahatAdkharSunrise_02 = getTime(sunriseTime, sunriseAdjustment);
    _ishraqPrayer_03 = getTZ(_kerahatAdkharSunrise_02.add(
      Duration(minutes: calculationParameters.kerahatSunRisingMins),
    ));
    _duhaPrayer_04 = getTZ(_ishraqPrayer_03.add(
      const Duration(minutes: 10), // TODO 10 minutes good?
    ));
    _dhuhr_06 = getTime(dhuhrTime, dhuhrAdjustment);
    _kerahatAdkharZawal_05 = getTZ(_dhuhr_06.subtract(
      Duration(minutes: calculationParameters.kerahatSunZawalMins),
    ));
    _asr_07 = getTime(asrTime, asrAdjustment);
    _maghrib_09 = getTime(maghribTime, maghribAdjustment);
    _kerahatAdkharSunSetting_08 = _maghrib_09.subtract(
      Duration(minutes: calculationParameters.kerahatSunSettingMins),
    );
    _isha_10 = getTime(ishaTime, ishaAdjustment);

    _fajrTomorrow_13 = getTime(fajrTomorrowTime, fajrAdjustment);
    _sunriseTomorrow_14 = getTime(sunriseTimeTomorrow, sunriseAdjustment);

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
    _currTOD = getCurrZaman(date);
    _currTODTime = getZamanTime(_currTOD);

    _nextTOD = getNextZaman(date);
    _nextTODTime = getZamanTime(_nextTOD);

    print('***** Current Local Time: $date');
    print('***** Time Zone: "${date.timeZoneName}"');

    print('***** Times Of Day:');
    //print('isha yesterday:   $_ishaYesterday');
    print('fajr:             $_fajr_01');
    print('sunrise:          $_kerahatAdkharSunrise_02');
    print('ishrak:           $_ishraqPrayer_03');
    print('duha:             $_duhaPrayer_04');
    print('zawal:            $_kerahatAdkharZawal_05');
    print('dhuhr:            $_dhuhr_06');
    print('asr:              $_asr_07');
    print('sunset:           $_kerahatAdkharSunSetting_08');
    print('maghrib:          $_maghrib_09');
    print('isha:             $_isha_10');
    print('middleOfight:     $_middleOfNight_11');
    print('last3rdOfNight:   $_last3rdOfNight_12');
    print('fajr tomorrow:    $_fajrTomorrow_13');
    print('sunrise tomorrow: $_sunriseTomorrow_14');

    print('***** Convenience Variables:');
    print('current: $_currTODTime ($_currTOD)');
    print('next:    $_nextTODTime ($_nextTOD)');
  }

  DateTime getTime(DateTime date, int adjustment) {
    return getTZ(roundedMinute(dateByAddingMinutes(date, adjustment),
        precision: precision));
  }

  DateTime getTZ(DateTime date) {
    return TZDateTime.from(date, tz);
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
    } else if (tod == TOD.Middle_of_Night) {
      return _middleOfNight_11;
    } else if (tod == TOD.Last_1__3_of_Night) {
      return _last3rdOfNight_12;
    } else if (tod == TOD.Fajr_Tomorrow) {
      return _fajrTomorrow_13;
    } else if (tod == TOD.Sunrise_Tomorrow) {
      return _sunriseTomorrow_14;
    } else {
      print('TimeOfDay:getZamanTime: Error unknown zaman: "$tod"');
      return _dhuhr_06;
    }
  }

  TOD getCurrZaman(DateTime date) {
    if (date.isAfter(_sunriseTomorrow_14)) {
      return TOD.Sunrise_Tomorrow;
    } else if (date.isAfter(_fajrTomorrow_13)) {
      return TOD.Fajr_Tomorrow;
    } else if (cQstA.showSunnahLayl &&
        cQstA.showLast3rdOfNight &&
        date.isAfter(_last3rdOfNight_12)) {
      return TOD.Last_1__3_of_Night;
    } else if (cQstA.showSunnahLayl &&
        !cQstA.showLast3rdOfNight &&
        date.isAfter(_middleOfNight_11)) {
      return TOD.Middle_of_Night;
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
/*  } else if (date.isAfter(_fajr)) {
      return Zaman.Fajr; */
    } else {
      return TOD.Fajr;
    }
  }

  TOD getNextZaman(DateTime date) {
    if (date.isAfter(_fajrTomorrow_13)) {
      return TOD.Sunrise_Tomorrow;
    } else if (cQstA.showSunnahLayl &&
        cQstA.showLast3rdOfNight &&
        date.isAfter(_last3rdOfNight_12)) {
      return TOD.Fajr_Tomorrow;
    } else if (cQstA.showSunnahLayl &&
        !cQstA.showLast3rdOfNight &&
        date.isAfter(_middleOfNight_11)) {
      return TOD.Fajr_Tomorrow;
    } else if (date.isAfter(_isha_10)) {
      if (cQstA.showSunnahLayl) {
        if (cQstA.showLast3rdOfNight) {
          return TOD.Last_1__3_of_Night; // 1/3 of night mode
        } else {
          return TOD.Middle_of_Night; // middle of night mode
        }
      }
      return TOD.Fajr_Tomorrow; // show layl off, just show next fajr
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
/*  } else if (date.isAfter(_fajr)) {
      return Zaman.Sunrise; */
    } else {
      return TOD.Kerahat_Sunrise;
    }
  }
}
