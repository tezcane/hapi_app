import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';

class MultiColorRing extends CustomPainter {
  const MultiColorRing(
    this.slices,
    this.totalSecs,
    this.diameter,
    this.noonCorrection,
    this.strokeWidth,
  );

  final List<Map<Color, double>> slices;
  final double totalSecs, diameter, noonCorrection;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    double radius = diameter / 2;
    Rect myRect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    double radianStart = noonCorrection; // used to be 0
    double radianLength = 0;

    l.d('_MultipleColorCirclePainter: allOccurrences=$totalSecs');
    for (Map<Color, double> map in slices) {
      double percent = map.values.first / totalSecs;
      radianLength = 2 * percent * math.pi;
      canvas.drawArc(
          myRect,
          radianStart,
          radianLength,
          false,
          Paint()
            ..color = map.keys.first
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke);
      radianStart += radianLength;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
