import 'dart:math';

import 'package:hapi/quest/active/athan/Coordinates.dart';
import 'package:hapi/quest/active/athan/MathUtils.dart';

class Qibla {
  static double qibla(coordinates) {
    //Coordinates makkah = new Coordinates(21.4225241, 39.8261818);
    Coordinates kaaba = new Coordinates(21.422487, 39.826206);

    // Equation from "Spherical Trigonometry For the use of colleges and schools" page 50
    double term1 = (sin(degreesToRadians(kaaba.longitude) -
        degreesToRadians(coordinates.longitude)));
    double term2 = (cos(degreesToRadians(coordinates.latitude)) *
        tan(degreesToRadians(kaaba.latitude)));
    double term3 = (sin(degreesToRadians(coordinates.latitude)) *
        cos(degreesToRadians(kaaba.longitude) -
            degreesToRadians(coordinates.longitude)));
    double angle = atan2(term1, term2 - term3);

    return unwindAngle(radiansToDegrees(angle));
  }
}
