import 'package:flutter/material.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_widget.dart';

/// This widget is responsible for drawing the circular thumbnail within the [ThumbnailDetailWidget].
///
/// It uses an inactive [EventWidget] for the image, with a [CustomClipper] for the circular image.
class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget(this.event);
  final Event event;

  static const double radius = 17;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 4,
      height: radius * 4,
//    child: ClipPath( // use to put a circle frame around photo
//      clipper: CircleClipper(),
      child: event.asset.widget(false, null),
//    ),
    );
  }
}

/// Custom Clipper for the desired circular effect.
class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
