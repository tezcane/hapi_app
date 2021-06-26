import 'package:hapi/quest/athan/Astronomical.dart';
import 'package:hapi/quest/athan/CalculationMethod.dart';
import 'package:hapi/quest/athan/CalculationParameters.dart';
import 'package:hapi/quest/athan/Coordinates.dart';
import 'package:hapi/quest/athan/DateUtils.dart';
import 'package:hapi/quest/athan/Madhab.dart';
import 'package:hapi/quest/athan/Prayer.dart';
import 'package:hapi/quest/athan/SolarTime.dart';
import 'package:hapi/quest/athan/TimeComponents.dart';
import 'package:timezone/timezone.dart';

class PrayerTimes {
  final Coordinates coordinates;
  final DateTime date;
  final CalculationParameters calculationParameters;
  final Location tz; // timezone
  final bool precision;

  late DateTime _fajr;
  late DateTime _sunrise; // sunrise - kerahat 1
  late DateTime _ishraq;
  late DateTime _duha;
  late DateTime _zawal; // sun zenith/peak - kerahat 2
  late DateTime _dhuhr;
  late DateTime _asr;
  late DateTime _sunSetting; // sunset - kerahat 3
  late DateTime _maghrib;
  late DateTime _isha;
  late DateTime _middleOfNight;
  late DateTime _last3rdOfNight;
  late DateTime _fajrTomorrow;
  late DateTime _sunriseTomorrow;
  DateTime get fajr => _fajr;
  DateTime get sunrise => _sunrise;
  DateTime get ishraq => _ishraq;
  DateTime get duha => _duha;
  DateTime get zawal => _zawal;
  DateTime get dhuhr => _dhuhr;
  DateTime get asr => _asr;
  DateTime get sunSetting => _sunSetting;
  DateTime get maghrib => _maghrib;
  DateTime get isha => _isha;
  DateTime get middleOfNight => _middleOfNight;
  DateTime get last3rdOfNight => _last3rdOfNight;
  DateTime get fajrTomorrow => _fajrTomorrow;
  DateTime get sunriseTomorrow => _sunriseTomorrow;

  Prayer _currPrayerName = Prayer.Dhuhr;
  Prayer _nextPrayerName = Prayer.Asr;
  DateTime _currPrayerDate = DateTime.now();
  DateTime _nextPrayerDate = DateTime.now();
  Prayer get currPrayerName => _currPrayerName;
  Prayer get nextPrayerName => _nextPrayerName;
  DateTime get currPrayerDate => _currPrayerDate;
  DateTime get nextPrayerDate => _nextPrayerDate;

  // TODO: added precision
  // rounded nightfraction
  PrayerTimes(
    this.coordinates,
    this.date,
    this.calculationParameters,
    this.tz,
    this.precision,
  ) {
    SolarTime solarTime = new SolarTime(date, coordinates);

    // DateTime dateYesterday = date.subtract(Duration(days: 1));
    // SolarTime solarTimeYesterday = new SolarTime(dateYesterday, coordinates);

    DateTime dateTomorrow = date.add(Duration(days: 1));
    SolarTime solarTimeTomorrow = new SolarTime(dateTomorrow, coordinates);

    // todo
    // print(calculationParameters.ishaAngle);
    //DateTime ishaYesterdayTime;
    DateTime fajrTime;
    DateTime asrTime;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime fajrTomorrowTime;

    double? nightFraction;

    DateTime dhuhrTime = new TimeComponents(solarTime.transit)
        .utcDate(date.year, date.month, date.day);
    DateTime sunriseTime = new TimeComponents(solarTime.sunrise)
        .utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = new TimeComponents(solarTime.sunset)
        .utcDate(date.year, date.month, date.day);

    DateTime sunriseTimeTomorrow = new TimeComponents(solarTimeTomorrow.sunrise)
        .utcDate(dateTomorrow.year, dateTomorrow.month, dateTomorrow.day);
    // DateTime sunsetTimeYesteray = new TimeComponents(solarTimeYesterday.sunset)
    //     .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);

    asrTime = new TimeComponents(
            solarTime.afternoon(shadowLength(calculationParameters.madhab)))
        .utcDate(date.year, date.month, date.day);

    int nightDurationInSecs =
        (sunriseTimeTomorrow.difference(sunsetTime)).inSeconds;

    fajrTime = new TimeComponents(
            solarTime.hourAngle(-1 * calculationParameters.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);

    fajrTomorrowTime = new TimeComponents(solarTimeTomorrow.hourAngle(
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
      ishaTime = new TimeComponents(
              solarTime.hourAngle(-1 * calculationParameters.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      // ishaYesterdayTime = new TimeComponents(solarTimeYesterday.hourAngle(
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
      DateTime angleBasedMaghrib = new TimeComponents(solarTime.hourAngle(
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

    _fajr = getTime(fajrTime, fajrAdjustment);
    _sunrise = getTime(sunriseTime, sunriseAdjustment);
    _ishraq = getTZ(_sunrise.add(
      Duration(minutes: calculationParameters.kerahatSunRisingMins),
    ));
    _duha = getTZ(_ishraq.add(
      Duration(minutes: 10), // TODO 10 minutes good?
    ));
    _dhuhr = getTime(dhuhrTime, dhuhrAdjustment);
    _zawal = getTZ(_dhuhr.subtract(
      Duration(minutes: calculationParameters.kerahatSunZawalMins),
    ));
    _asr = getTime(asrTime, asrAdjustment);
    _maghrib = getTime(maghribTime, maghribAdjustment);
    _sunSetting = _maghrib.subtract(
      Duration(minutes: calculationParameters.kerahatSunSettingMins),
    );
    _isha = getTime(ishaTime, ishaAdjustment);

    _fajrTomorrow = getTime(fajrTomorrowTime, fajrAdjustment);
    _sunriseTomorrow = getTime(sunriseTimeTomorrow, sunriseAdjustment);

    // Sunnah Times
    Duration nightDuration = _fajrTomorrow.difference(_maghrib);
    _middleOfNight = roundedMinute(
        dateByAddingSeconds(_maghrib, (nightDuration.inSeconds / 2).floor()),
        precision: precision);
    _last3rdOfNight = roundedMinute(
        dateByAddingSeconds(
            _maghrib, (nightDuration.inSeconds * (2 / 3)).floor()),
        precision: precision);

    // Convenience Utilities
    _currPrayerName = currentPrayer(date);
    _currPrayerDate = timeForPrayer(_currPrayerName);

    _nextPrayerName = nextPrayer(date);
    _nextPrayerDate = timeForPrayer(_nextPrayerName);

    print('***** Current Local Time: $date');
    print('***** Time Zone: "${date.timeZoneName}"');

    print('***** Prayer Times:');
    //print('isha yesterday:   $_ishaYesterday');
    print('fajr:             $_fajr');
    print('sunrise:          $_sunrise');
    print('duha:             $_duha');
    print('zawal:            $_zawal');
    print('dhuhr:            $_dhuhr');
    print('asr:              $_asr');
    print('setting:          $_sunSetting');
    print('maghrib:          $_maghrib');
    print('isha:             $_isha');
    print('fajr tomorrow:    $_fajrTomorrow');
    print('sunrise tomorrow: $_sunriseTomorrow');

    print('***** Convenience Utilities:');
    print('current: $_currPrayerDate ($_currPrayerName)');
    print('next:    $_nextPrayerDate ($_nextPrayerName)');

    print('***** Sunnah Times:');
    //print('night duration secs: $nightDurationInSecs');
    print('night duration secs: ${nightDuration.inSeconds}');
    print('middleOfTheNight:    $_middleOfNight');
    print('lastThirdOfTheNight: $_last3rdOfNight');
  }

  DateTime getTime(DateTime date, int adjustment) {
    return getTZ(roundedMinute(dateByAddingMinutes(date, adjustment),
        precision: precision));
  }

  DateTime getTZ(DateTime date) {
    return TZDateTime.from(date, tz);
  }

  DateTime timeForPrayer(Prayer prayer) {
    if (prayer == Prayer.Fajr) {
      return _fajr;
    } else if (prayer == Prayer.Sunrise) {
      return _sunrise;
    } else if (prayer == Prayer.Ishraq) {
      return _ishraq;
    } else if (prayer == Prayer.Duha) {
      return _duha;
    } else if (prayer == Prayer.Zawal) {
      return _zawal;
    } else if (prayer == Prayer.Dhuhr) {
      return _dhuhr;
    } else if (prayer == Prayer.Asr) {
      return _asr;
    } else if (prayer == Prayer.Sun_Setting) {
      return _sunSetting;
    } else if (prayer == Prayer.Maghrib) {
      return _maghrib;
    } else if (prayer == Prayer.Isha) {
      return _isha;
    } else if (prayer == Prayer.Last_1__3_of_Night) {
      return _last3rdOfNight;
    } else if (prayer == Prayer.Fajr_Tomorrow) {
      return _fajrTomorrow;
    } else if (prayer == Prayer.Sunrise_Tomorrow) {
      return _sunriseTomorrow;
    } else {
      print('PrayerTimes:timeForPrayer: Error unknown Prayer: "$prayer"');
      return _dhuhr;
    }
  }

  Prayer currentPrayer(DateTime date) {
    if (date.isAfter(_sunriseTomorrow)) {
      return Prayer.Sunrise_Tomorrow;
    } else if (date.isAfter(_fajrTomorrow)) {
      return Prayer.Fajr_Tomorrow;
    } else if (date.isAfter(_last3rdOfNight)) {
      return Prayer.Last_1__3_of_Night;
    } else if (date.isAfter(_isha)) {
      return Prayer.Isha;
    } else if (date.isAfter(_maghrib)) {
      return Prayer.Maghrib;
    } else if (date.isAfter(_sunSetting)) {
      return Prayer.Sun_Setting;
    } else if (date.isAfter(_asr)) {
      return Prayer.Asr;
    } else if (date.isAfter(_dhuhr)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_zawal)) {
      return Prayer.Zawal;
    } else if (date.isAfter(_duha)) {
      return Prayer.Duha;
    } else if (date.isAfter(_ishraq)) {
      return Prayer.Ishraq;
    } else if (date.isAfter(_sunrise)) {
      return Prayer.Sunrise;
    } else if (date.isAfter(_fajr)) {
      return Prayer.Fajr;
    } else {
      return Prayer.Fajr;
    }
  }

  Prayer nextPrayer(DateTime date) {
    if (date.isAfter(_fajrTomorrow)) {
      return Prayer.Sunrise_Tomorrow;
    } else if (date.isAfter(_last3rdOfNight)) {
      return Prayer.Fajr_Tomorrow;
    } else if (date.isAfter(_isha)) {
      return Prayer.Last_1__3_of_Night;
    } else if (date.isAfter(_maghrib)) {
      return Prayer.Isha;
    } else if (date.isAfter(_sunSetting)) {
      return Prayer.Maghrib;
    } else if (date.isAfter(_asr)) {
      return Prayer.Sun_Setting;
    } else if (date.isAfter(_dhuhr)) {
      return Prayer.Asr;
    } else if (date.isAfter(_zawal)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_duha)) {
      return Prayer.Zawal;
    } else if (date.isAfter(_ishraq)) {
      return Prayer.Duha;
    } else if (date.isAfter(_sunrise)) {
      return Prayer.Ishraq;
    } else if (date.isAfter(_fajr)) {
      return Prayer.Sunrise;
    } else {
      return Prayer.Sunrise;
    }
  }
}
