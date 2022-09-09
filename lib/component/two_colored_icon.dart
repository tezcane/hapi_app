import 'package:flutter/material.dart';

/// Change an icon into two color parts (50/50 by default):
///   1. One solid color (on bottom). This can also be changed to the background
///      color to make it look like the icon is cut in half.
///   2. One gradient color (on top), or use 2 or 3 of same color to ignore.
///
///   Can rotate top/bottom to left/right, etc. with alignmentBegin/End params.
class TwoColoredIcon extends StatelessWidget {
  const TwoColoredIcon(
    this.icon,
    this.iconSize,
    this.colors,
    this.bottomColor, {
    this.fillPercent = .5,
    this.alignmentBegin = Alignment.topCenter,
    this.alignmentEnd = Alignment.bottomCenter,
  });

  final IconData icon;
  final double iconSize;
  final List<Color> colors;
  final Color bottomColor;
  final double fillPercent;
  final Alignment alignmentBegin;
  final Alignment alignmentEnd;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: alignmentBegin,
          end: alignmentEnd,
          stops: [0, fillPercent, fillPercent],
          colors: colors,
        ).createShader(rect);
      },
      child: Icon(icon, size: iconSize, color: bottomColor),
    );
  }
}
