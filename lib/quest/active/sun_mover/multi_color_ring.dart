import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';

class ColorSlice {
  ColorSlice(this.elapsedSecs, this.color);

  final double elapsedSecs;
  final Color color;

  static double _totalSecs = 0;
  static double _noonRadianCorrection = 0;

  /// These are static and once set will be used by both SunRing and QuestRing.
  static double get totalSecs => _totalSecs;
  static double get noonRadianCorrection => _noonRadianCorrection;
  static void setTotalSecs(double v) => _totalSecs = v;
  static void setNoonRadianCorrection(double v) => _noonRadianCorrection = v;
}

class MultiColorRing extends CustomPainter {
  const MultiColorRing(this.colorSlices, this.diameter, this.strokeWidth);

  /// LinkedHashMap preserves insertion order
  final Map<Object, ColorSlice> colorSlices;
  final double diameter, strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    double totalSecs = ColorSlice.totalSecs;
    l.d('MultiColorRing:paint: totalSecs=$totalSecs');

    double radius = diameter / 2;
    Rect myRect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    double radianStart = ColorSlice.noonRadianCorrection; // used to be 0
    double radianLength = 0;
    for (ColorSlice colorSlice in colorSlices.values) {
      double percent = colorSlice.elapsedSecs / totalSecs;
      radianLength = 2 * percent * math.pi;
      canvas.drawArc(
          myRect,
          radianStart,
          radianLength,
          false,
          Paint()
            ..color = colorSlice.color
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke);
      radianStart += radianLength;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
