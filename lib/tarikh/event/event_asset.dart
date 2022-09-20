import 'dart:ui';

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:hapi/tarikh/event/event.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

/// An object representing the renderable assets loaded from `timeline.json`.
///
/// Each [EventAsset] encapsulates all the relevant properties for drawing,
/// as well as maintaining a reference to its original [Event].
class EventAsset {
  EventAsset(this.filename, this.width, this.height, this.scale);
  final String filename;
  final double width;
  final double height;

  /// Can be overwritten
  double scale;

  /// We create the asset before we create the timeline event so init this ASAP
  late final Event event;

  double opacity = 0.0;
  double scaleVelocity = 0.0;
  double y = 0.0;
  double velocity = 0.0;
}

/// A renderable image.
class ImageAsset extends EventAsset {
  ImageAsset(
      String filename, double width, double height, double scale, this.image)
      : super(filename, width, height, scale);
  final Image image;
}

/// This asset also has information regarding its animations.
class AnimatedEventAsset extends EventAsset {
  AnimatedEventAsset(
    String filename,
    double width,
    double height,
    double scale,
    this.loop,
    this.offset,
    this.gap,
    this.animationTime,
  ) : super(filename, width, height, scale);
  final bool loop;
  final double offset;
  final double gap;

  /// Can be overwritten
  double animationTime;
}

/// A `Flare` Asset.
class FlareAsset extends AnimatedEventAsset {
  FlareAsset(
    String filename,
    double width,
    double height,
    double scale,
    bool loop,
    double offset,
    double gap,
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
  ) : super(filename, width, height, scale, loop, offset, gap, 0.0);
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
}

/// An `Nima` Asset.
class NimaAsset extends AnimatedEventAsset {
  NimaAsset(
    String filename,
    double width,
    double height,
    double scale,
    bool loop,
    double offset,
    double gap,
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
  ) : super(filename, width, height, scale, loop, offset, gap, 0.0);
  final nima.FlutterActor actorStatic;
  final nima.FlutterActor actor;
  final nima.AABB setupAABB;
  final nima.ActorAnimation animation;
}
