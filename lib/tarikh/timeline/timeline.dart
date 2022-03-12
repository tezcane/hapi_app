import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

typedef PaintCallback = Function();
typedef ChangeEraCallback = Function(TimelineEntry? era);
typedef ChangeHeaderColorCallback = Function(Color background, Color text);

class Timeline {
  Timeline() {
    setViewport(start: 1536.0, end: 3072.0); // TODO what is this?
  }

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
//static const double BubbleArrowSize = 19.0;
  static const double BubblePadding = 20.0;
  static const double BubbleTextHeight = 20.0;
  static const double AssetPadding = 30.0;
  static const double Parallax = 100.0;
  static const double AssetScreenScale = 0.3;
//static const double InitialViewportPadding = 100.0; // TODO cleanup
//static const double TravelViewportPaddingTop = 400.0;

  static const double ViewportPaddingTop = 120.0;
  static const double ViewportPaddingBottom = 100.0;
  static const int SteadyMilliseconds = 500;

  double _start = 0.0;
  double _end = 0.0;
  double _renderStart = double.maxFinite; // TODO ?
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
  double _timeMin = 0.0;
  double _timeMax = 0.0;
  double _gutterWidth = GutterLeft;

  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isActive = false;
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

  /// A gradient is shown on the background, depending on the [_currentEra] we're in.
  final List<TimelineBackgroundColor> _backgroundColors = [];

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  final List<TickColors> _tickColors = [];
  final List<HeaderColors> _headerColors = [];

  /// All the [TimelineEntry]s that are loaded from disk at boot (in [loadFromBundle()]).
  /// List for "root" entries, i.e. entries with no parents.
  final List<TimelineEntry> _rootEntries = [];

  /// The list of [TimelineAsset], also loaded from disk at boot.
  List<TimelineAsset> _renderedAssets = [];

  /// This is a special feature to play a particular part of an animation
  final Map<String, TimelineEntry> _entriesById = {};
  final Map<String, nima.FlutterActor> _nimaResources = {};
  final Map<String, flare.FlutterActor> _flareResources = {};

  /// Callback set by [TimelineRenderWidget] when adding a reference to this object.
  /// It'll trigger [RenderBox.markNeedsPaint()].
  PaintCallback? onNeedPaint;

  /// These next two callbacks are bound to set the state of the [TimelineWidget]
  /// so it can change the appearance of the top AppBar.
  ChangeEraCallback? onEraChanged;
  ChangeHeaderColorCallback? onHeaderColorsChanged;

  TimelineEntry? get currentEra => _currentEra;

  List<TimelineEntry> get rootEntries => _rootEntries;
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
  bool get isActive => _isActive;

  Color? get headerTextColor => _headerTextColor;
  // Color? get headerBackgroundColor => _headerBackgroundColor;
  // HeaderColors? get currentHeaderColors => _currentHeaderColors;

  List<TimelineBackgroundColor> get backgroundColors => _backgroundColors;
  List<TickColors> get tickColors => _tickColors;

  TimelineEntry findEvent(String label) {
    while (true) {
      Map<String, TimelineEntry> eventMap = TarikhController.to.eventMap;
      if (eventMap.containsKey(label)) {
        return eventMap[label]!;
      } else {
        // TODO this is broken if menu section clicked on before init is done
        print(
            'findEvent: eventMap not initialized, eventMap size=${eventMap.length}');
        sleep(const Duration(seconds: 1));
        continue;
      }
    }
  }

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

  /// Toggle/stop rendering whenever the timeline is visible or hidden.
  set isActive(bool isIt) {
    if (isIt != _isActive) {
      _isActive = isIt;
      if (_isActive) {
        _startRendering();
      }
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
        _startRendering();
      });
    } else {
      /// Otherwise update the current state and schedule a new frame.
      _isSteady = false;
      _startRendering();
    }
  }

  /// Schedule a new frame.
  void _startRendering() {
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

  Future<TimelineAsset> loadFlareAsset(
    Map assetMap,
    String filename,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    double scale,
  ) async {
    flare.FlutterActor? flutterActor = _flareResources[filename];
    if (flutterActor == null) {
      flutterActor = flare.FlutterActor();

      /// Flare library function to load the [FlutterActor]
      await flutterActor.loadFromBundle(rootBundle, filename);

      /// Populate the Map.
      _flareResources[filename] = flutterActor;
    }

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
    dynamic name = assetMap["idle"];
    if (name is String) {
      if ((idle = actor.getAnimation(name)) != null) {
        animation = idle;
      }
    } else if (name is List) {
      for (String animationName in name) {
        flare.ActorAnimation? animation1 = actor.getAnimation(animationName);
        if (animation1 != null) {
          idleAnimations ??= [];
          idleAnimations.add(animation1);
          animation = animation1;
        }
      }
    }

    flare.ActorAnimation? intro;
    name = assetMap["intro"];
    if (name is String) {
      if ((intro = actor.getAnimation(name)) != null) {
        animation = intro;
      }
    }

    /// Make sure that all the initial values are set for the actor and for the
    /// actor instance.
    actor.advance(0.0);
    flare.AABB setupAABB = actor.computeAABB();
    animation.apply(0.0, actor, 1.0);
    animation.apply(animation.duration, actorStatic, 1.0);
    actor.advance(0.0);
    actorStatic.advance(0.0);

    dynamic bounds = assetMap["bounds"];
    if (bounds is List) {
      /// Override the AABB for this entry with custom values.
      setupAABB = flare.AABB.fromValues(
          bounds[0] is int ? bounds[0].toDouble() : bounds[0],
          bounds[1] is int ? bounds[1].toDouble() : bounds[1],
          bounds[2] is int ? bounds[2].toDouble() : bounds[2],
          bounds[3] is int ? bounds[3].toDouble() : bounds[3]);
    }

    TimelineFlare flareAsset = TimelineFlare(
      actorStatic,
      actor,
      setupAABB,
      animation,
      loop,
      offset,
      gap,
      width,
      height,
      filename,
      scale,
    );

    // set optional fields, if they exist:
    flareAsset.intro = intro;
    flareAsset.idle = idle;
    flareAsset.idleAnimations = idleAnimations;

    return flareAsset;
  }

  Future<TimelineAsset> loadNimaAsset(
    Map assetMap,
    String filename,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    double scale,
  ) async {
    nima.FlutterActor? flutterActor = _nimaResources[filename];
    if (flutterActor == null) {
      flutterActor = nima.FlutterActor();
      await flutterActor.loadFromBundle(filename);
      _nimaResources[filename] = flutterActor;
    }

    nima.FlutterActor actorStatic = flutterActor;
    nima.FlutterActor actor = flutterActor.makeInstance() as nima.FlutterActor;

    nima.ActorAnimation animation;
    dynamic name = assetMap["idle"];
    if (name is String) {
      animation = actor.getAnimation(name);
    } else {
      animation = flutterActor.animations[0];
    }

    actor.advance(0.0);
    nima.AABB setupAABB = actor.computeAABB();
    animation.apply(0.0, actor, 1.0);
    animation.apply(animation.duration, actorStatic, 1.0);
    actor.advance(0.0);
    actorStatic.advance(0.0);

    dynamic bounds = assetMap["bounds"];
    if (bounds is List) {
      setupAABB = nima.AABB.fromValues(
          bounds[0] is int ? bounds[0].toDouble() : bounds[0],
          bounds[1] is int ? bounds[1].toDouble() : bounds[1],
          bounds[2] is int ? bounds[2].toDouble() : bounds[2],
          bounds[3] is int ? bounds[3].toDouble() : bounds[3]);
    }

    TimelineNima nimaAsset = TimelineNima(
      actorStatic,
      actor,
      setupAABB,
      animation,
      loop,
      offset,
      gap,
      width,
      height,
      filename,
      scale,
    );

    return nimaAsset;
  }

  /// The `asset` key in the current entry contains all the information for
  /// the nima/flare animation file that'll be played on the timeline.
  ///
  /// `asset` is a JSON map with:
  ///   - source: the name of the nima/flare/image file in the assets folder.
  ///   - width/height/offset/bounds/gap:
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
  Future<TimelineAsset> getTimelineAsset(Map assetMap) async {
    String source = assetMap["source"];
    String filename = "assets/tarikh/" + source;

    TimelineAsset asset;

    dynamic loopVal = assetMap["loop"];
    bool loop = loopVal is bool ? loopVal : true;

    dynamic offsetVal = assetMap["offset"];
    double offset = offsetVal == null
        ? 0.0
        : offsetVal is int
            ? offsetVal.toDouble()
            : offsetVal;

    dynamic gapVal = assetMap["gap"];
    double gap = gapVal == null
        ? 0.0
        : gapVal is int
            ? gapVal.toDouble()
            : gapVal;

    dynamic widthVal = assetMap["width"];
    double width = widthVal is int ? widthVal.toDouble() : widthVal;

    dynamic heightVal = assetMap["height"];
    double height = heightVal is int ? heightVal.toDouble() : heightVal;

    double scale = 1.0;
    if (assetMap.containsKey("scale")) {
      dynamic scaleVal = assetMap["scale"];
      scale = scaleVal is int ? scaleVal.toDouble() : scaleVal;
    }

    /// Instantiate the correct object based on the file extension.
    switch (getFileExtension(source)) {
      case "flr":
        asset = await loadFlareAsset(
            assetMap, filename, loop, offset, gap, width, height, scale);
        break;
      case "nma":
        asset = await loadNimaAsset(
            assetMap, filename, loop, offset, gap, width, height, scale);
        break;
      default: // TODO TEST THIS, MVP can ship with just pictures
        /// Legacy fallback case: some elements could have been just images.
        ByteData data = await rootBundle.load(filename);
        Uint8List list = Uint8List.view(data.buffer);
        ui.Codec codec = await ui.instantiateImageCodec(list);
        ui.FrameInfo frame = await codec.getNextFrame();

        asset = TimelineImage(frame.image, width, height, filename, scale);

        break;
    }

    return Future.value(asset);
  }

  /// Load all the resources from the local bundle.
  ///
  /// This function will load and decode `timline.json` from disk,
  /// decode the JSON file, and populate all the [TimelineEntry]s.
  loadFromBundle() async {
    final String jsonData =
        await rootBundle.loadString('assets/tarikh/timeline.json');
    final List jsonEntries = json.decode(jsonData);

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic entries in the [jsonEntries] list.
    for (Map map in jsonEntries) {
      /// The label is a brief description for the current entry.
      String label = map["label"];

      /// Create the current entry and fill in the current date if it's
      /// an `Incident`, or look for the `start` property if it's an `Era` instead.
      /// Some entries will have a `start` element, but not an `end` specified.
      /// These entries specify a particular event such as the appearance of
      /// "Humans" in history, which hasn't come to an end -- yet.
      TimelineEntryType type;
      double startMs;
      if (map.containsKey("date")) {
        type = TimelineEntryType.Incident;
        dynamic date = map["date"];
        startMs = date is int ? date.toDouble() : date;
      } else {
        type = TimelineEntryType.Era;
        dynamic startVal = map["start"];
        startMs = startVal is int ? startVal.toDouble() : startVal;
      }

      /// Some elements will have an `end` time specified.
      /// If not `end` key is present in this entry, create the value based
      /// on the type of the event:
      /// - Eras use the current year as an end time.
      /// - Other entries are just single points in time (start == end).
      double endMs;
      if (map.containsKey("end")) {
        dynamic endVal = map["end"];
        endMs = endVal is int ? endVal.toDouble() : endVal;
      } else if (type == TimelineEntryType.Era) {
        // TODO where timeline eras stretch to future?
        endMs = (await TimeController.to.now()).year.toDouble() * 10.0;
      } else {
        endMs = startMs;
      }

      String articleFilename = map["article"];

      /// Get Timeline Color Setup:
      if (map.containsKey('timelineColors')) {
        var timelineColors = map['timelineColors'];

        /// If a custom background color for this [TimelineEntry] is specified,
        /// extract its RGB values and save them for reference, along with the
        /// starting date of the current entry.
        var timelineBackgroundColor = TimelineBackgroundColor(
          colorFromList(timelineColors["background"]),
          startMs,
        );
        _backgroundColors.add(timelineBackgroundColor);

        /// [Ticks] can also have custom colors, so that everything's is visible
        /// even with custom colored backgrounds.
        var tickColors = TickColors(
          colorFromList(timelineColors["ticks"], key: "background"),
          colorFromList(timelineColors["ticks"], key: "long"),
          colorFromList(timelineColors["ticks"], key: "short"),
          colorFromList(timelineColors["ticks"], key: "text"),
          startMs,
        );
        _tickColors.add(tickColors);

        /// If a `header` element is present, de-serialize the colors for it too.
        var headerColors = HeaderColors(
          colorFromList(timelineColors["header"], key: "background"),
          colorFromList(timelineColors["header"], key: "text"),
          startMs,
        );
        _headerColors.add(headerColors);
      }

      /// OPTIONAL FIELD 1 of 2: An accent color is also specified at times.
      Color? accent;
      if (map.containsKey("accent")) {
        accent = colorFromList(map["accent"]);
      }

      /// OPTIONAL FIELD 2 of 2: Some entries will also have an id
      String? id;
      if (map.containsKey("id")) {
        id = map["id"];
      }

      /// Get flare/nima/image asset object
      TimelineAsset asset = await getTimelineAsset(map["asset"]);

      /// Finally create TimeLineEntry object
      var timelineEntry = TimelineEntry(
        label,
        type,
        startMs,
        endMs,
        articleFilename,
        asset,
        accent,
        id,
      );

      /// Add TimelineEntry reference 1 of 2:
      asset.entry = timelineEntry; // can only do this once

      /// Add TimelineEntry reference 2 of 2:
      if (map.containsKey("id")) {
        _entriesById[id!] = timelineEntry;
      }

      /// Add this entry to the list.
      TarikhController.to.eventMap
          .putIfAbsent(timelineEntry.label, () => timelineEntry);
      TarikhController.to.events.add(timelineEntry); // sort is probably needed
    }

    /// sort the full list so they are in order of oldest to newest
    TarikhController.to.events.sort((TimelineEntry a, TimelineEntry b) {
      return a.startMs.compareTo(b.startMs);
    });

    _backgroundColors
        .sort((TimelineBackgroundColor a, TimelineBackgroundColor b) {
      return a.startMs.compareTo(b.startMs);
    });

    _timeMin = double.maxFinite;
    _timeMax = -double.maxFinite;

    /// IMPORTANT NOTE: Do we want to enhance this to allow json file input to
    ///                 define where stuff belongs:
    /// Build up hierarchy (Eras are grouped into "Spanning Eras" and Events are
    /// placed into the Eras they belong to).
    TimelineEntry? previous;
    for (TimelineEntry entry in TarikhController.to.events) {
      if (entry.startMs < _timeMin) {
        _timeMin = entry.startMs;
      }
      if (entry.endMs > _timeMax) {
        _timeMax = entry.endMs;
      }
      if (previous != null) {
        previous.next = entry;
      }
      entry.previous = previous;
      previous = entry;

      TimelineEntry? parent;
      double minDistance = double.maxFinite;
      for (TimelineEntry checkEntry in TarikhController.to.events) {
        if (checkEntry.type == TimelineEntryType.Era) {
          double distance = entry.startMs - checkEntry.startMs;
          double distanceEnd = entry.startMs - checkEntry.endMs;
          if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
            minDistance = distance;
            parent = checkEntry;
          }
        }
      }
      // no parent, so this is a root entry.
      if (parent == null) {
        _rootEntries.add(entry); // note holds eras, not individual entries
      } else {
        // otherwise add as child to parent node
        entry.parent = parent;
        parent.children ??= []; // parent node holds children
        parent.children!.add(entry);
      }
    }
  }

  /// Helper function for [MenuVignette].
  TimelineEntry? getById(String id) {
    return _entriesById[id];
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

  Color colorFromList(colorList, {String key = ""}) {
    if (key != "") {
      colorList = colorList[key];
    }
    List<int> bg = colorList.cast<int>();

    int bg3 = 0xFF; // 255 (no opacity)
    if (bg.length == 4) {
      bg3 = bg[3];
    }

    return Color.fromARGB(bg3, bg[0], bg[1], bg[2]);
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
      if (_height == 0.0 && _rootEntries.isNotEmpty) {
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
    if (isActive && onNeedPaint != null) {
      onNeedPaint!();
    }
  }

  TickColors? findTickColors(double screen) {
    for (TickColors color in _tickColors.reversed) {
      if (screen >= color.screenY) {
        return color;
      }
    }

    return screen < _tickColors.first.screenY
        ? _tickColors.first
        : _tickColors.last;
  }

  HeaderColors? _findHeaderColors(double screen) {
    for (HeaderColors color in _headerColors.reversed) {
      if (screen >= color.screenY) {
        return color;
      }
    }

    return screen < _headerColors.first.screenY
        ? _headerColors.first
        : _headerColors.last;
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
    if (_tickColors.isNotEmpty) {
      double lastStart = _tickColors.first.startMs;
      for (TickColors color in _tickColors) {
        color.screenY =
            (lastStart + (color.startMs - lastStart / 2.0) - _renderStart) *
                scale;
        lastStart = color.startMs;
      }
    }
    if (_headerColors.isNotEmpty) {
      double lastStart = _headerColors.first.startMs;
      for (HeaderColors color in _headerColors) {
        color.screenY =
            (lastStart + (color.startMs - lastStart / 2.0) - _renderStart) *
                scale;
        lastStart = color.startMs;
      }
    }

    _currentHeaderColors = _findHeaderColors(0.0)!;

    if (_currentHeaderColors != null) {
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
    if (_rootEntries.isNotEmpty) {
      /// Advance the items hierarchy one level at a time.
      if (_advanceItems(_rootEntries, _gutterWidth + LineSpacing, scale,
          elapsed, animate, 0)) {
        doneRendering = false;
      }

      /// Advance all the assets and add the rendered ones into [_renderAssets].
      _renderedAssets = []; // resets here, where all UI cleanup is done?
      if (_advanceAssets(_rootEntries, elapsed, animate, _renderedAssets)) {
        doneRendering = false;
      }
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
