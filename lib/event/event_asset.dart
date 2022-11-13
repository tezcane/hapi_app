import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:get/get.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_widget.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

enum ASSET_TYPE {
  IMAGE, // PNG and JPG images
  IMAGE_SVG, // SVG images
//RIVE, // TODO
  NIMA,
  FLARE,
}

/// An object representing the renderable assets loaded from `timeline.json`.
///
/// Each [EventAsset] encapsulates all the relevant properties for drawing,
/// as well as maintaining a reference to its original [Event].
abstract class EventAsset {
  EventAsset(this.filename, this.width, this.height, this.scale);
  final String filename;
  final double width;
  final double height;

  /// Can be overwritten
  double scale;

  /// We create the asset before we create the timeline event so init this ASAP
  late final Event event;

  double opacity = 1.0;
  double scaleVelocity = 0.0; // TODO what does it do?
  double y = 0.0; // TODO what does it do?
  double velocity = 0.0; // TODO what does it do?

  // Abstract method:
  ASSET_TYPE get assetType;
  Widget widget(bool isActive, Offset? interactOffset);
}

/// A renderable image. Should be either a PNG or JPG file (TODO JPG untested).
class ImageAsset extends EventAsset {
  ImageAsset(String filename, double width, double height, double scale)
      : super(filename, width, height, scale) {
    _initImage();
  }

  late final ui.Image uiImage;
  late final Widget widgetImage;

  _initImage() async {
    ByteData byteData = await rootBundle.load(filename);
    Uint8List uint8List = Uint8List.view(byteData.buffer);
    ui.Codec codec = await ui.instantiateImageCodec(uint8List);
    ui.FrameInfo frame = await codec.getNextFrame();
    uiImage = frame.image;

    widgetImage = Image(image: AssetImage(filename), fit: BoxFit.fill);
  }

  @override
  ASSET_TYPE get assetType => ASSET_TYPE.IMAGE;

  @override
  Widget widget(bool isActive, Offset? interactOffset) => widgetImage;
}

/// SVG image file.
class ImageAssetSVG extends EventAsset {
  ImageAssetSVG(
    String filename,
    double width,
    double height,
    double scale,
  ) : super(filename, width, height, scale) {
    _initImage();
  }

  late bool _initDarkMode;
  late Widget imageSvgWidget;

  _initImage() async {
    if (kDebugMode) {
      final SvgParser parser = SvgParser();
      try {
        parser.parse(
          await rootBundle.loadString(filename),
          warningsAsErrors: true,
        );
      } catch (e) {
        l.E('SVG $filename contains unsupported features: $e');
      }
    }

    _initDarkMode = Get.isDarkMode;
    imageSvgWidget = SvgPicture.asset(
      filename,
//    fit: BoxFit.fill,
      color: _initDarkMode ? Colors.white : Colors.black,
    );

    // Left for reference, can parse via uint8List input (like png/jpg files):
    // ByteData byteData = await rootBundle.load(filename);
    // Uint8List uint8List = Uint8List.view(byteData.buffer);
    // imageSvgWidget = SvgPicture.memory(uint8List,
  }

  @override
  ASSET_TYPE get assetType => ASSET_TYPE.IMAGE_SVG;

  @override
  Widget widget(bool isActive, Offset? interactOffset) {
    if (_initDarkMode != Get.isDarkMode) _initImage();
    return imageSvgWidget; // not thread safe, but working
  }
}

/// This asset also has information regarding its animations.
abstract class AnimatedEventAsset extends EventAsset {
  AnimatedEventAsset(
    String filename,
    double width,
    double height,
    double scale,
    this.loop,
    this.tOffsetHorizontal,
    this.tOffsetVertical,
    this.animationTime,
  ) : super(filename, width, height, scale);

  /// true=loop animation, false=play once ant stop
  final bool loop;

  /// Timeline horizontal offset (negative move left, positive move right)
  final double tOffsetHorizontal;

  /// Timeline vertical offset (negative move up, positive move down)
  final double tOffsetVertical;

  /// Can be overwritten
  double animationTime;

  @override
  Widget widget(bool isActive, Offset? interactOffset) => EventWidget(
        event: event,
        isActive: isActive,
        interactOffset: interactOffset,
      );
}

/// A `Nima` animation asset.
class NimaAsset extends AnimatedEventAsset {
  NimaAsset(
    String filename,
    double width,
    double height,
    double scale,
    bool loop,
    double tOffsetHorizontal,
    double tOffsetVertical,
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
  ) : super(
          filename,
          width,
          height,
          scale,
          loop,
          tOffsetHorizontal,
          tOffsetVertical,
          0.0,
        );
  final nima.FlutterActor actorStatic;
  final nima.FlutterActor actor;
  final nima.AABB setupAABB;
  final nima.ActorAnimation animation;

  @override
  ASSET_TYPE get assetType => ASSET_TYPE.NIMA;
}

/// A `Flare` animation asset.
class FlareAsset extends AnimatedEventAsset {
  FlareAsset(
    String filename,
    double width,
    double height,
    double scale,
    bool loop,
    double tOffsetHorizontal,
    double tOffsetVertical,
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
  ) : super(
          filename,
          width,
          height,
          scale,
          loop,
          tOffsetHorizontal,
          tOffsetVertical,
          0.0,
        );
  final flare.FlutterActorArtboard actorStatic;
  final flare.FlutterActorArtboard actor;
  final flare.AABB setupAABB;

  /// Can be overwritten
  flare.ActorAnimation animation;

  /// Some Flare assets will have multiple idle animations (e.g. 'Humans'),
  /// others will have an intro&idle animation (e.g. 'Sun is Born').
  /// All this information is in `timeline.json` file, and it's de-serialized in
  /// the [Timeline.loadFromBundle()] method, called during startup.
  /// and custom-computed AABB bounds to properly position them in the timeline.
  flare.ActorAnimation? intro;
  flare.ActorAnimation? idle;
  List<flare.ActorAnimation>? idleAnimations;

  @override
  ASSET_TYPE get assetType => ASSET_TYPE.FLARE;
}

Future<NimaAsset> loadNimaAsset(
  String filename,
  double width,
  double height,
  double scale,
  bool loop,
  double tOffsetHorizontal,
  double tOffsetVertical,
  String? nimaIdle,
  List<double>? bounds,
) async {
  nima.FlutterActor flutterActor = nima.FlutterActor();
  await flutterActor.loadFromBundle(filename);

  nima.FlutterActor actorStatic = flutterActor;
  nima.FlutterActor actor = flutterActor.makeInstance() as nima.FlutterActor;

  nima.ActorAnimation animation;
  if (nimaIdle is String) {
    animation = actor.getAnimation(nimaIdle);
  } else {
    animation = flutterActor.animations[0];
  }

  actor.advance(0.0);
  nima.AABB setupAABB = actor.computeAABB();
  animation.apply(0.0, actor, 1.0);
  animation.apply(animation.duration, actorStatic, 1.0);
  actor.advance(0.0);
  actorStatic.advance(0.0);

  if (bounds is List) {
    setupAABB =
        nima.AABB.fromValues(bounds![0], bounds[1], bounds[2], bounds[3]);
  }

  NimaAsset nimaAsset = NimaAsset(
    filename,
    width,
    height,
    scale,
    loop,
    tOffsetHorizontal,
    tOffsetVertical,
    actorStatic,
    actor,
    setupAABB,
    animation,
  );

  return nimaAsset;
}

Future<FlareAsset> loadFlareAsset(
  String filename,
  double width,
  double height,
  double scale,
  bool loop,
  double tOffsetHorizontal,
  double tOffsetVertical,
  String? flareIdle,
  List<double>? bounds,
  String? flareIntro,
) async {
  flare.FlutterActor flutterActor = flare.FlutterActor();

  /// Flare library function to load the [FlutterActor]
  await flutterActor.loadFromBundle(rootBundle, filename);

  /// Distinguish between the actual actor, and its instance.
  flare.FlutterActorArtboard actorStatic =
      flutterActor.artboard as flare.FlutterActorArtboard;
  actorStatic.initializeGraphics();
  flare.FlutterActorArtboard actor =
      flutterActor.artboard.makeInstance() as flare.FlutterActorArtboard;
  actor.initializeGraphics();

  /// and the reference to their first animation is grabbed.
  flare.ActorAnimation animation = flutterActor.artboard.animations[0];

  flare.ActorAnimation? idle;
  List<flare.ActorAnimation>? idleAnimations;
  if (flareIdle is String) {
    if ((idle = actor.getAnimation(flareIdle)) != null) animation = idle;
  } else if (flareIdle is List) {
    for (String animationName in flareIdle as List<String>) {
      flare.ActorAnimation? animation1 = actor.getAnimation(animationName);
      if (animation1 != null) {
        idleAnimations ??= [];
        idleAnimations.add(animation1);
        animation = animation1;
      }
    }
  }

  flare.ActorAnimation? intro;
  if (flareIntro is String) {
    if ((intro = actor.getAnimation(flareIntro)) != null) animation = intro;
  }

  /// Make sure that all the initial values are set for the actor and for the
  /// actor instance.
  actor.advance(0.0);
  flare.AABB setupAABB = actor.computeAABB();
  animation.apply(0.0, actor, 1.0);
  animation.apply(animation.duration, actorStatic, 1.0);
  actor.advance(0.0);
  actorStatic.advance(0.0);

  if (bounds is List) {
    /// Override the AABB for this event with custom values.
    setupAABB = flare.AABB.fromValues(
      bounds![0],
      bounds[1],
      bounds[2],
      bounds[3],
    );
  }

  FlareAsset flareAsset = FlareAsset(
    filename,
    width,
    height,
    scale,
    loop,
    tOffsetHorizontal,
    tOffsetVertical,
    actorStatic,
    actor,
    setupAABB,
    animation,
  );

  // set optional fields, if they exist:
  flareAsset.intro = intro;
  flareAsset.idle = idle;
  flareAsset.idleAnimations = idleAnimations;

  return flareAsset;
}

/// The `asset` key in the current event contains all the information for
/// the nima/flare animation file that'll be played on the timeline.
///
/// `asset` is an object with:
///   - source: the name of the nima/flare/image file in the assets folder.
///   - width/height/tOffsetHorizontal/tOffsetVertical/bounds:
///            Sizes of the animation to properly align it in the timeline,
///            together with its Axis-Aligned Bounding Box container.
///   - intro: Some files have an 'intro' animation, to be played before
///            idling.
///   - idle:  Some files have one or more idle animations, and these are
///            their names.
///   - loop:  Some animations shouldn't loop (e.g. Big Bang) but just settle
///            onto their idle animation. If that's the case, this flag is
///            raised.
///   - scale: a custom scale value.
Future<EventAsset> getEventAsset(Asset asset) async {
  ASSET_TYPE _parseAssetType(String filename) {
    if (filename.endsWith('png')) return ASSET_TYPE.IMAGE;
    if (filename.endsWith('jpg')) return ASSET_TYPE.IMAGE;
    if (filename.endsWith('svg')) return ASSET_TYPE.IMAGE_SVG;
    if (filename.endsWith('nma')) return ASSET_TYPE.NIMA;
    if (filename.endsWith('flr')) return ASSET_TYPE.FLARE;

    l.E('Unknown file extension: $filename, default to ASSET_TYPE.IMAGE');
    return ASSET_TYPE.IMAGE;
  }

  String filename = 'assets/' + asset.filename;

  /// Instantiate the correct object based on the file extension.
  final EventAsset eventAsset;
  switch (_parseAssetType(asset.filename)) {
    case ASSET_TYPE.IMAGE:
      eventAsset = ImageAsset(
        filename,
        asset.width,
        asset.height,
        asset.scale,
      );
      break;
    case ASSET_TYPE.IMAGE_SVG:
      eventAsset = ImageAssetSVG(
        filename,
        asset.width,
        asset.height,
        asset.scale,
      );
      break;
    case ASSET_TYPE.NIMA:
      eventAsset = await loadNimaAsset(
        filename,
        asset.width,
        asset.height,
        asset.scale,
        asset.loop,
        asset.tOffsetHorizontal,
        asset.tOffsetVertical,
        asset.idle,
        asset.bounds,
      );
      break;
    case ASSET_TYPE.FLARE:
      eventAsset = await loadFlareAsset(
        filename,
        asset.width,
        asset.height,
        asset.scale,
        asset.loop,
        asset.tOffsetHorizontal,
        asset.tOffsetVertical,
        asset.idle,
        asset.bounds,
        asset.intro,
      );
      break;
  }

  return Future.value(eventAsset);
}

/// Method used to paint assets to a canvas. Lots of one off code logic here
/// by checking booleans/nulls on input paramaters but it is better to have all
/// this very similar code in one place for easier code maintenance. Very small
/// differences between all the places this code is used so also wanted to
/// collect that code here. Makes it easier to support different media types
/// later, e.g. RIVE, Animated GIF, etc.
drawAssetOnCanvas({
  required final Event? event,
  required final Canvas canvas,
  required final Offset offset,
  required final nima.FlutterActor? nimaActor,
  required final flare.FlutterActorArtboard? flareActor,
  required final Alignment alignmentNima,
  required final Alignment alignmentFlare,
  required final Size size,
  required final BoxFit fit,
  required final Color? gradientColor,
  required final double opacity,
  required final bool useAssetOpacity,
  required final double rs,
  required final double assetScreenScale,
  required final bool useOffsetHorizontal,
  required final List<TapTarget>? tapTargets,
}) {
  /// Don't paint if not needed.
  if (event == null) return;

  EventAsset asset = event.asset;

  canvas.save();

  double w = asset.width * assetScreenScale;
  double h = asset.height * assetScreenScale;

  Offset renderOffset = useOffsetHorizontal
      ? Offset(offset.dx + size.width - w, asset.y)
      : offset;
  Size renderSize = useOffsetHorizontal ? Size(w * rs, h * rs) : size;

  switch (asset.assetType) {

    /// If the asset is just a static image, draw the image directly to canvas
    case ASSET_TYPE.IMAGE:
      canvas.drawImageRect(
        (asset as ImageAsset).uiImage,
        Rect.fromLTWH(0.0, 0.0, asset.width, asset.height),
        Rect.fromLTWH(offset.dx + size.width - w, asset.y, w * rs, h * rs),
        Paint()
          ..isAntiAlias = true
          ..filterQuality = ui.FilterQuality.low
          ..color = Colors.white.withOpacity(asset.opacity),
      );

      break;

    /// If the asset is just a static image, draw the image directly to canvas
    case ASSET_TYPE.IMAGE_SVG:
      // TODO asdf fdsa untested and asset not here
      const String rawSvg = '''<svg viewBox="...">...</svg>''';

      //final DrawableRoot svgRoot = await svg.fromSvgString(rawSvg, rawSvg);

      // // If you only want the final Picture output, just use
      // final Picture picture = svgRoot.toPicture();

      // Otherwise, if you want to draw it to a canvas:
      // Optional, but probably normally desirable: scale the canvas dimensions
      // to the SVG's viewbox
      //svgRoot.scaleCanvasToViewBox(canvas, Size(asset.width, asset.height));

      // Optional, but probably normally desireable: ensure the SVG isn't
      // rendered outside of the viewbox bounds
      //svgRoot.clipCanvasToViewBox(canvas);

      //svgRoot.draw(canvas, Rect.zero); // The second parameter is not used
      break;

    /// If we have a [NimaAsset] asset, set it up properly and paint it.
    ///
    /// 1. Calculate the bounds for the current object.
    /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset is
    /// first loaded. We rely on this AABB to perform screen-space calculations.
    case ASSET_TYPE.NIMA:
      // if (_nimaActor == null) break;
      NimaAsset nimaAsset = asset as NimaAsset;
      nima.AABB bounds = nimaAsset.setupAABB;

      double contentHeight = bounds[3] - bounds[1];
      double contentWidth = bounds[2] - bounds[0];

      double x = -bounds[0] -
          contentWidth / 2.0 -
          (alignmentNima.x * contentWidth / 2.0);
      if (useOffsetHorizontal) x += nimaAsset.tOffsetHorizontal;

      double y = -bounds[1] -
          contentHeight / 2.0 +
          (alignmentNima.y * contentHeight / 2.0);

      double scaleX = 1.0, scaleY = 1.0;

      canvas.save();

      /// But this behavior can be customized according to anyone's needs.
      /// The following switch/case contains all the various alternatives
      /// native to Flutter.
      switch (fit) {
        case BoxFit.contain:
          double minScale = min(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = minScale;
          break;
        case BoxFit.cover:
          double maxScale = max(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = maxScale;
          break;
        case BoxFit.fill:
          scaleX = renderSize.width / contentWidth;
          scaleY = renderSize.height / contentHeight;
          break;
        case BoxFit.fitHeight:
          double minScale = renderSize.height / contentHeight;
          scaleX = scaleY = minScale;
          break;
        case BoxFit.fitWidth:
          double minScale = renderSize.width / contentWidth;
          scaleX = scaleY = minScale;
          break;
        case BoxFit.none:
          scaleX = scaleY = 1.0;
          break;
        case BoxFit.scaleDown:
          double minScale = min(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
          break;
      }

      /// 2. Move the [canvas] to the right position so that the widget's
      /// position is center-aligned based on its offset, size and alignment
      /// position.
      canvas.translate(
        renderOffset.dx +
            renderSize.width / 2.0 +
            (alignmentNima.x * renderSize.width / 2.0),
        renderOffset.dy +
            renderSize.height / 2.0 +
            (alignmentNima.y * renderSize.height / 2.0),
      );

      /// 3. Scale depending on the [fit].
      canvas.scale(scaleX, -scaleY);

      /// 4. Move canvas to the correct [_nimaActor] position calculated above
      canvas.translate(x, y);

      double actorOpacity = useAssetOpacity ? asset.opacity : 1.0;
      if (actorOpacity < 0.0) {
        l.w('Nima opacity is $actorOpacity, correcting to 0.0');
        actorOpacity = 0.0;
      }
      if (actorOpacity > 1.0) {
        l.w('Nima opacity is $actorOpacity, correcting to 1.0');
        actorOpacity = 1.0;
      }

      /// 5. perform the drawing operations.
      if (nimaActor != null) {
        nimaActor.draw(canvas, actorOpacity);
      } else {
        asset.actor.draw(canvas, actorOpacity);
      }

      /// 6. Restore the canvas' original transform state.
      canvas.restore();

      break;

    /// If we have a [TimelineFlare] asset set it up properly and paint it.
    ///
    /// 1. Calculate the bounds for the current object.
    /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset
    /// is first loaded. We rely on AABB for screen-space calculations.
    case ASSET_TYPE.FLARE:
      // if (_flareActor == null) break;
      FlareAsset flareAsset = asset as FlareAsset;
      flare.AABB bounds = flareAsset.setupAABB;

      double contentWidth = bounds[2] - bounds[0];
      double contentHeight = bounds[3] - bounds[1];

      double x = -bounds[0] -
          contentWidth / 2.0 -
          (alignmentFlare.x * contentWidth / 2.0);
      if (useOffsetHorizontal) x += flareAsset.tOffsetHorizontal;

      double y = -bounds[1] -
          contentHeight / 2.0 +
          (alignmentFlare.y * contentHeight / 2.0);

      double scaleX = 1.0, scaleY = 1.0;

      canvas.save();

      /// But this behavior can be customized according to anyone's needs.
      /// The following switch/case contains all the various alternatives
      /// native to Flutter.
      switch (fit) {
        case BoxFit.contain:
          double minScale = min(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = minScale;
          break;
        case BoxFit.cover:
          double maxScale = max(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = maxScale;
          break;
        case BoxFit.fill:
          scaleX = renderSize.width / contentWidth;
          scaleY = renderSize.height / contentHeight;
          break;
        case BoxFit.fitHeight:
          double minScale = renderSize.height / contentHeight;
          scaleX = scaleY = minScale;
          break;
        case BoxFit.fitWidth:
          double minScale = renderSize.width / contentWidth;
          scaleX = scaleY = minScale;
          break;
        case BoxFit.none:
          scaleX = scaleY = 1.0;
          break;
        case BoxFit.scaleDown:
          double minScale = min(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
          break;
      }

      /// 2. Move the [canvas] to the right position so that the widget's
      /// position is center-aligned based on its offset, size and alignment
      /// position.
      canvas.translate(
        renderOffset.dx +
            renderSize.width / 2.0 +
            (alignmentFlare.x * renderSize.width / 2.0),
        renderOffset.dy +
            renderSize.height / 2.0 +
            (alignmentFlare.y * renderSize.height / 2.0),
      );

      /// 3. Scale depending on the [fit].
      canvas.scale(scaleX, scaleY);

      /// 4. Move canvas to correct [_flareActor] position calculated above
      canvas.translate(x, y);

      /// 5. perform the drawing operations.
      if (useAssetOpacity) {
        double actorOpacity = asset.opacity; //useAssetOpacity?asset.opacity:1.0
        if (actorOpacity < 0.0) {
          l.w('Flare opacity is $actorOpacity, correcting to 0.0');
          asset.opacity = 0.0;
        }
        if (actorOpacity > 1.0) {
          l.w('Flare opacity is $actorOpacity, correcting to 1.0');
          asset.opacity = 1.0;
        }
        asset.actor.modulateOpacity = asset.opacity;
      }
      if (flareActor != null) {
        flareActor.draw(canvas);
      } else {
        asset.actor.draw(canvas);
      }

      /// 6. Restore the canvas' original transform state.
      canvas.restore();

      break;
  }

  /// 7. Use the [gradientColor] field to customize the foreground element
  /// being rendered, and cover it with a linear gradient.
  if (gradientColor != null) {
    double gradientFade = 1.0 - opacity;
    List<ui.Color> colors = <ui.Color>[
      gradientColor.withOpacity(gradientFade),
      gradientColor.withOpacity(min(1.0, gradientFade + 0.85))
    ];
    List<double> stops = <double>[0.0, 1.0];

    ui.Paint paint = ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset(0.0, offset.dy),
        ui.Offset(0.0, offset.dy + 150.0),
        colors,
        stops,
      )
      ..style = ui.PaintingStyle.fill;
    canvas.drawRect(offset & size, paint);
  }

  /// 8. If asset is *tappable* element, add to list so it can be processed.
  if (tapTargets != null) {
    tapTargets.add(TapTarget(asset.event, renderOffset & renderSize));
  }

  canvas.restore();
}
