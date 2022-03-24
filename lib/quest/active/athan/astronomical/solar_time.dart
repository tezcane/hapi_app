import 'dart:math';

import 'package:hapi/helpers/cord.dart';
import 'package:hapi/helpers/math_utils.dart';
import 'package:hapi/quest/active/athan/astronomical/astronomical.dart';
import 'package:hapi/quest/active/athan/astronomical/solar_coordinates.dart';

class SolarTime {
  late Cord observer;
  late SolarCoordinates solar;
  late SolarCoordinates prevSolar;
  late SolarCoordinates nextSolar;

  late double approxTransit;
  late double transit;
  late double sunrise;
  late double sunset;

  SolarTime(date, Cord cord) {
    double julianDay =
        Astronomical.julianDay(date.year, date.month, date.day, 0);

    observer = cord;
    solar = SolarCoordinates(julianDay);

    prevSolar = SolarCoordinates(julianDay - 1);
    nextSolar = SolarCoordinates(julianDay + 1);

    double m0 = Astronomical.approximateTransit(
        cord.lng, solar.apparentSiderealTime, solar.rightAscension);
    const solarAltitude = -50.0 / 60.0;

    approxTransit = m0;

    transit = Astronomical.correctedTransit(
        m0,
        cord.lng,
        solar.apparentSiderealTime,
        solar.rightAscension,
        prevSolar.rightAscension,
        nextSolar.rightAscension);

    sunrise = Astronomical.correctedHourAngle(
        m0,
        solarAltitude,
        cord,
        false,
        solar.apparentSiderealTime,
        solar.rightAscension,
        prevSolar.rightAscension,
        nextSolar.rightAscension,
        solar.declination,
        prevSolar.declination,
        nextSolar.declination);

    sunset = Astronomical.correctedHourAngle(
        m0,
        solarAltitude,
        cord,
        true,
        solar.apparentSiderealTime,
        solar.rightAscension,
        prevSolar.rightAscension,
        nextSolar.rightAscension,
        solar.declination,
        prevSolar.declination,
        nextSolar.declination);
  }

  double hourAngle(angle, afterTransit) {
    return Astronomical.correctedHourAngle(
        approxTransit,
        angle,
        observer,
        afterTransit,
        solar.apparentSiderealTime,
        solar.rightAscension,
        prevSolar.rightAscension,
        nextSolar.rightAscension,
        solar.declination,
        prevSolar.declination,
        nextSolar.declination);
  }

  double afternoon(int shadowLength) {
    // TODO asdf fdsa (original to-do): source shadow angle calculation
    double tangent = (observer.lat - solar.declination).abs();
    double inverse = shadowLength + tan(degreesToRadians(tangent));
    double angle = radiansToDegrees(atan(1.0 / inverse));
    return hourAngle(angle, true);
  }
}
