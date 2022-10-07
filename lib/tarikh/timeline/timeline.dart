import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';

typedef PaintCallback = Function();
typedef ChangeEraCallback = Function(Event? era);
typedef ChangeHeaderColorCallback = Function(/*Color background,*/ Color text);

class Timeline {
  Timeline(
    this._rootEvents,
    this._tickColors,
    this._headerColors,
    this._timeMin,
    this._timeMax,
  ) {
    _headerColorsReversed = _headerColors.reversed;
    setViewport(start: 1536.0, end: 3072.0); // TODO what is this?
  }

  /// All the [Event]s that are loaded from disk at boot (in [loadFromBundle()]).
  /// List for "root" events, i.e. events with no parents.
  final List<Event> _rootEvents;

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  final List<TickColors> _tickColors;
  final List<HeaderColors> _headerColors;
  late final Iterable<HeaderColors> _headerColorsReversed;

  final double _timeMin;
  final double _timeMax;

  /// The list of [EventAsset], loaded from disk at boot and stored.
  List<EventAsset> _renderedAssets = [];

  /// Some aptly named constants for properly aligning the Timeline view.
  static const double LineWidth = 2.0;
  static const double LineSpacing = 10.0;
  static const double DepthOffset = LineSpacing + LineWidth;

  static const double EdgePadding = 8.0;
  static const double MoveSpeed = 10.0;
  static const double MoveSpeedInteracting = 40.0;
  static const double Deceleration = 3.0;
  static const double GutterLeft = 45.0; //was 45.0;
  static const double GutterLeftExpanded = 110.0; //was 75.0

  static const double EdgeRadius = 4.0;
  static const double MinChildLength = 50.0;
  static const double BubbleHeight = 50.0;
  static const double BubblePadding = 20.0;
  static const double BubbleTextHeight = 20.0;
  static const double AssetPadding = 30.0;
  static const double Parallax = 100.0;
  static const double AssetScreenScale = 0.3;

  static const double ViewportPaddingTop = 120.0;
  static const double ViewportPaddingBottom = 100.0;
  static const int SteadyMilliseconds = 500;

  double _start = 0.0;
  double _end = 0.0;
  double _renderStart = double.maxFinite; // TODO sets size of ticks?
  double _renderEnd = double.maxFinite;
  double _lastFrameTime = 0.0;
  double _height = 0.0;
  double _firstOnScreenEventY = 0.0;
  double _lastEventY = 0.0;
  double _lastOnScreenEventY = 0.0;
  double _offsetDepth = 0.0;
  double _renderOffsetDepth = 0.0;
  double _labelX = 0.0;
  double _renderLabelX = 0.0;
  double _lastAssetY = 0.0;
  double _prevEventOpacity = 0.0;
  double _distanceToPrevEvent = 0.0;
  double _nextEventOpacity = 0.0;
  double _distanceToNextEvent = 0.0;
  double _simulationTime = 0.0;
  double _gutterWidth = GutterLeft;

  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isSteady = false;

  HeaderColors? _currentHeaderColors;

  Color? _headerTextColor;
//Color? _headerBackgroundColor;

  /// Depending on the current [Platform], different values are initialized
  /// so that they behave properly on iOS&Android.
  ScrollPhysics? _scrollPhysics;

  /// [_scrollPhysics] needs a [ScrollMetrics] value to function.
  ScrollMetrics? _scrollMetrics;
  Simulation? _scrollSimulation;

  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets devicePadding = EdgeInsets.zero;

  Timer? _steadyTimer;

  /// Through these two references, the Timeline can access the era and update
  /// the top label accordingly.
  Event? _currentEra;
  Event? _lastEra;

  /// These references allow to maintain a reference to the next and previous elements
  /// of the Timeline, depending on which elements are currently in focus.
  /// When there's enough space on the top/bottom, the Timeline will render a round button
  /// with an arrow to link to the next/previous element.
  Event? _nextEvent;
  Event? _renderNextEvent;
  Event? _prevEvent;
  Event? _renderPrevEvent;

  /// Callback set by [TimelineRenderWidget] when adding a reference to this object.
  /// It'll trigger [RenderBox.markNeedsPaint()].
  PaintCallback? onNeedPaint;

  /// These next two callbacks are bound to set the state of the [TimelineWidget]
  /// so it can change the appearance of the top AppBar.
  ChangeEraCallback? onEraChanged;
  ChangeHeaderColorCallback? onHeaderColorsChanged;

  Event? get currentEra => _currentEra;

  List<EventAsset> get renderedAssets => _renderedAssets;

  double get renderOffsetDepth => _renderOffsetDepth;
  double get renderLabelX => _renderLabelX;
  double get start => _start;
  double get end => _end;
  double get renderStart => _renderStart;
  double get renderEnd => _renderEnd;
  double get gutterWidth => _gutterWidth;

  Event? get nextEvent => _renderNextEvent;
  Event? get prevEvent => _renderPrevEvent;
  double get nextEventOpacity => _nextEventOpacity;
  double get prevEventOpacity => _prevEventOpacity;

  bool get isInteracting => _isInteracting;

  Color? get headerTextColor => _headerTextColor;

  /// When a scale operation is detected, this setter is called:
  /// e.g. [_TimelineWidgetState.scaleStart()].
  set isInteracting(bool value) {
    if (value != _isInteracting) {
      _isInteracting = value;
      _updateSteady();
    }
  }

  /// Used to detect if the current scaling operation is still happening
  /// during the current frame in [advance()].
  set isScaling(bool value) {
    if (value != _isScaling) {
      _isScaling = value;
      _updateSteady();
    }
  }

  /// Check that the viewport is steady - i.e. no taps, pans, scales or other gestures are being detected.
  void _updateSteady() {
    bool isIt = !_isInteracting && !_isScaling;

    /// If a timer is currently active, dispose it.
    if (_steadyTimer != null) {
      _steadyTimer!.cancel();
      _steadyTimer = null;
    }

    if (isIt) {
      /// If another timer is still needed, recreate it.
      _steadyTimer =
          Timer(const Duration(milliseconds: SteadyMilliseconds), () {
        _steadyTimer = null;
        _isSteady = true;
        startRendering();
      });
    } else {
      /// Otherwise update the current state and schedule a new frame.
      _isSteady = false;
      startRendering();
    }
  }

  /// Schedule a new frame.
  startRendering() {
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  double screenPaddingInTime(double padding, double start, double end) {
    return padding / computeScale(start, end);
  }

  /// Compute the viewport scale from the start/end times.
  double computeScale(double start, double end) {
    return _height == 0.0 ? 1.0 : _height / (end - start);
  }

  /// Make sure that while scrolling we're within the correct timeline bounds.
  clampScroll() {
    _scrollMetrics = null;
    _scrollPhysics = null;
    _scrollSimulation = null;

    /// Get measurements values for the current viewport.
    double scale = computeScale(_start, _end);
    double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
    double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
    bool fixStart = _start < _timeMin - padTop;
    bool fixEnd = _end > _timeMax + padBottom;

    /// As the scale changes we need to re-solve the right padding
    /// Don't think there's an analytical single solution for this
    /// so we do it in steps approaching the correct answer.
    for (int i = 0; i < 20; i++) {
      double scale = computeScale(_start, _end);
      double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
      double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
      if (fixStart) {
        _start = _timeMin - padTop;
      }
      if (fixEnd) {
        _end = _timeMax + padBottom;
      }
    }
    if (_end < _start) {
      _end = _start + _height / scale;
    }

    /// Be sure to reschedule a new frame.
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  /// This method bounds the current viewport depending on the current start and end positions.
  void setViewport(
      {double start = double.maxFinite,
      bool pad = false,
      double end = double.maxFinite,
      double height = double.maxFinite,
      double velocity = double.maxFinite,
      bool animate = false}) {
    /// Calculate the current height.
    if (height != double.maxFinite) {
      if (_height == 0.0) {
        double scale = height / (_end - _start);
        _start = _start - padding.top / scale;
        _end = _end + padding.bottom / scale;
      }
      _height = height;
    }

    /// If a value for start&end has been provided, evaluate the top/bottom position
    /// for the current viewport accordingly.
    /// Otherwise build the values separately.
    if (start != double.maxFinite && end != double.maxFinite) {
      _start = start;
      _end = end;
      if (pad && _height != 0.0) {
        double scale = _height / (_end - _start);
        _start = _start - padding.top / scale;
        _end = _end + padding.bottom / scale;
      }
    } else {
      if (start != double.maxFinite) {
        double scale = height / (_end - _start);
        _start = pad ? start - padding.top / scale : start;
      }
      if (end != double.maxFinite) {
        double scale = height / (_end - _start);
        _end = pad ? end + padding.bottom / scale : end;
      }
    }

    /// If a velocity value has been passed, use the [ScrollPhysics] to create
    /// a simulation and perform scrolling natively to the current platform.
    if (velocity != double.maxFinite) {
      double scale = computeScale(_start, _end);
      double padTop =
          (devicePadding.top + ViewportPaddingTop) / computeScale(_start, _end);
      double padBottom = (devicePadding.bottom + ViewportPaddingBottom) /
          computeScale(_start, _end);
      double rangeMin = (_timeMin - padTop) * scale;
      double rangeMax = (_timeMax + padBottom) * scale - _height;
      if (rangeMax < rangeMin) {
        rangeMax = rangeMin;
      }

      _simulationTime = 0.0;
      // TODO test this on all platforms
      // The current platform is initialized at boot, to properly initialize
      // [ScrollPhysics] based on the platform we're on.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _scrollPhysics = const BouncingScrollPhysics();
      } else {
        _scrollPhysics = const ClampingScrollPhysics();
      }
      _scrollMetrics = FixedScrollMetrics(
          minScrollExtent: double.negativeInfinity,
          maxScrollExtent: double.infinity,
          pixels: 0.0,
          viewportDimension: _height,
          axisDirection: AxisDirection.down);

      _scrollSimulation =
          _scrollPhysics!.createBallisticSimulation(_scrollMetrics!, velocity);
    }
    if (!animate) {
      _renderStart = start;
      _renderEnd = end;
      advance(0.0, false);
      if (onNeedPaint != null) {
        onNeedPaint!();
      }
    } else if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  /// Make sure that all the visible assets are being rendered and advanced
  /// according to the current state of the timeline.
  void beginFrame(Duration timeStamp) {
    _isFrameScheduled = false;
    final double time =
        timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    if (_lastFrameTime == 0.0) {
      _lastFrameTime = time;
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    double elapsed = time - _lastFrameTime;
    _lastFrameTime = time;

    if (!advance(elapsed, true) && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }

    // Tez: fixes exception when hitting back button from timeline back to root page
    // TODO isActive was not here before, needed to fix exception after upgrading
    // flutter version:
    if (TarikhC.to.isActiveTimeline && onNeedPaint != null) {
      onNeedPaint!();
    }
  }

  bool advance(double elapsed, bool animate) {
    if (_height <= 0) {
      /// Done rendering. Need to wait for height.
      return true;
    }

    /// The current scale based on the rendering area.
    double scale = _height / (_renderEnd - _renderStart);

    bool doneRendering = true;
    bool stillScaling = true;

    /// If the timeline is performing a scroll operation adjust the viewport
    /// based on the elapsed time.
    if (_scrollSimulation != null) {
      doneRendering = false;
      _simulationTime += elapsed;
      double scale = _height / (_end - _start);
      double velocity = _scrollSimulation!.dx(_simulationTime);

      double displace = velocity * elapsed / scale;

      _start -= displace;
      _end -= displace;

      /// If scrolling has terminated, clean up the resources.
      if (_scrollSimulation!.isDone(_simulationTime)) {
        _scrollMetrics = null;
        _scrollPhysics = null;
        _scrollSimulation = null;
      }
    }

    /// Check if the left-hand side gutter has been toggled.
    /// If visible, make room for it.
    double targetGutterWidth =
        TarikhC.to.isGutterModeOff ? GutterLeft : GutterLeftExpanded;
    double dgw = targetGutterWidth - _gutterWidth;
    if (!animate || dgw.abs() < 1) {
      _gutterWidth = targetGutterWidth;
    } else {
      doneRendering = false;
      _gutterWidth += dgw * min(1.0, elapsed * 10.0);
    }

    /// Animate movement.
    double speed =
        min(1.0, elapsed * (_isInteracting ? MoveSpeedInteracting : MoveSpeed));
    double ds = _start - _renderStart;
    double de = _end - _renderEnd;

    /// If the current view is animating, adjust the [_renderStart]/[_renderEnd] based on the interaction speed.
    if (!animate || ((ds * scale).abs() < 1.0 && (de * scale).abs() < 1.0)) {
      stillScaling = false;
      _renderStart = _start;
      _renderEnd = _end;
    } else {
      doneRendering = false;
      _renderStart = _renderStart + (ds * speed);
      _renderEnd = _renderEnd + (de * speed);
    }
    isScaling = stillScaling;

    /// Update scale after changing render range.
    scale = _height / (_renderEnd - _renderStart);

    /// Update color screen positions.
    double lastStart = _tickColors.first.startMs;
    for (TickColors color in _tickColors) {
      color.screenY =
          (lastStart + (color.startMs - lastStart / 2.0) - _renderStart) *
              scale;
      lastStart = color.startMs;
    }

    lastStart = _headerColors.first.startMs;
    for (HeaderColors color in _headerColors) {
      color.screenY =
          (lastStart + (color.startMs - lastStart / 2.0) - _renderStart) *
              scale;
      lastStart = color.startMs;
    }

    // old _findHeaderColors() logic:
    double screen = 0.0;
    HeaderColors? headerColors;
    for (HeaderColors color in _headerColorsReversed) {
      if (screen >= color.screenY) {
        headerColors = color;
      }
    }
    headerColors ??= screen < _headerColors.first.screenY
        ? _headerColors.first
        : _headerColors.last;
    _currentHeaderColors = headerColors;

    if (_headerTextColor == null) {
      _headerTextColor = _currentHeaderColors!.text;
      //_headerBackgroundColor = _currentHeaderColors!.background;
    } else {
      bool stillColoring = false;
      Color headerTextColor = _interpolateColor(
        _headerTextColor!,
        _currentHeaderColors!.text,
        elapsed,
      );

      if (headerTextColor != _headerTextColor) {
        _headerTextColor = headerTextColor;
        stillColoring = true;
        doneRendering = false;
      }
      // Color headerBackgroundColor = interpolateColor(
      //     _headerBackgroundColor!, _currentHeaderColors!.background, elapsed);
      // if (headerBackgroundColor != _headerBackgroundColor) {
      //   _headerBackgroundColor = headerBackgroundColor;
      //   stillColoring = true;
      //   doneRendering = false;
      // }
      if (stillColoring) {
        if (onHeaderColorsChanged != null) {
          //onHeaderColorsChanged!(_headerBackgroundColor!, _headerTextColor!);
          onHeaderColorsChanged!(_headerTextColor!);
        }
      }
    }

    /// Check all the visible events and use the helper function [advanceItems()]
    /// to align their state with the elapsed time.
    /// Set all the initial values to defaults so that everything's consistent.
    _lastEventY = -double.maxFinite;
    _lastOnScreenEventY = 0.0;
    _firstOnScreenEventY = double.maxFinite;
    _lastAssetY = -double.maxFinite;
    _labelX = 0.0;
    _offsetDepth = 0.0;
    _currentEra = null;
    _nextEvent = null;
    _prevEvent = null;

    /// Advance the items hierarchy one level at a time.
    if (_advanceEvents(
        _rootEvents, _gutterWidth + LineSpacing, scale, elapsed, animate, 0)) {
      doneRendering = false;
    }

    /// Advance all the assets and add the rendered ones into [_renderAssets].
    _renderedAssets = []; // resets here, where all UI cleanup is done?
    if (_advanceAssets(_rootEvents, elapsed, animate, _renderedAssets)) {
      doneRendering = false;
    }

    if (_nextEventOpacity == 0.0) {
      _renderNextEvent = _nextEvent;
    }

    /// Determine next event's opacity and interpolate, if needed, towards that value.
    double targetNextEventOpacity = _lastOnScreenEventY > _height / 1.7 ||
            !_isSteady ||
            _distanceToNextEvent < 0.01 ||
            _nextEvent != _renderNextEvent
        ? 0.0
        : 1.0;
    double dt = targetNextEventOpacity - _nextEventOpacity;

    if (!animate || dt.abs() < 0.01) {
      _nextEventOpacity = targetNextEventOpacity;
    } else {
      doneRendering = false;
      _nextEventOpacity += dt * min(1.0, elapsed * 10.0);
    }

    if (_prevEventOpacity == 0.0) {
      _renderPrevEvent = _prevEvent;
    }

    /// Determine previous event's opacity and interpolate, if needed, towards that value.
    double targetPrevEventOpacity = _firstOnScreenEventY < _height / 2.0 ||
            !_isSteady ||
            _distanceToPrevEvent < 0.01 ||
            _prevEvent != _renderPrevEvent
        ? 0.0
        : 1.0;
    dt = targetPrevEventOpacity - _prevEventOpacity;

    if (!animate || dt.abs() < 0.01) {
      _prevEventOpacity = targetPrevEventOpacity;
    } else {
      doneRendering = false;
      _prevEventOpacity += dt * min(1.0, elapsed * 10.0);
    }

    /// Interpolate the horizontal position of the label.
    double dl = _labelX - _renderLabelX;
    if (!animate || dl.abs() < 1.0) {
      _renderLabelX = _labelX;
    } else {
      doneRendering = false;
      _renderLabelX += dl * min(1.0, elapsed * 6.0);
    }

    /// If a new era is currently in view, callback.
    if (_currentEra != _lastEra) {
      _lastEra = _currentEra;
      if (onEraChanged != null) {
        onEraChanged!(_currentEra);
      }
    }

    if (_isSteady) {
      double dd = _offsetDepth - renderOffsetDepth;
      if (!animate || dd.abs() * DepthOffset < 1.0) {
        _renderOffsetDepth = _offsetDepth;
      } else {
        /// Needs a second run.
        doneRendering = false;
        _renderOffsetDepth += dd * min(1.0, elapsed * 12.0);
      }
    }

    return doneRendering;
  }

  double bubbleHeight(Event event) =>
      (BubblePadding * 1.15) +
      ((event.isBubbleTextThick ? 2 : 1) * BubbleTextHeight);

  /// Advance event [assets] with the current [elapsed] time.
  bool _advanceEvents(
    List<Event> events,
    double x,
    double scale,
    double elapsed,
    bool animate,
    int depth,
  ) {
    bool stillAnimating = false;
    double lastEnd = -double.maxFinite;
    for (int i = 0; i < events.length; i++) {
      Event event = events[i];

      double start = event.startMs - _renderStart;
      double end = event.isEra ? event.endMs - _renderStart : start;

      /// Vertical position for this element.
      double y = start * scale; // +pad;
      if (i > 0 && y - lastEnd < EdgePadding) {
        y = lastEnd + EdgePadding;
      }

      /// Adjust based on current scale value.
      double endY = end * scale; //-pad;
      /// Update the reference to the last found element.
      lastEnd = endY;

      event.length = endY - y;

      /// Calculate the best location for the bubble/label.
      double targetLabelY = y;
      double itemBubbleHeight = bubbleHeight(event);
      double fadeAnimationStart = itemBubbleHeight + BubblePadding / 2.0;
      if (targetLabelY - _lastEventY < fadeAnimationStart &&
          // The best location for our label is occluded, lets see if we can
          // bump it forward...
          event.isEra &&
          _lastEventY + fadeAnimationStart < endY) {
        targetLabelY = _lastEventY + fadeAnimationStart + 0.5;
      }

      /// Determine if the label is in view.
      double targetLabelOpacity =
          targetLabelY - _lastEventY < fadeAnimationStart ? 0.0 : 1.0;

      /// Debounce labels becoming visible.
      if (targetLabelOpacity > 0.0 && event.targetLabelOpacity != 1.0) {
        event.delayLabel = 0.5;
      }
      event.targetLabelOpacity = targetLabelOpacity;
      if (event.delayLabel > 0.0) {
        targetLabelOpacity = 0.0;
        event.delayLabel -= elapsed;
        stillAnimating = true;
      }

      double dt = targetLabelOpacity - event.labelOpacity;
      if (!animate || dt.abs() < 0.01) {
        event.labelOpacity = targetLabelOpacity;
      } else {
        stillAnimating = true;
        event.labelOpacity += dt * min(1.0, elapsed * 25.0);
      }

      /// Assign current vertical position.
      event.y = y;
      event.endY = endY;

      double targetLegOpacity = event.length > EdgeRadius ? 1.0 : 0.0;
      double dtl = targetLegOpacity - event.legOpacity;
      if (!animate || dtl.abs() < 0.01) {
        event.legOpacity = targetLegOpacity;
      } else {
        stillAnimating = true;
        event.legOpacity += dtl * min(1.0, elapsed * 20.0);
      }

      double targetItemOpacity = event.parent != null
          ? event.parent!.length < MinChildLength ||
                  (event.parent != null && event.parent!.endY < y)
              ? 0.0
              : y > event.parent!.y
                  ? 1.0
                  : 0.0
          : 1.0;
      dtl = targetItemOpacity - event.opacity;
      if (!animate || dtl.abs() < 0.01) {
        event.opacity = targetItemOpacity;
      } else {
        stillAnimating = true;
        event.opacity += dtl * min(1.0, elapsed * 20.0);
      }

      /// Animate the label position.
      double targetLabelVelocity = targetLabelY - event.labelY;
      double dvy = targetLabelVelocity - event.labelVelocity;
      if (dvy.abs() > _height) {
        event.labelY = targetLabelY;
        event.labelVelocity = 0.0;
      } else {
        event.labelVelocity += dvy * elapsed * 18.0;
        event.labelY += event.labelVelocity * elapsed * 20.0;
      }

      /// Check the final position has been reached, otherwise raise a flag.
      if (animate &&
          (event.labelVelocity.abs() > 0.01 ||
              targetLabelVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      if (event.targetLabelOpacity > 0.0) {
        _lastEventY = targetLabelY;
        if (_lastEventY < _height && _lastEventY > devicePadding.top) {
          _lastOnScreenEventY = _lastEventY;
          if (_firstOnScreenEventY == double.maxFinite) {
            _firstOnScreenEventY = _lastEventY;
          }
        }
      }

      if (event.isEra && y < 0 && endY > _height && depth > _offsetDepth) {
        _offsetDepth = depth.toDouble();
      }

      /// A new era is currently in view.
      if (event.isEra && y < 0 && endY > _height / 2.0) {
        _currentEra = event;
      }

      /// Check if the bubble is out of view and set the y position to the
      /// target one directly.
      if (y > _height + itemBubbleHeight) {
        event.labelY = y;
        if (_nextEvent == null) {
          _nextEvent = event;
          _distanceToNextEvent = (y - _height) / _height;
        }
      } else if (endY < devicePadding.top) {
        _prevEvent = event;
        _distanceToPrevEvent = ((y - _height) / _height).abs();
      } else if (endY < -itemBubbleHeight) {
        event.labelY = y;
      }

      double lx = x + LineSpacing + LineSpacing;
      if (lx > _labelX) {
        _labelX = lx;
      }

      if (event.children != null && event.isVisible) {
        /// Advance the rest of the hierarchy.
        if (_advanceEvents(event.children!, x + LineSpacing + LineWidth, scale,
            elapsed, animate, depth + 1)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }

  Color _interpolateColor(Color from, Color to, double elapsed) {
    double r, g, b, a;
    double speed = min(1.0, elapsed * 5.0);
    double c = to.alpha.toDouble() - from.alpha.toDouble();
    if (c.abs() < 1.0) {
      a = to.alpha.toDouble();
    } else {
      a = from.alpha + c * speed;
    }

    c = to.red.toDouble() - from.red.toDouble();
    if (c.abs() < 1.0) {
      r = to.red.toDouble();
    } else {
      r = from.red + c * speed;
    }

    c = to.green.toDouble() - from.green.toDouble();
    if (c.abs() < 1.0) {
      g = to.green.toDouble();
    } else {
      g = from.green + c * speed;
    }

    c = to.blue.toDouble() - from.blue.toDouble();
    if (c.abs() < 1.0) {
      b = to.blue.toDouble();
    } else {
      b = from.blue + c * speed;
    }

    return Color.fromARGB(a.round(), r.round(), g.round(), b.round());
  }

  /// Advance asset [events] with the [elapsed] time. Calls itself recursively
  /// to process all of a parent's root and its children.
  bool _advanceAssets(List<Event> events, double elapsed, bool animate,
      List<EventAsset> renderedAssets) {
    bool stillAnimating = false;
    for (Event event in events) {
      double y = event.labelY;
      double halfHeight = _height / 2.0;
      double thresholdAssetY = y + ((y - halfHeight) / halfHeight) * Parallax;
      double targetAssetY =
          thresholdAssetY - event.asset.height * AssetScreenScale / 2.0;

      /// Determine if the current event is visible or not.
      double targetAssetOpacity =
          (thresholdAssetY - _lastAssetY < 0 ? 0.0 : 1.0) *
              event.opacity *
              event.labelOpacity;

      /// Debounce asset becoming visible.
      if (targetAssetOpacity > 0.0 && event.targetAssetOpacity != 1.0) {
        event.delayAsset = 0.25;
      }
      event.targetAssetOpacity = targetAssetOpacity;
      if (event.delayAsset > 0.0) {
        /// If this item has been debounced, update it's debounce time.
        targetAssetOpacity = 0.0;
        event.delayAsset -= elapsed;
        stillAnimating = true;
      }

      /// Determine if the event needs to be scaled.
      double targetScale = targetAssetOpacity;
      double targetScaleVelocity = targetScale - event.asset.scale;
      if (!animate || targetScale == 0) {
        event.asset.scaleVelocity = targetScaleVelocity;
      } else {
        double dvy = targetScaleVelocity - event.asset.scaleVelocity;
        event.asset.scaleVelocity += dvy * elapsed * 18.0;
      }

      event.asset.scale += event.asset.scaleVelocity * elapsed * 20.0;
      if (animate &&
          (event.asset.scaleVelocity.abs() > 0.01 ||
              targetScaleVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      EventAsset asset = event.asset;
      if (asset.opacity == 0.0) {
        /// Item was invisible, just pop it to the right place and stop velocity.
        asset.y = targetAssetY;
        asset.velocity = 0.0;
      }

      /// Determinte the opacity delta and interpolate towards that value if needed.
      double da = targetAssetOpacity - asset.opacity;
      if (!animate || da.abs() < 0.01) {
        asset.opacity = targetAssetOpacity;
      } else {
        stillAnimating = true;
        asset.opacity += da * min(1.0, elapsed * 15.0);
      }

      /// This asset is visible.
      if (asset.opacity > 0.0) {
        /// Calculate the vertical delta, and assign the interpolated value.
        double targetAssetVelocity = max(_lastAssetY, targetAssetY) - asset.y;
        double dvay = targetAssetVelocity - asset.velocity;
        if (dvay.abs() > _height) {
          asset.y = targetAssetY;
          asset.velocity = 0.0;
        } else {
          asset.velocity += dvay * elapsed * 15.0;
          asset.y += asset.velocity * elapsed * 17.0;
        }

        /// Check if we reached our target and flag it if not.
        if (asset.velocity.abs() > 0.01 || targetAssetVelocity.abs() > 0.01) {
          stillAnimating = true;
        }

        _lastAssetY =
            targetAssetY + asset.height * AssetScreenScale + AssetPadding;
        if (asset is NimaAsset) {
          _lastAssetY += asset.gap;
        } else if (asset is FlareAsset) {
          _lastAssetY += asset.gap;
        }
        if (asset.y > _height ||
            asset.y + asset.height * AssetScreenScale < 0.0) {
          /// It's not in view: cull it. Make sure we don't advance animations.
          if (asset is NimaAsset) {
            NimaAsset nimaAsset = asset;
            if (!nimaAsset.loop) {
              nimaAsset.animationTime = -1.0;
            }
          } else if (asset is FlareAsset) {
            FlareAsset flareAsset = asset;
            if (!flareAsset.loop) {
              flareAsset.animationTime = -1.0;
            } else if (flareAsset.intro != null) {
              flareAsset.animationTime = -1.0;
              flareAsset.animation = flareAsset.intro!;
            }
          }
        } else {
          bool isActive = TarikhC.to.isActiveTimeline;

          /// Item is in view, apply the new animation time and advance the actor.
          if (asset is NimaAsset && isActive) {
            asset.animationTime += elapsed;
            if (asset.loop) {
              asset.animationTime %= asset.animation.duration;
            }
            asset.animation.apply(asset.animationTime, asset.actor, 1.0);
            asset.actor.advance(elapsed);
            stillAnimating = true;
          } else if (asset is FlareAsset && isActive) {
            asset.animationTime += elapsed;

            /// Flare animations can have idle animations, as well as intro animations.
            /// Distinguish which one has the top priority and apply it accordingly.
            if (asset.idleAnimations != null) {
              double phase = 0.0;
              for (flare.ActorAnimation animation in asset.idleAnimations!) {
                animation.apply(
                    (asset.animationTime + phase) % animation.duration,
                    asset.actor,
                    1.0);
                phase += 0.16;
              }
            } else {
              if (asset.intro == asset.animation &&
                  asset.animationTime >= asset.animation.duration) {
                asset.animationTime -= asset.animation.duration;
                asset.animation = asset.idle!;
              }
              if (asset.loop && asset.animationTime > 0) {
                asset.animationTime %= asset.animation.duration;
              }
              asset.animation.apply(asset.animationTime, asset.actor, 1.0);
            }
            asset.actor.advance(elapsed);
            stillAnimating = true;
          }

          /// Add this asset to the list of rendered assets.
          renderedAssets.add(event.asset);
        }
      } else {
        /// [item] is not visible.
        event.asset.y = max(_lastAssetY, targetAssetY);
      }

      if (event.children != null && event.isVisible) {
        /// Proceed down the hierarchy. Recursive call back into this method.
        if (_advanceAssets(event.children!, elapsed, animate, renderedAssets)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }
}
