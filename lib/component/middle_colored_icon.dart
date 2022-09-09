// import 'package:flutter/material.dart';
//
// import 'two_colored_icon.dart';
//
// /// TODO UNTESTED
// /// Change an icon into three color parts (left, middle, outside):
// class MiddleColoredIcon extends StatelessWidget {
//   const MiddleColoredIcon(
//     this.icon,
//     this.iconSize,
//     this.colors,
//     this.bottomColor, {
//     this.fillPercent = .5,
//     this.alignmentBegin = Alignment.topCenter,
//     this.alignmentEnd = Alignment.bottomCenter,
//   });
//
//   final IconData icon;
//   final double iconSize;
//   final List<Color> colors;
//   final Color bottomColor;
//   final double fillPercent;
//   final Alignment alignmentBegin;
//   final Alignment alignmentEnd;
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         TwoColoredIcon(
//           icon,
//           iconSize,
//           colors,
//           bottomColor,
//           fillPercent: fillPercent,
//           alignmentBegin: LanguageC.to.centerLeft,
//           alignmentEnd: Alignment.center,
//         ),
//         Icon(icon, size: iconSize, color: colors[0]),
//         TwoColoredIcon(
//           icon,
//           iconSize,
//           colors,
//           bottomColor,
//           fillPercent: fillPercent,
//           alignmentBegin: Alignment.center,
//           alignmentEnd: Alignment.centerRight,
//         ),
//       ],
//     );
//   }
// }
