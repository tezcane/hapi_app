import 'package:flutter/cupertino.dart';

/// A little line used to give visual separation between UI components.
class Separator extends StatelessWidget {
  const Separator(this.marginTop, this.marginBottom, this.lineWidth);

  final double marginTop, marginBottom, lineWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: marginTop),
          height: lineWidth,
          color: const Color.fromRGBO(151, 151, 151, 0.29),
        ),
        Container(
          margin: EdgeInsets.only(bottom: marginBottom),
          height: lineWidth,
          color: const Color.fromRGBO(239, 227, 227, 0.29),
        ),
      ],
    );
  }
}
