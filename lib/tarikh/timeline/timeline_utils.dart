import 'package:flutter/material.dart';
import 'package:hapi/event/event.dart';

// Color interpolateColor(Color from, Color to, double elapsed) {
//   double r, g, b, a;
//   double speed = min(1.0, elapsed * 5.0);
//   double c = to.alpha.toDouble() - from.alpha.toDouble();
//   if (c.abs() < 1.0) {
//     a = to.alpha.toDouble();
//   } else {
//     a = from.alpha + c * speed;
//   }
//
//   c = to.red.toDouble() - from.red.toDouble();
//   if (c.abs() < 1.0) {
//     r = to.red.toDouble();
//   } else {
//     r = from.red + c * speed;
//   }
//
//   c = to.green.toDouble() - from.green.toDouble();
//   if (c.abs() < 1.0) {
//     g = to.green.toDouble();
//   } else {
//     g = from.green + c * speed;
//   }
//
//   c = to.blue.toDouble() - from.blue.toDouble();
//   if (c.abs() < 1.0) {
//     b = to.blue.toDouble();
//   } else {
//     b = from.blue + c * speed;
//   }
//
//   return Color.fromARGB(a.round(), r.round(), g.round(), b.round());
// }

// String getFileExtension(String filename) {
//   int dot = filename.lastIndexOf('.');
//   if (dot == -1) {
//     return '';
//   }
//   return filename.substring(dot + 1);
// }

// String? removeExtension(String filename) {
//   int dot = filename.lastIndexOf('.');
//   if (dot == -1) {
//     return null;
//   }
//   return filename.substring(0, dot);
// }

// class EventColors {
//   EventColors(
//     this.timelineBackgroundColor,
//     this.tickColors,
//     this.headerColors,
//     //this.tapTarget,
//   );
//
//   final TimelineBackgroundColor timelineBackgroundColor;
//   final TickColors tickColors;
//   final HeaderColors headerColors;
//   // final TapTarget tapTarget;
// }

class TimelineBackgroundColor {
  const TimelineBackgroundColor(this.color, this.start);
  final Color color;
  final double start;
}

class TickColors {
  TickColors(this.background, this.long, this.short, this.text, this.start);
  final Color background;
  final Color long;
  final Color short;
  final Color text;
  final double start;
  double screenY = 0.0;
}

class HeaderColors {
  HeaderColors(this.background, this.text, this.start);
  final Color background;
  final Color text;
  final double start;
  double screenY = 0.0;
}

class TapTarget {
  const TapTarget(this.event, this.rect, {this.zoom = false});
  final Event event;
  final Rect rect;
  final bool zoom;
}
