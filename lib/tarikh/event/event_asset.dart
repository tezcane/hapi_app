import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/services.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

enum ASSET_TYPE {
  IMAGE,
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

  double opacity = .5; // TODO tune, opacity of pictures on the menu
  double scaleVelocity = 0.0; // TODO what does it do?
  double y = 0.0; // TODO what does it do?
  double velocity = 0.0; // TODO what does it do?

  // Abstract method:
  ASSET_TYPE getAssetType();
}

/// A renderable image.
class ImageAsset extends EventAsset {
  ImageAsset(
      String filename, double width, double height, double scale, this.image)
      : super(filename, width, height, scale);
  final ui.Image image;

  @override
  ASSET_TYPE getAssetType() => ASSET_TYPE.IMAGE;
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
}

/// An `Nima` Asset.
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
  ASSET_TYPE getAssetType() => ASSET_TYPE.NIMA;
}

/// A `Flare` Asset.
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
  ASSET_TYPE getAssetType() => ASSET_TYPE.FLARE;
}

Future<ImageAsset> loadImageAsset(
  String filename,
  double width,
  double height,
  double scale,
) async {
  ByteData data = await rootBundle.load(filename);
  Uint8List list = Uint8List.view(data.buffer);
  ui.Codec codec = await ui.instantiateImageCodec(list);
  ui.FrameInfo frame = await codec.getNextFrame();

  return ImageAsset(filename, width, height, scale, frame.image);
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
//  if (filename.endsWith('jpg')) return ASSET_TYPE.IMAGE;
    if (filename.endsWith('nma')) return ASSET_TYPE.NIMA;
    if (filename.endsWith('flr')) return ASSET_TYPE.FLARE;

    l.w('Unknown file extension: $filename, default to ASSET_TYPE.IMAGE');
    return ASSET_TYPE.IMAGE;
  }

  String filename = 'assets/' + asset.source;

  /// Instantiate the correct object based on the file extension.
  final EventAsset eventAsset;
  switch (_parseAssetType(asset.source)) {
    case ASSET_TYPE.IMAGE:
      eventAsset = await loadImageAsset(
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

/// To init relics easier we use this class as a helper.
class RelicAsset {
  const RelicAsset(
    this.filename, {
    this.width = 200.0,
    this.height = 200.0,
    this.scale = 1.0,
  });
  final String filename;
  final double width;
  final double height;
  final double scale;

  Future<EventAsset> toImageEventAsset() async =>
      await loadImageAsset(filename, width, height, scale);
}
