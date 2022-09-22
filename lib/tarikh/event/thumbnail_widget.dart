import 'package:flutter/material.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';
import 'package:hapi/tarikh/event/event_widget.dart';

/// This widget is responsible for drawing the circular thumbnail within the [ThumbnailDetailWidget].
///
/// It uses an inactive [EventWidget] for the image, with a [CustomClipper] for the circular image.
class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget(this.event);

  static const double radius = 17;

  /// Reference to the event to get the thumbnail image information.
  final Event event;

  @override
  Widget build(BuildContext context) {
    EventAsset asset = event.asset;
    Widget thumbnail;

    /// Check if the [event.asset] provided is already a [EventImage].
    if (asset is ImageAsset) {
      thumbnail = RawImage(image: asset.image);
    } else if (asset is NimaAsset || asset is FlareAsset) {
      /// If not, retrieve the image from the Nima/Flare [EventAsset], and
      /// set it as inactive (i.e. a static image).
      /// TODO turn active on/off?
      thumbnail = EventWidget(isActive: false, event: event);
    } else {
      thumbnail = Container(color: Colors.transparent);
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
