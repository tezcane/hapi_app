import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';

typedef PaintCallback = Function();
typedef ChangeEraCallback = Function(TimelineEntry? era);
typedef ChangeHeaderColorCallback = Function(Color background, Color text);

class Timeline {
  Timeline(
    this._rootEntries,
    this._tickColors,
    this._headerColors,
    this._timeMin,
    this._timeMax,
  ) {
    _headerColorsReversed = _headerColors.reversed;
    setViewport(start: 1536.0, end: 3072.0); // TODO what is this?
  }

  /// All the [TimelineEntry]s that are loaded from disk at boot (in [loadFromBundle()]).
  /// List for "root" entries, i.e. entries with no parents.
  final List<TimelineEntry> _rootEntries;

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  final List<TickColors> _tickColors;
  final List<HeaderColors> _headerColors;
  late final Iterable<HeaderColors> _headerColorsReversed;

  final double _timeMin;
  final double _timeMax;

  /// The list of [TimelineAsset], loaded from disk at boot and stored in entry.
  List<TimelineAsset> _renderedAssets = [];

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
  double _firstOnScreenEntryY = 0.0;
  double _lastEntryY = 0.0;
  double _lastOnScreenEntryY = 0.0;
  double _offsetDepth = 0.0;
  double _renderOffsetDepth = 0.0;
  double _labelX = 0.0;
  double _renderLabelX = 0.0;
  double _lastAssetY = 0.0;
  double _prevEntryOpacity = 0.0;
  double _distanceToPrevEntry = 0.0;
  double _nextEntryOpacity = 0.0;
  double _distanceToNextEntry = 0.0;
  double _simulationTime = 0.0;
  double _gutterWidth = GutterLeft;

  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isSteady = false;

  HeaderColors? _currentHeaderColors;

  Color? _headerTextColor;
  Color? _headerBackgroundColor;

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
  TimelineEntry? _currentEra;
  TimelineEntry? _lastEra;

  /// These references allow to maintain a reference to the next and previous elements
  /// of the Timeline, depending on which elements are currently in focus.
  /// When there's enough space on the top/bottom, the Timeline will render a round button
  /// with an arrow to link to the next/previous element.
  TimelineEntry? _nextEntry;
  TimelineEntry? _renderNextEntry;
  TimelineEntry? _prevEntry;
  TimelineEntry? _renderPrevEntry;

  /// Callback set by [TimelineRenderWidget] when adding a reference to this object.
  /// It'll trigger [RenderBox.markNeedsPaint()].
  PaintCallback? onNeedPaint;

  /// These next two callbacks are bound to set the state of the [TimelineWidget]
  /// so it can change the appearance of the top AppBar.
  ChangeEraCallback? onEraChanged;
  ChangeHeaderColorCallback? onHeaderColorsChanged;

  TimelineEntry? get currentEra => _currentEra;

  List<TimelineAsset> get renderedAssets => _renderedAssets;

  double get renderOffsetDepth => _renderOffsetDepth;
  double get renderLabelX => _renderLabelX;
  double get start => _start;
  double get end => _end;
  double get renderStart => _renderStart;
  double get renderEnd => _renderEnd;
  double get gutterWidth => _gutterWidth;

  TimelineEntry? get nextEntry => _renderNextEntry;
  TimelineEntry? get prevEntry => _renderPrevEntry;
  double get nextEntryOpacity => _nextEntryOpacity;
  double get prevEntryOpacity => _prevEntryOpacity;

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
      SchedulerBinding.instance!.scheduleFrameCallback(beginFrame);
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
      SchedulerBinding.instance!.scheduleFrameCallback(beginFrame);
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
      SchedulerBinding.instance!.scheduleFrameCallback(beginFrame);
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
      SchedulerBinding.instance!.scheduleFrameCallback(beginFrame);
      return;
    }

    double elapsed = time - _lastFrameTime;
    _lastFrameTime = time;

    if (!advance(elapsed, true) && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance!.scheduleFrameCallback(beginFrame);
    }

    // Tez: fixes exception when hitting back button from timeline back to root page
    // TODO isActive was not here before, needed to fix exception after upgrading
    // flutter version:
    if (TarikhController.to.isActive && onNeedPaint != null) {
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
        TarikhController.to.isGutterModeOff() ? GutterLeft : GutterLeftExpanded;
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
      _headerBackgroundColor = _currentHeaderColors!.background;
    } else {
      bool stillColoring = false;
      Color headerTextColor = interpolateColor(
          _headerTextColor!, _currentHeaderColors!.text, elapsed);

      if (headerTextColor != _headerTextColor) {
        _headerTextColor = headerTextColor;
        stillColoring = true;
        doneRendering = false;
      }
      Color headerBackgroundColor = interpolateColor(
          _headerBackgroundColor!, _currentHeaderColors!.background, elapsed);
      if (headerBackgroundColor != _headerBackgroundColor) {
        _headerBackgroundColor = headerBackgroundColor;
        stillColoring = true;
        doneRendering = false;
      }
      if (stillColoring) {
        if (onHeaderColorsChanged != null) {
          onHeaderColorsChanged!(_headerBackgroundColor!, _headerTextColor!);
        }
      }
    }

    /// Check all the visible entries and use the helper function [advanceItems()]
    /// to align their state with the elapsed time.
    /// Set all the initial values to defaults so that everything's consistent.
    _lastEntryY = -double.maxFinite;
    _lastOnScreenEntryY = 0.0;
    _firstOnScreenEntryY = double.maxFinite;
    _lastAssetY = -double.maxFinite;
    _labelX = 0.0;
    _offsetDepth = 0.0;
    _currentEra = null;
    _nextEntry = null;
    _prevEntry = null;

    /// Advance the items hierarchy one level at a time.
    if (_advanceItems(
        _rootEntries, _gutterWidth + LineSpacing, scale, elapsed, animate, 0)) {
      doneRendering = false;
    }

    /// Advance all the assets and add the rendered ones into [_renderAssets].
    _renderedAssets = []; // resets here, where all UI cleanup is done?
    if (_advanceAssets(_rootEntries, elapsed, animate, _renderedAssets)) {
      doneRendering = false;
    }

    if (_nextEntryOpacity == 0.0) {
      _renderNextEntry = _nextEntry;
    }

    /// Determine next entry's opacity and interpolate, if needed, towards that value.
    double targetNextEntryOpacity = _lastOnScreenEntryY > _height / 1.7 ||
            !_isSteady ||
            _distanceToNextEntry < 0.01 ||
            _nextEntry != _renderNextEntry
        ? 0.0
        : 1.0;
    double dt = targetNextEntryOpacity - _nextEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _nextEntryOpacity = targetNextEntryOpacity;
    } else {
      doneRendering = false;
      _nextEntryOpacity += dt * min(1.0, elapsed * 10.0);
    }

    if (_prevEntryOpacity == 0.0) {
      _renderPrevEntry = _prevEntry;
    }

    /// Determine previous entry's opacity and interpolate, if needed, towards that value.
    double targetPrevEntryOpacity = _firstOnScreenEntryY < _height / 2.0 ||
            !_isSteady ||
            _distanceToPrevEntry < 0.01 ||
            _prevEntry != _renderPrevEntry
        ? 0.0
        : 1.0;
    dt = targetPrevEntryOpacity - _prevEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _prevEntryOpacity = targetPrevEntryOpacity;
    } else {
      doneRendering = false;
      _prevEntryOpacity += dt * min(1.0, elapsed * 10.0);
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

  double bubbleHeight(TimelineEntry entry) {
    return (BubblePadding * 1.15) + (entry.lineCount * BubbleTextHeight);
  }

  /// Advance entry [assets] with the current [elapsed] time.
  bool _advanceItems(List<TimelineEntry> items, double x, double scale,
      double elapsed, bool animate, int depth) {
    bool stillAnimating = false;
    double lastEnd = -double.maxFinite;
    for (int i = 0; i < items.length; i++) {
      TimelineEntry item = items[i];

      double start = item.startMs - _renderStart;
      double end = item.type == TimelineEntryType.Era
          ? item.endMs - _renderStart
          : start;

      /// Vertical position for this element.
      double y = start * scale; // +pad;
      if (i > 0 && y - lastEnd < EdgePadding) {
        y = lastEnd + EdgePadding;
      }

      /// Adjust based on current scale value.
      double endY = end * scale; //-pad;
      /// Update the reference to the last found element.
      lastEnd = endY;

      item.length = endY - y;

      /// Calculate the best location for the bubble/label.
      double targetLabelY = y;
      double itemBubbleHeight = bubbleHeight(item);
      double fadeAnimationStart = itemBubbleHeight + BubblePadding / 2.0;
      if (targetLabelY - _lastEntryY < fadeAnimationStart

          /// The best location for our label is occluded, lets see if we can bump it forward...
          &&
          item.type == TimelineEntryType.Era &&
          _lastEntryY + fadeAnimationStart < endY) {
        targetLabelY = _lastEntryY + fadeAnimationStart + 0.5;
      }

      /// Determine if the label is in view.
      double targetLabelOpacity =
          targetLabelY - _lastEntryY < fadeAnimationStart ? 0.0 : 1.0;

      /// Debounce labels becoming visible.
      if (targetLabelOpacity > 0.0 && item.targetLabelOpacity != 1.0) {
        item.delayLabel = 0.5;
      }
      item.targetLabelOpacity = targetLabelOpacity;
      if (item.delayLabel > 0.0) {
        targetLabelOpacity = 0.0;
        item.delayLabel -= elapsed;
        stillAnimating = true;
      }

      double dt = targetLabelOpacity - item.labelOpacity;
      if (!animate || dt.abs() < 0.01) {
        item.labelOpacity = targetLabelOpacity;
      } else {
        stillAnimating = true;
        item.labelOpacity += dt * min(1.0, elapsed * 25.0);
      }

      /// Assign current vertical position.
      item.y = y;
      item.endY = endY;

      double targetLegOpacity = item.length > EdgeRadius ? 1.0 : 0.0;
      double dtl = targetLegOpacity - item.legOpacity;
      if (!animate || dtl.abs() < 0.01) {
        item.legOpacity = targetLegOpacity;
      } else {
        stillAnimating = true;
        item.legOpacity += dtl * min(1.0, elapsed * 20.0);
      }

      double targetItemOpacity = item.parent != null
          ? item.parent!.length < MinChildLength ||
                  (item.parent != null && item.parent!.endY < y)
              ? 0.0
              : y > item.parent!.y
                  ? 1.0
                  : 0.0
          : 1.0;
      dtl = targetItemOpacity - item.opacity;
      if (!animate || dtl.abs() < 0.01) {
        item.opacity = targetItemOpacity;
      } else {
        stillAnimating = true;
        item.opacity += dtl * min(1.0, elapsed * 20.0);
      }

      /// Animate the label position.
      double targetLabelVelocity = targetLabelY - item.labelY;
      double dvy = targetLabelVelocity - item.labelVelocity;
      if (dvy.abs() > _height) {
        item.labelY = targetLabelY;
        item.labelVelocity = 0.0;
      } else {
        item.labelVelocity += dvy * elapsed * 18.0;
        item.labelY += item.labelVelocity * elapsed * 20.0;
      }

      /// Check the final position has been reached, otherwise raise a flag.
      if (animate &&
          (item.labelVelocity.abs() > 0.01 ||
              targetLabelVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      if (item.targetLabelOpacity > 0.0) {
        _lastEntryY = targetLabelY;
        if (_lastEntryY < _height && _lastEntryY > devicePadding.top) {
          _lastOnScreenEntryY = _lastEntryY;
          if (_firstOnScreenEntryY == double.maxFinite) {
            _firstOnScreenEntryY = _lastEntryY;
          }
        }
      }

      if (item.type == TimelineEntryType.Era &&
          y < 0 &&
          endY > _height &&
          depth > _offsetDepth) {
        _offsetDepth = depth.toDouble();
      }

      /// A new era is currently in view.
      if (item.type == TimelineEntryType.Era && y < 0 && endY > _height / 2.0) {
        _currentEra = item;
      }

      /// Check if the bubble is out of view and set the y position to the
      /// target one directly.
      if (y > _height + itemBubbleHeight) {
        item.labelY = y;
        if (_nextEntry == null) {
          // TODO asdf intercept up/dn btn here?
          _nextEntry = item;
          _distanceToNextEntry = (y - _height) / _height;
        }
      } else if (endY < devicePadding.top) {
        _prevEntry = item;
        _distanceToPrevEntry = ((y - _height) / _height).abs();
      } else if (endY < -itemBubbleHeight) {
        item.labelY = y;
      }

      double lx = x + LineSpacing + LineSpacing;
      if (lx > _labelX) {
        _labelX = lx;
      }

      if (item.children != null && item.isVisible) {
        /// Advance the rest of the hierarchy.
        if (_advanceItems(item.children!, x + LineSpacing + LineWidth, scale,
            elapsed, animate, depth + 1)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }

  /// Advance asset [items] with the [elapsed] time. Calls itself recursively
  /// to process all of a parent's root and its children.
  bool _advanceAssets(List<TimelineEntry> items, double elapsed, bool animate,
      List<TimelineAsset> renderedAssets) {
    bool stillAnimating = false;
    for (TimelineEntry item in items) {
      double y = item.labelY;
      double halfHeight = _height / 2.0;
      double thresholdAssetY = y + ((y - halfHeight) / halfHeight) * Parallax;
      double targetAssetY =
          thresholdAssetY - item.asset.height * AssetScreenScale / 2.0;

      /// Determine if the current entry is visible or not.
      double targetAssetOpacity =
          (thresholdAssetY - _lastAssetY < 0 ? 0.0 : 1.0) *
              item.opacity *
              item.labelOpacity;

      /// Debounce asset becoming visible.
      if (targetAssetOpacity > 0.0 && item.targetAssetOpacity != 1.0) {
        item.delayAsset = 0.25;
      }
      item.targetAssetOpacity = targetAssetOpacity;
      if (item.delayAsset > 0.0) {
        /// If this item has been debounced, update it's debounce time.
        targetAssetOpacity = 0.0;
        item.delayAsset -= elapsed;
        stillAnimating = true;
      }

      /// Determine if the entry needs to be scaled.
      double targetScale = targetAssetOpacity;
      double targetScaleVelocity = targetScale - item.asset.scale;
      if (!animate || targetScale == 0) {
        item.asset.scaleVelocity = targetScaleVelocity;
      } else {
        double dvy = targetScaleVelocity - item.asset.scaleVelocity;
        item.asset.scaleVelocity += dvy * elapsed * 18.0;
      }

      item.asset.scale += item.asset.scaleVelocity * elapsed * 20.0;
      if (animate &&
          (item.asset.scaleVelocity.abs() > 0.01 ||
              targetScaleVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      TimelineAsset asset = item.asset;
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
        if (asset is TimelineNima) {
          _lastAssetY += asset.gap;
        } else if (asset is TimelineFlare) {
          _lastAssetY += asset.gap;
        }
        if (asset.y > _height ||
            asset.y + asset.height * AssetScreenScale < 0.0) {
          /// It's not in view: cull it. Make sure we don't advance animations.
          if (asset is TimelineNima) {
            TimelineNima nimaAsset = asset;
            if (!nimaAsset.loop) {
              nimaAsset.animationTime = -1.0;
            }
          } else if (asset is TimelineFlare) {
            TimelineFlare flareAsset = asset;
            if (!flareAsset.loop) {
              flareAsset.animationTime = -1.0;
            } else if (flareAsset.intro != null) {
              flareAsset.animationTime = -1.0;
              flareAsset.animation = flareAsset.intro!;
            }
          }
        } else {
          bool isActive = TarikhController.to.isActive;

          /// Item is in view, apply the new animation time and advance the actor.
          if (asset is TimelineNima && isActive) {
            asset.animationTime += elapsed;
            if (asset.loop) {
              asset.animationTime %= asset.animation.duration;
            }
            asset.animation.apply(asset.animationTime, asset.actor, 1.0);
            asset.actor.advance(elapsed);
            stillAnimating = true;
          } else if (asset is TimelineFlare && isActive) {
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
          renderedAssets.add(item.asset);
        }
      } else {
        /// [item] is not visible.
        item.asset.y = max(_lastAssetY, targetAssetY);
      }

      if (item.children != null && item.isVisible) {
        /// Proceed down the hierarchy. Recursive call back into this method.
        if (_advanceAssets(item.children!, elapsed, animate, renderedAssets)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }
}
