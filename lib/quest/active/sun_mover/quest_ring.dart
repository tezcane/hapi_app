import 'package:flutter/material.dart';
import 'package:hapi/helpers/math_utils.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';

class QuestRing extends StatelessWidget {
  const QuestRing(this.athan, this.diameter, this.strokeWidth);

  final Athan athan;
  final double diameter;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    List<Map<Color, double>> athanSlices = [];

    double totalSecs = 0.0;
    int lastIdx = Z.values.length - 2; // don't go to FajrTomorrow
    for (var zIdx = lastIdx; zIdx >= 0; zIdx--) {
      Z currZ = Z.values[zIdx];
      Z nextZ = Z.values[zIdx + 1];

      List<Object> currZValues = athan.getZamanTime(currZ);
      DateTime currZTime = currZValues[0] as DateTime;
      Color currZColor = currZValues[1] as Color;

      List<Object> nextZValues = athan.getZamanTime(nextZ);
      DateTime nextZTime = nextZValues[0] as DateTime;

      double elapsedSecs =
          nextZTime.difference(currZTime).inMilliseconds / 1000;
      athanSlices.add({currZColor: elapsedSecs});
      totalSecs += elapsedSecs;
    }

    // calculate high noon degree offset so we align SunMover circle around it
    DateTime currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    DateTime nextZTime = athan.highNoon;
    double elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;
    // high noon/Sun zenith is constant at very top of circle (25%=quarter turn)
    double noonDegreeCorrection = 365 * ((elapsedSecs / totalSecs) - .25);
    double noonRadianCorrection = degreesToRadians(noonDegreeCorrection);

    // get offset where fajr is so we can rotate sun from correct spot
    double fajrStartPercentCorrection = noonDegreeCorrection / 365;
    //l.d('noonDegreeCorrection=$noonDegreeCorrection, noonCorrection=$noonCorrection, fajrStartCorrection=$fajrStartCorrection');

    // calculate sunrise on the horizon, so we can set horizon right for gumbi and me
    currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    nextZTime = athan.sunrise;
    elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;

    // Sunrise is constant at very right of circle, (no turn)
    double sunrisePercentCorrection =
        (((elapsedSecs / totalSecs) / 365) - fajrStartPercentCorrection) / 2;
    double sunriseCorrection = .5 - sunrisePercentCorrection;
    //double sunriseCorrection = 2 * degreeCorrection * math.pi;

    //l.d('sunriseDegreeCorrection=$sunriseDegreeCorrection, fajrStartCorrection=$fajrStartCorrection->sunriseCorrection=$sunriseCorrection');

    // RepaintBoundary prevents the ALWAYS repaint on ANY page update
    return Center(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          children: [
            // RepaintBoundary needed or it will repaint on every second tick
            RepaintBoundary(
              child: CustomPaint(
                painter: MultiColorRing(
                  athanSlices,
                  totalSecs,
                  diameter,
                  noonRadianCorrection,
                  strokeWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
