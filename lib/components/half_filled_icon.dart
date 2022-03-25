import 'package:flutter/material.dart';

/// Change an icon into two color parts (50/50 by default):
///   1. One solid color (on bottom). This can also be changed to the background
///      color to cut an icon in half.
///   2. One gradient color (on top) but you can input the same color if not desired.
///
///   The top/bottom can be rotated to left/right with the radianAngle param.
class TwoColoredIcon extends StatelessWidget {
  const TwoColoredIcon(
    this.icon,
    this.size,
    this.colors,
    this.bottomColor, {
    this.fillPercent = .5,
    this.radianAngle = 1.5708,
  });

  final IconData icon;
  final double size;
  final List<Color> colors;
  final Color bottomColor;
  final double fillPercent, radianAngle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: radianAngle,
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect rect) {
          return LinearGradient(
            stops: [0, fillPercent, fillPercent],
            colors: colors,
          ).createShader(rect);
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size, color: bottomColor),
        ),
      ),
    );
  }
}
