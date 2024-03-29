import 'dart:math';

import 'package:hapi/helper/math_utils.dart';
import 'package:hapi/quest/active/athan/astronomical/astronomical.dart';

class SolarCoordinates {
  SolarCoordinates(double julianDay) {
    double T = Astronomical.julianCentury(julianDay);
    double L0 = Astronomical.meanSolarLongitude(T);
    double Lp = Astronomical.meanLunarLongitude(T);
    double Omega = Astronomical.ascendingLunarNodeLongitude(T);
    double Lambda =
        degreesToRadians(Astronomical.apparentSolarLongitude(T, L0));
    double Theta0 = Astronomical.meanSiderealTime(T);
    double dPsi = Astronomical.nutationInLongitude(T, L0, Lp, Omega);
    double dEpsilon = Astronomical.nutationInObliquity(T, L0, Lp, Omega);
    double Epsilon0 = Astronomical.meanObliquityOfTheEcliptic(T);
    double EpsilonApparent = degreesToRadians(
        Astronomical.apparentObliquityOfTheEcliptic(T, Epsilon0));

    /* declination: The declination of the sun, the angle between
            the rays of the Sun and the plane of the Earth's
            equator, in degrees.
            Equation from Astronomical Algorithms page 165 */
    _declination = radiansToDegrees(asin(sin(EpsilonApparent) * sin(Lambda)));

    /* rightAscension: Right ascension of the Sun, the angular distance on the
            celestial equator from the vernal equinox to the hour circle,
            in degrees.
            Equation from Astronomical Algorithms page 165 */
    _rightAscension = unwindAngle(radiansToDegrees(
        atan2(cos(EpsilonApparent) * sin(Lambda), cos(Lambda))));

    /* apparentSiderealTime: Apparent sidereal time, the hour angle of the vernal
            equinox, in degrees.
            Equation from Astronomical Algorithms page 88 */
    _apparentSiderealTime = Theta0 +
        (((dPsi * 3600) * cos(degreesToRadians(Epsilon0 + dEpsilon))) / 3600);
  }

  late double _declination;
  double get declination => _declination;

  late double _rightAscension;
  double get rightAscension => _rightAscension;

  late double _apparentSiderealTime;
  double get apparentSiderealTime => _apparentSiderealTime;
}
