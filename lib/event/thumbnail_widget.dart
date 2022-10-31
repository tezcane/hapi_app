import 'package:flutter/material.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_asset.dart';
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
    EventAsset asset = event.asset;
    Widget thumbnail;
    switch (asset.getAssetType()) {
      case ASSET_TYPE.IMAGE:
        thumbnail = RawImage(image: (asset as ImageAsset).image);
        break;
      case ASSET_TYPE.FLARE:
      case ASSET_TYPE.NIMA:
        thumbnail = EventWidget(isActive: false, event: event); // acts like pic
        break;
    }

    return SizedBox(
      width: radius * 4,
      height: radius * 4,
      child: ClipPath(clipper: CircleClipper(), child: thumbnail),
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
