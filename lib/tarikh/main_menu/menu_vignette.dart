import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_asset.dart';

/// This controls the collapsable tarikh menu vinettes animations.
///
/// This widget renders a Flare/Nima [FlutterActor]. It relies on a [LeafRenderObjectWidget]
/// so it can implement a custom [RenderObject] and update it accordingly.
class MenuVignette extends LeafRenderObjectWidget {
  const MenuVignette({
    required this.needsRepaint,
    required this.gradientColor,
    required this.isActive,
    required this.event,
  });
  // TODO this is needed or good to have MAYBE?, but not used anywhere now
  // Replaced old way of using timeline null checks
  final bool needsRepaint;

  /// A gradient color to give the section background a faded look.
  /// Also makes the sub-section more readable.
  final Color gradientColor;

  /// A flag is used to animate the widget only when needed.
  final bool isActive;

  /// The id of the [FlutterActor] that will be rendered.
  final Event event;

  @override
  RenderObject createRenderObject(BuildContext context) {
    /// The [BlocProvider] widgets down the tree to access its components
    /// optimizing memory consumption and simplifying the code-base.
    return MenuVignetteRenderObject()
      ..event = event
      ..gradientColor = gradientColor
      ..isActive = isActive
      ..needsRepaint = needsRepaint;
  }

  // TODO who and when is this called?  needsRepaint needed then?
  // Need this like timeline_render_widget.dart too?:
  //   cTrkh.t.onNeedPaint = markNeedsPaint;
  //   markNeedsPaint();
  //   markNeedsLayout();
  @override
  void updateRenderObject(
      BuildContext context, covariant MenuVignetteRenderObject renderObject) {
    /// The [BlocProvider] widgets down the tree to access its components
    /// optimizing memory consumption and simplifying the code-base.
    renderObject
      ..event = event
      ..gradientColor = gradientColor
      ..isActive = isActive
      ..needsRepaint = needsRepaint;
  }

  @override
  didUnmountRenderObject(covariant MenuVignetteRenderObject renderObject) =>
      renderObject.isActive = false;
}

/// When extending a [RenderBox] we provide a custom set of instructions for the widget being rendered.
///
/// In particular this means overriding the [paint()] and [hitTestSelf()] methods to render the loaded
/// Flare/Nima [FlutterActor] where the widget is being placed.
class MenuVignetteRenderObject extends RenderBox {
  Event? _event;

  /// If this object is not active, stop playing. This optimizes resource consumption
  /// and makes sure that each [FlutterActor] remains coherent throughout its animation.
  bool _isActive = false;
  bool _firstUpdate = true;
  double _lastFrameTime = 0.0;
  Color? gradientColor;
  bool _isFrameScheduled = false;
  double opacity = 0.0; // subtracts this from opacity?, so 0 = fully lit?

  bool _needsRepaint = false;

  set needsRepaint(bool value) {
    if (_needsRepaint == value) {
      return;
    }
    _needsRepaint = value;

    _firstUpdate = true;
    updateRendering();
  }

  set event(Event event) {
    if (_event != event) {
      _event = event;
      updateRendering();
    }
  }

  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive == value) {
      return;
    }

    /// When this [RenderBox] becomes active, start advancing it again.
    _isActive = value;
    updateRendering();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performResize() => size = constraints.biggest;

  /// Uses the [SchedulerBinding] to trigger a new paint for this widget.
  void updateRendering() {
    if (_isActive) {
      markNeedsPaint();
      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }
    }
    markNeedsLayout();
  }

  /// This overridden method is where we can implement our custom drawing logic, for
  /// laying out the [FlutterActor], and drawing it to [canvas].
  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    drawAssetOnCanvas(
      event: _event,
      canvas: canvas,
      offset: offset,
      nimaActor: null,
      flareActor: null,
      alignmentNima: Alignment.topRight,
      alignmentFlare: Alignment.center,
      size: size,
      fit: BoxFit.cover,
      gradientColor: gradientColor,
      opacity: 1.0, // TOOD opacity
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
      _isFrameScheduled = true;
      _lastFrameTime = t;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    /// Calculate the elapsed time to [advance()] the animations.
    double elapsed = t - _lastFrameTime;
    _lastFrameTime = t;
    Event? event = _event;
    if (event != null) {
      EventAsset asset = event.asset;
      if (asset is NimaAsset) {
        /// Modulate the opacity value used by [gradientFade].
        if (opacity < 1.0) opacity = min(opacity + elapsed, 1.0);
        asset.animationTime += elapsed;
        if (asset.loop) asset.animationTime %= asset.animation.duration;

        /// Apply the current time to the [asset] animation.
        asset.animation.apply(asset.animationTime, asset.actor, 1.0);

        /// Use the library function to update the actor's time.
        asset.actor.advance(elapsed);
      } else if (asset is FlareAsset) {
        /// Modulate the opacity value used by [gradientFade].
        if (opacity < 1.0) opacity = min(opacity + elapsed, 1.0);

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
        if (asset.intro == asset.animation &&
            asset.animationTime >= asset.animation.duration) {
          asset.animationTime -= asset.animation.duration;
          asset.animation = asset.idle!;
        }
        if (asset.loop && asset.animationTime >= 0) {
          asset.animationTime %= asset.animation.duration;
        }

        /// Apply the current time to this [ActorAnimation].
        asset.animation.apply(asset.animationTime, asset.actor, 1.0);

        /// Use the library function to update the actor's time.
        asset.actor.advance(elapsed);
      }
    }

    /// Invalidate the current widget visual state and let Flutter paint it again.
    // Tez: fixes exception when hitting back button from history detail page
    //     // TODO isActive was not here before, needed to fix exception after upgrading
    //     // flutter version:
    //     if (isActive) {
    if (_isActive) markNeedsPaint();

    /// Schedule a new frame to update again - but only if needed.
    if (isActive && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }
}
