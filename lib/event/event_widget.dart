import 'dart:math';

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_dart/math/vec2d.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hapi/event/animation_controller/flare_interaction_controller.dart';
import 'package:hapi/event/animation_controller/newton_controller.dart';
import 'package:hapi/event/animation_controller/nima_interaction_controller.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_asset.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;
import 'package:nima/nima/math/vec2d.dart' as nima;

/// This widget renders a single [Event]. It relies on a [LeafRenderObjectWidget]
/// so it can implement a custom [RenderObject] and update it accordingly.
class EventWidget extends LeafRenderObjectWidget {
  const EventWidget({
    required this.event,
    required this.isActive,
    this.interactOffset,
  });
  final Event event;
  final bool isActive; // flag to start/stop animations when needed

  /// If this widget also has a custom controller, the [interactOffset]
  /// parameter can be used to detect motion effects and alter the [FlareActor] accordingly.
  final Offset? interactOffset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return VignetteRenderObject()
      ..event = event
      ..isActive = isActive
      ..interactOffset = interactOffset;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant VignetteRenderObject renderObject) {
    renderObject
      ..event = event
      ..isActive = isActive
      ..interactOffset = interactOffset;
  }

  @override
  didUnmountRenderObject(covariant VignetteRenderObject renderObject) {
    renderObject
      ..isActive = false
      ..event = null;
  }
}

/// When extending a [RenderBox] we provide a custom set of instructions for the widget being rendered.
///
/// In particular this means overriding the [paint()] and [hitTestSelf()] methods to render the loaded
/// Flare/Nima [FlutterActor] where the widget is being placed.
class VignetteRenderObject extends RenderBox {
  static const Alignment alignment = Alignment.center;

  bool _isActive = false;
  bool _firstUpdate = true;
  bool _isFrameScheduled = false;
  double _lastFrameTime = 0.0;
  Offset? interactOffset;
  Offset? _renderOffset;

  Event? _event;
  nima.FlutterActor? _nimaActor;
  flare.FlutterActorArtboard? _flareActor;
  FlareInteractionController? _flareController;
  NimaInteractionController? _nimaController;

  /// Called whenever a new [Event] is being set.
  updateActor() {
    if (_event == null) {
      /// If [_event] is removed, free its resources.
      _nimaActor?.dispose();
      _flareActor?.dispose();
      _nimaActor = null;
      _flareActor = null;
    } else {
      EventAsset asset = _event!.asset;
      if (asset is NimaAsset) {
        /// Instance [_nimaActor] through the actor reference in the asset
        /// and set the initial starting value for its animation.
        _nimaActor = asset.actor.makeInstance() as nima.FlutterActor;
        asset.animation.apply(asset.animation.duration, _nimaActor, 1.0);
        _nimaActor!.advance(0.0);
        if (asset.filename == 'assets/tarikh/nima/Newton_v2.nma') {
          /// Newton uses a custom controller! =)
          _nimaController = NewtonController();
          _nimaController!.initialize(_nimaActor!);
        }
      } else if (asset is FlareAsset) {
        /// Instance [_flareActor] through the actor reference in the asset
        /// and set the initial starting value for its animation.
        _flareActor = asset.actor.makeInstance() as flare.FlutterActorArtboard;
        _flareActor!.initializeGraphics();
        asset.animation.apply(asset.animation.duration, _flareActor, 1.0);
        _flareActor!.advance(0.0);
      }
    }
  }

  /// Uses the [SchedulerBinding] to trigger a new paint for this widget.
  void updateRendering() {
    if (_isActive && _event != null) {
      markNeedsPaint();
      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }
    }
    markNeedsLayout();
  }

  Event? get event => _event;
  set event(Event? value) {
    if (_event == value) {
      return;
    }
    _event = value;
    _firstUpdate = true;
    updateActor();
    updateRendering();
  }

  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive == value) {
      return;
    }
    _isActive = value;
    updateRendering();
  }

  /// The size of this widget is determined by its parent, for optimization purposes.
  @override
  bool get sizedByParent => true;

  /// Determine if this widget has been tapped. If that's the case, restart its animation.
  @override
  bool hitTestSelf(Offset screenOffset) {
    if (_event != null) {
      EventAsset asset = _event!.asset;
      if (asset is NimaAsset) {
        asset.animationTime = 0.0;
      } else if (asset is FlareAsset) {
        asset.animationTime = 0.0;
      }
    }
    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// This overridden method is where we can implement our custom logic, for
  /// laying out the [FlutterActor], and drawing it to [canvas].
  @override
  void paint(PaintingContext context, Offset offset) async {
    final Canvas canvas = context.canvas;
    _renderOffset = offset;

    drawAssetOnCanvas(
      event: _event,
      canvas: canvas,
      offset: offset,
      nimaActor: _nimaActor, // needed or EventWidget() doesn't animate
      flareActor: _flareActor, // needed or EventWidget() doesn't animate
      alignmentNima: alignment,
      alignmentFlare: alignment,
      size: size,
      fit: BoxFit.contain,
      gradientColor: null,
      opacity: 1.0,
      useAssetOpacity: false,
      rs: 1.0,
      assetScreenScale: 1.0,
      useOffsetHorizontal: false,
      tapTargets: null,
    );
  }

  /// This callback is used by the [SchedulerBinding] in order to advance the Flare/Nima
  /// animations properly, and update the corresponding [FlutterActor]s.
  /// It is also responsible for advancing any attached components to said Actors,
  /// such as [_nimaController] or [_flareController].
  void beginFrame(Duration timeStamp) {
    _isFrameScheduled = false;
    final double t =
        timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    if (_lastFrameTime == 0) {
      _lastFrameTime = t;
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    /// Calculate the elapsed time to [advance()] the animations.
    double elapsed = t - _lastFrameTime;
    _lastFrameTime = t;
    if (_event != null) {
      EventAsset asset = _event!.asset;
      if (asset is NimaAsset && _nimaActor != null) {
        asset.animationTime += elapsed;

        if (asset.loop) {
          asset.animationTime %= asset.animation.duration;
        }

        /// Apply the current time to the [asset] animation.
        asset.animation.apply(asset.animationTime, _nimaActor, 1.0);
        if (_nimaController != null) {
          nima.Vec2D? localTouchPosition;
          if (interactOffset != null) {
            nima.AABB bounds = asset.setupAABB;
            double contentHeight = bounds[3] - bounds[1];
            double contentWidth = bounds[2] - bounds[0];
            double x = -bounds[0] -
                contentWidth / 2.0 -
                (alignment.x * contentWidth / 2.0);
            double y = -bounds[1] -
                contentHeight / 2.0 +
                (alignment.y * contentHeight / 2.0);

            double scaleX = 1.0, scaleY = 1.0;

            // switch (fit) {
            //   case BoxFit.fill:
            //     scaleX = size.width / contentWidth;
            //     scaleY = size.height / contentHeight;
            //     break;
            //   case BoxFit.contain:
            double minScale =
                min(size.width / contentWidth, size.height / contentHeight);
            scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.cover:
            //     double maxScale =
            //         max(size.width / contentWidth, size.height / contentHeight);
            //     scaleX = scaleY = maxScale;
            //     break;
            //   case BoxFit.fitHeight:
            //     double minScale = size.height / contentHeight;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.fitWidth:
            //     double minScale = size.width / contentWidth;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.none:
            //     scaleX = scaleY = 1.0;
            //     break;
            //   case BoxFit.scaleDown:
            //     double minScale =
            //         min(size.width / contentWidth, size.height / contentHeight);
            //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
            //     break;
            // }
            double dx = interactOffset!.dx -
                (_renderOffset!.dx +
                    size.width / 2.0 +
                    (alignment.x * size.width / 2.0));
            double dy = interactOffset!.dy -
                (_renderOffset!.dy +
                    size.height / 2.0 +
                    (alignment.y * size.height / 2.0));
            dx /= scaleX;
            dy /= -scaleY;
            dx -= x;
            dy -= y;

            /// Use this logic to evaluate the correct touch position that will
            /// be passed down to [NimaInteractionController.advance()].
            localTouchPosition = nima.Vec2D.fromValues(dx, dy);
          }

          /// This custom [NimaInteractionController] uses [localTouchPosition] to perform its calculations.
          _nimaController!.advance(_nimaActor!, localTouchPosition, elapsed);
        }
        _nimaActor!.advance(elapsed);
      } else if (asset is FlareAsset && _flareActor != null) {
        /// Some [TimelineFlare] assets have a custom intro that's played
        /// when they're painted for the first time.
        if (_firstUpdate) {
          if (asset.intro != null) {
            asset.animation = asset.intro!;
            asset.animationTime = -1.0;
          }
          _firstUpdate = false;
        }
        asset.animationTime += elapsed;
        if (asset.idleAnimations != null) {
          /// If an [idleAnimation] is set up, the current time is calculated and applied to it.
          double phase = 0.0;
          for (flare.ActorAnimation animation in asset.idleAnimations!) {
            animation.apply((asset.animationTime + phase) % animation.duration,
                _flareActor, 1.0);
            phase += 0.16;
          }
        } else {
          if (asset.intro == asset.animation &&
              asset.animationTime >= asset.animation.duration) {
            asset.animationTime -= asset.animation.duration;
            asset.animation = asset.idle!;
          }
          if (asset.loop && asset.animationTime >= 0) {
            asset.animationTime %= asset.animation.duration;
          }

          /// Apply the current time to this [ActorAnimation].
          asset.animation.apply(asset.animationTime, _flareActor, 1.0);
        }
        if (_flareController != null) {
          flare.Vec2D? localTouchPosition;
          if (interactOffset != null) {
            flare.AABB bounds = asset.setupAABB;
            double contentWidth = bounds[2] - bounds[0];
            double contentHeight = bounds[3] - bounds[1];
            double x = -bounds[0] -
                contentWidth / 2.0 -
                (alignment.x * contentWidth / 2.0);
            double y = -bounds[1] -
                contentHeight / 2.0 +
                (alignment.y * contentHeight / 2.0);

            double scaleX = 1.0, scaleY = 1.0;

            // switch (fit) {
            //   case BoxFit.fill:
            //     scaleX = size.width / contentWidth;
            //     scaleY = size.height / contentHeight;
            //     break;
            //   case BoxFit.contain:
            double minScale =
                min(size.width / contentWidth, size.height / contentHeight);
            scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.cover:
            //     double maxScale =
            //         max(size.width / contentWidth, size.height / contentHeight);
            //     scaleX = scaleY = maxScale;
            //     break;
            //   case BoxFit.fitHeight:
            //     double minScale = size.height / contentHeight;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.fitWidth:
            //     double minScale = size.width / contentWidth;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.none:
            //     scaleX = scaleY = 1.0;
            //     break;
            //   case BoxFit.scaleDown:
            //     double minScale =
            //         min(size.width / contentWidth, size.height / contentHeight);
            //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
            //     break;
            // }
            double dx = interactOffset!.dx -
                (_renderOffset!.dx +
                    size.width / 2.0 +
                    (alignment.x * size.width / 2.0));
            double dy = interactOffset!.dy -
                (_renderOffset!.dy +
                    size.height / 2.0 +
                    (alignment.y * size.height / 2.0));
            dx /= scaleX;
            dy /= scaleY;
            dx -= x;
            dy -= y;

            /// Use this logic to evaluate the correct touch position that will
            /// be passed down to [FlareInteractionController.advance()].
            localTouchPosition = flare.Vec2D.fromValues(dx, dy);
          }

          /// Perform the actual [advance()]ing.
          if (localTouchPosition != null) {
            _flareController!
                .advance(_flareActor!, localTouchPosition, elapsed);
          }
        }

        /// Advance the [FlutterActorArtboard].
        _flareActor!.advance(elapsed);
      }
    }

    // Tez: fixes exception when hitting back button from history detail page
    // TODO isActive was not here before, needed to fix exception after upgrading
    // flutter version:
    if (isActive) {
      /// Invalidate the current widget visual state and let Flutter paint it again.
      markNeedsPaint();
    }

    /// Schedule a new frame to update again - but only if needed.
    if (isActive && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }
}
