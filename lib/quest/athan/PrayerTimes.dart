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

  DateTime? _ishaDayBefore;
  DateTime? _fajr;
  DateTime? _rising; // sunrise - kerahat 1
  DateTime? _duha;
  DateTime? _peaking; // sun zenith/peak - kerahat 2
  DateTime? _dhuhr;
  DateTime? _asr;
  DateTime? _setting; // sunset - kerahat 3
  DateTime? _maghrib;
  DateTime? _isha;
  DateTime? _fajrDayAfter;
  DateTime? get ishaDayBefore => _ishaDayBefore;
  DateTime? get fajr => _fajr;
  DateTime? get rising => _rising;
  DateTime? get duha => _duha;
  DateTime? get peaking => _peaking;
  DateTime? get dhuhr => _dhuhr;
  DateTime? get asr => _asr;
  DateTime? get setting => _setting;
  DateTime? get maghrib => _maghrib;
  DateTime? get isha => _isha;
  DateTime? get fajrDayAfter => _fajrDayAfter;

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

    DateTime dateBefore = date.subtract(Duration(days: 1));
    SolarTime solarTimeBefore = new SolarTime(dateBefore, coordinates);

    DateTime dateAfter = date.add(Duration(days: 1));
    SolarTime solarTimeAfter = new SolarTime(dateAfter, coordinates);

    // todo
    // print(calculationParameters.ishaAngle);
    DateTime ishaDayBeforeTime;
    DateTime fajrTime;
    DateTime asrTime;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime fajrDayAfterTime;

    double? nightFraction;

    DateTime dhuhrTime = new TimeComponents(solarTime.transit)
        .utcDate(date.year, date.month, date.day);
    DateTime sunriseTime = new TimeComponents(solarTime.sunrise)
        .utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = new TimeComponents(solarTime.sunset)
        .utcDate(date.year, date.month, date.day);

    DateTime sunriseafterTime = new TimeComponents(solarTimeAfter.sunrise)
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    DateTime sunsetbeforeTime = new TimeComponents(solarTimeBefore.sunset)
        .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    asrTime = new TimeComponents(
            solarTime.afternoon(shadowLength(calculationParameters.madhab)))
        .utcDate(date.year, date.month, date.day);

    DateTime tomorrow = dateByAddingDays(date, 1);
    var tomorrowSolarTime = new SolarTime(tomorrow, coordinates);
    DateTime tomorrowSunrise = new TimeComponents(tomorrowSolarTime.sunrise)
        .utcDate(tomorrow.year, tomorrow.month, tomorrow.day);
    // var night = (tomorrowSunrise - sunsetTime) / 1000;
    int night = (tomorrowSunrise.difference(sunsetTime)).inSeconds;

    fajrTime = new TimeComponents(
            solarTime.hourAngle(-1 * calculationParameters.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);

    fajrDayAfterTime = new TimeComponents(solarTimeAfter.hourAngle(
            -1 * calculationParameters.fajrAngle, false))
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);

    // special case for moonsighting committee above latitude 55
    if (calculationParameters.salahMethod == SalahMethod.Moonsight_Committee &&
        coordinates.latitude >= 55) {
      nightFraction = night / 7;
      fajrTime = dateByAddingSeconds(sunriseTime, -nightFraction.round());
      fajrDayAfterTime =
          dateByAddingSeconds(sunriseafterTime, -nightFraction.round());
    }

    DateTime safeFajr() {
      if (calculationParameters.salahMethod ==
          SalahMethod.Moonsight_Committee) {
        return Astronomical.seasonAdjustedMorningTwilight(
            coordinates.latitude, dayOfYear(date), date.year, sunriseTime);
      } else {
        var portion = calculationParameters.nightPortions()["fajr"];
        nightFraction = portion * night;
        return dateByAddingSeconds(sunriseTime, -nightFraction!.round());
      }
    }

    if (fajrTime.millisecondsSinceEpoch == double.nan ||
        safeFajr().isAfter(fajrTime)) {
      fajrTime = safeFajr();
    }

    if (fajrDayAfterTime.millisecondsSinceEpoch == double.nan ||
        safeFajr().isAfter(fajrDayAfterTime)) {
      fajrDayAfterTime = safeFajr();
    }

    if (calculationParameters.ishaInterval > 0) {
      ishaTime =
          dateByAddingMinutes(sunsetTime, calculationParameters.ishaInterval);
      ishaDayBeforeTime = dateByAddingMinutes(
          sunsetbeforeTime, calculationParameters.ishaInterval);
    } else {
      ishaTime = new TimeComponents(
              solarTime.hourAngle(-1 * calculationParameters.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      ishaDayBeforeTime = new TimeComponents(solarTimeBefore.hourAngle(
              -1 * calculationParameters.ishaAngle, true))
          .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);
      // special case for moonsighting committee above latitude 55
      if (calculationParameters.salahMethod ==
              SalahMethod.Moonsight_Committee &&
          coordinates.latitude >= 55) {
        nightFraction = night / 7;
        ishaTime = dateByAddingSeconds(sunsetTime, nightFraction!.round());
        ishaDayBeforeTime =
            dateByAddingSeconds(sunsetbeforeTime, nightFraction!.round());
      }

      DateTime safeIsha() {
        if (calculationParameters.salahMethod ==
            SalahMethod.Moonsight_Committee) {
          return Astronomical.seasonAdjustedEveningTwilight(
              coordinates.latitude, dayOfYear(date), date.year, sunsetTime);
        } else {
          var portion = calculationParameters.nightPortions()["isha"];
          nightFraction = portion * night;
          return dateByAddingSeconds(sunsetTime, nightFraction!.round());
        }
      }

      DateTime safeIshaBefore() {
        if (calculationParameters.salahMethod ==
            SalahMethod.Moonsight_Committee) {
          return Astronomical.seasonAdjustedEveningTwilight(
              coordinates.latitude, dayOfYear(date), date.year, sunsetTime);
        } else {
          var portion = calculationParameters.nightPortions()["isha"];
          nightFraction = portion * night;
          return dateByAddingSeconds(sunsetTime, nightFraction!.round());
        }
      }

      if (ishaTime.millisecondsSinceEpoch == double.nan ||
          safeIsha().isBefore(ishaTime)) {
        ishaTime = safeIsha();
      }

      if (ishaDayBeforeTime.millisecondsSinceEpoch == double.nan ||
          safeIshaBefore().isBefore(ishaDayBeforeTime)) {
        ishaDayBeforeTime = safeIshaBefore();
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

    _fajr = getTime(fajrTime, fajrAdjustment);
    _rising = getTime(sunriseTime, sunriseAdjustment);
    _duha = getTZ(_rising!.add(
      Duration(minutes: calculationParameters.kerahatSunRisingMins),
    ));
    _dhuhr = getTime(dhuhrTime, dhuhrAdjustment);
    _peaking = getTZ(_dhuhr!.subtract(
      Duration(minutes: calculationParameters.kerahatSunPeakingMins),
    ));
    _asr = getTime(asrTime, asrAdjustment);
    _maghrib = getTime(maghribTime, maghribAdjustment);
    _setting = _maghrib!.subtract(
      Duration(minutes: calculationParameters.kerahatSunSettingMins),
    );
    _isha = getTime(ishaTime, ishaAdjustment);

    _fajrDayAfter = getTime(fajrDayAfterTime, fajrAdjustment);
    _ishaDayBefore = getTime(ishaDayBeforeTime, ishaAdjustment);

    // Convenience Utilities
    _currPrayerName = currentPrayer(date);
    _currPrayerDate = timeForPrayer(_currPrayerName);

    _nextPrayerName = nextPrayer(date);
    _nextPrayerDate = timeForPrayer(_nextPrayerName!);

    // Sunnah Times
    // TODO TEST: note was originally using next day for calcs:
    Duration nightDuration = _fajr!.difference(_maghrib!);
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
    print('fajr:        $_fajr');
    print('sunrise:     $_rising');
    print('duha:        $_duha');
    print('peaking:     $_peaking');
    print('dhuhr:       $_dhuhr');
    print('asr:         $_asr');
    print('setting:     $_setting');
    print('maghrib:     $_maghrib');
    print('isha:        $_isha');

    print('isha day before: $_ishaDayBefore');
    print('fajr day after:  $_fajrDayAfter');

    print('***** Convenience Utilities:');
    print('current: $_currPrayerDate ($_currPrayerName)');
    print('next:    $_nextPrayerDate ($_nextPrayerName)');

    print('***** Sunnah Times:');
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
    if (prayer == Prayer.IshaDayBefore) {
      return _ishaDayBefore!;
    } else if (prayer == Prayer.Fajr) {
      return _fajr!;
    } else if (prayer == Prayer.Rising) {
      return _rising!;
    } else if (prayer == Prayer.Duha) {
      return _duha!;
    } else if (prayer == Prayer.Peaking) {
      return _peaking!;
    } else if (prayer == Prayer.Dhuhr) {
      return _dhuhr!;
    } else if (prayer == Prayer.Asr) {
      return _asr!;
    } else if (prayer == Prayer.Setting) {
      return _setting!;
    } else if (prayer == Prayer.Maghrib) {
      return _maghrib!;
    } else if (prayer == Prayer.Isha) {
      return _isha!;
    } else if (prayer == Prayer.FajrDayAfter) {
      return _fajrDayAfter!;
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
    } else if (date.isAfter(_setting!)) {
      return Prayer.Setting;
    } else if (date.isAfter(_asr!)) {
      return Prayer.Asr;
    } else if (date.isAfter(_dhuhr!)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_peaking!)) {
      return Prayer.Peaking;
    } else if (date.isAfter(_duha!)) {
      return Prayer.Duha;
    } else if (date.isAfter(_rising!)) {
      return Prayer.Rising;
    } else if (date.isAfter(_fajr!)) {
      return Prayer.Fajr;
    } else {
      return Prayer.IshaDayBefore;
    }
  }

  Prayer nextPrayer(DateTime date) {
    if (date.isAfter(_isha!)) {
      return Prayer.FajrDayAfter;
    } else if (date.isAfter(_maghrib!)) {
      return Prayer.Isha;
    } else if (date.isAfter(_asr!)) {
      return Prayer.Maghrib;
    } else if (date.isAfter(_dhuhr!)) {
      return Prayer.Asr;
    } else if (date.isAfter(_rising!)) {
      return Prayer.Dhuhr;
    } else if (date.isAfter(_fajr!)) {
      return Prayer.Rising;
    } else {
      return Prayer.Fajr;
    }
  }
}
