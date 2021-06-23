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

  DateTime? _ishaYesterday;
  DateTime? _fajr;
  DateTime? _sunrise; // sunrise - kerahat 1
  DateTime? _duha;
  DateTime? _sunZenith; // sun zenith/peak - kerahat 2
  DateTime? _dhuhr;
  DateTime? _asr;
  DateTime? _sunsetting; // sunset - kerahat 3
  DateTime? _maghrib;
  DateTime? _isha;
  DateTime? _fajrTomorrow;
  DateTime? _sunriseTomorrow;
  DateTime? get ishaYesterday => _ishaYesterday;
  DateTime? get fajr => _fajr;
  DateTime? get rising => _sunrise;
  DateTime? get duha => _duha;
  DateTime? get peaking => _sunZenith;
  DateTime? get dhuhr => _dhuhr;
  DateTime? get asr => _asr;
  DateTime? get sunsetting => _sunsetting;
  DateTime? get maghrib => _maghrib;
  DateTime? get isha => _isha;
  DateTime? get fajrTomorrow => _fajrTomorrow;
  DateTime? get sunriseTomorrow => _sunriseTomorrow;

  DateTime? _middleOfTheNight;
  DateTime? _lastThirdOfTheNight;
  DateTime? get middleOfTheNight => _middleOfTheNight;
  DateTime? get lastThirdOfTheNight => _lastThirdOfTheNight;

  Prayer _currPrayerName = Prayer.Dhuhr;
  Prayer? _nextPrayerName;
  DateTime? _currPrayerDate;
  DateTime? _nextPrayerDate;
  Prayer get currentPrayerName => _currPrayerName;
  DateTime? get currentPrayerDate => _currPrayerDate;
  Prayer? get nextPrayerName => _nextPrayerName;
  DateTime? get nextPrayerDate => _nextPrayerDate;

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

    DateTime dateYesterday = date.subtract(Duration(days: 1));
    SolarTime solarTimeYesterday = new SolarTime(dateYesterday, coordinates);

    DateTime dateTomorrow = date.add(Duration(days: 1));
    SolarTime solarTimeTomorrow = new SolarTime(dateTomorrow, coordinates);

    // todo
    // print(calculationParameters.ishaAngle);
    DateTime ishaYesterdayTime;
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
    DateTime sunsetTimeYesteray = new TimeComponents(solarTimeYesterday.sunset)
        .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);

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
      ishaYesterdayTime = dateByAddingMinutes(
          sunsetTimeYesteray, calculationParameters.ishaInterval);
    } else {
      ishaTime = new TimeComponents(
              solarTime.hourAngle(-1 * calculationParameters.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      ishaYesterdayTime = new TimeComponents(solarTimeYesterday.hourAngle(
              -1 * calculationParameters.ishaAngle, true))
          .utcDate(dateYesterday.year, dateYesterday.month, dateYesterday.day);
      // special case for moonsighting committee above latitude 55
      if (calculationParameters.salahMethod ==
              SalahMethod.Moonsight_Committee &&
          coordinates.latitude >= 55) {
        nightFraction = nightDurationInSecs / 7;
        ishaTime = dateByAddingSeconds(sunsetTime, nightFraction!.round());
        ishaYesterdayTime =
            dateByAddingSeconds(sunsetTimeYesteray, nightFraction!.round());
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

      if (ishaYesterdayTime.millisecondsSinceEpoch == double.nan ||
          safeIsha(dateYesterday).isBefore(ishaYesterdayTime)) {
        ishaYesterdayTime = safeIsha(dateYesterday);
      }
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

    _ishaYesterday = getTime(ishaYesterdayTime, ishaAdjustment);

    _fajr = getTime(fajrTime, fajrAdjustment);
    _sunrise = getTime(sunriseTime, sunriseAdjustment);
    _duha = getTZ(_sunrise!.add(
      Duration(minutes: calculationParameters.kerahatSunRisingMins),
    ));
    _dhuhr = getTime(dhuhrTime, dhuhrAdjustment);
    _sunZenith = getTZ(_dhuhr!.subtract(
      Duration(minutes: calculationParameters.kerahatSunZenithMins),
    ));
    _asr = getTime(asrTime, asrAdjustment);
    _maghrib = getTime(maghribTime, maghribAdjustment);
    _sunsetting = _maghrib!.subtract(
      Duration(minutes: calculationParameters.kerahatSunSettingMins),
    );
    _isha = getTime(ishaTime, ishaAdjustment);

    _fajrTomorrow = getTime(fajrTomorrowTime, fajrAdjustment);
    _sunriseTomorrow = getTime(sunriseTimeTomorrow, sunriseAdjustment);

    // Convenience Utilities
    _currPrayerName = currentPrayer(date);
    _currPrayerDate = timeForPrayer(_currPrayerName);

    _nextPrayerName = nextPrayer(date);
    _nextPrayerDate = timeForPrayer(_nextPrayerName!);

    // Sunnah Times
    Duration nightDuration = _fajrTomorrow!.difference(_maghrib!);
    _middleOfTheNight = roundedMinute(
        dateByAddingSeconds(_maghrib!, (nightDuration.inSeconds / 2).floor()),
        precision: precision);
    _lastThirdOfTheNight = roundedMinute(
        dateByAddingSeconds(
            _maghrib!, (nightDuration.inSeconds * (2 / 3)).floor()),
        precision: precision);

    print('***** Current Local Time: $date');
    print('***** Time Zone: "${date.timeZoneName}"');

    print('***** Prayer Times:');
    print('isha yesterday:   $_ishaYesterday');
    print('fajr:             $_fajr');
    print('sunrise:          $_sunrise');
    print('duha:             $_duha');
    print('peaking:          $_sunZenith');
    print('dhuhr:            $_dhuhr');
    print('asr:              $_asr');
    print('setting:          $_sunsetting');
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
    print('middleOfTheNight:    $_middleOfTheNight');
    print('lastThirdOfTheNight: $_lastThirdOfTheNight');
  }

  DateTime getTime(DateTime date, int adjustment) {
    return getTZ(roundedMinute(dateByAddingMinutes(date, adjustment),
        precision: precision));
  }

  DateTime getTZ(DateTime date) {
    return TZDateTime.from(date, tz);
  }

  DateTime timeForPrayer(Prayer prayer) {
    if (prayer == Prayer.Isha_Yesterday) {
      return _ishaYesterday!;
    } else if (prayer == Prayer.Fajr) {
      return _fajr!;
    } else if (prayer == Prayer.Sunrise) {
      return _sunrise!;
    } else if (prayer == Prayer.Duha) {
      return _duha!;
    } else if (prayer == Prayer.Sun_Zenith) {
      return _sunZenith!;
    } else if (prayer == Prayer.Dhuhr) {
      return _dhuhr!;
    } else if (prayer == Prayer.Asr) {
      return _asr!;
    } else if (prayer == Prayer.Sunsetting) {
      return _sunsetting!;
    } else if (prayer == Prayer.Maghrib) {
      return _maghrib!;
    } else if (prayer == Prayer.Isha) {
      return _isha!;
    } else if (prayer == Prayer.Fajr_Tomorrow) {
      return _fajrTomorrow!;
    } else if (prayer == Prayer.Sunrise_Tomorrow) {
      return _sunriseTomorrow!;
    } else {
      print('PrayerTimes:timeForPrayer: Error unknown Prayer: "$prayer"');
      return _dhuhr!;
    }
  }

  Prayer currentPrayer(DateTime date) {
    if (date.isAfter(_isha!)) {
      return Prayer.Isha;
    } else if (date.isAfter(_maghrib!)) {
      return Prayer.Maghrib;
    } else if (date.isAfter(_sunsetting!)) {
      return Prayer.Sunsetting;
    } else if (date.isAfter(_asr!)) {
      return Prayer.Asr;
    } else if (date.isAfter(_dhuhr!)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_sunZenith!)) {
      return Prayer.Sun_Zenith;
    } else if (date.isAfter(_duha!)) {
      return Prayer.Duha;
    } else if (date.isAfter(_sunrise!)) {
      return Prayer.Sunrise;
    } else if (date.isAfter(_fajr!)) {
      return Prayer.Fajr;
    } else {
      return Prayer.Isha_Yesterday;
    }
  }

  Prayer nextPrayer(DateTime date) {
    if (date.isAfter(_fajrTomorrow!)) {
      return Prayer.Sunrise_Tomorrow;
    } else if (date.isAfter(_isha!)) {
      return Prayer.Fajr_Tomorrow;
    } else if (date.isAfter(_maghrib!)) {
      return Prayer.Isha;
    } else if (date.isAfter(_sunsetting!)) {
      return Prayer.Maghrib;
    } else if (date.isAfter(_asr!)) {
      return Prayer.Sunsetting;
    } else if (date.isAfter(_dhuhr!)) {
      return Prayer.Asr;
    } else if (date.isAfter(_sunZenith!)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_duha!)) {
      return Prayer.Sun_Zenith;
    } else if (date.isAfter(_sunrise!)) {
      return Prayer.Duha;
    } else if (date.isAfter(_fajr!)) {
      return Prayer.Sunrise;
    } else {
      return Prayer.Fajr;
    }
  }
}
