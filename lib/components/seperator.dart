import 'package:flutter/cupertino.dart';

const topColorDefault = Color.fromRGBO(151, 151, 151, 0.29);
const bottomColorDefault = Color.fromRGBO(239, 227, 227, 0.29);

/// A little line used to give visual separation between UI components.
class Separator extends StatelessWidget {
  const Separator(
    this.marginTop,
    this.marginBottom,
    // Note lineHeight is height of both lines (it's divided in half):
    this.lineHeight, {
    this.topColor = topColorDefault,
    this.bottomColor = bottomColorDefault,
  });

  final double marginTop, marginBottom, lineHeight;
  final Color topColor, bottomColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // needed
      children: [
        Container(
          margin: EdgeInsets.only(top: marginTop),
          height: lineHeight / 2,
          color: topColor,
        ),
        Container(
          margin: EdgeInsets.only(bottom: marginBottom),
          height: lineHeight / 2,
          color: bottomColor,
        ),
      ],
    );
  }
}
