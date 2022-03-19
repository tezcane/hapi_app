import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:hapi/controllers/time_controller.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

/// An object representing the renderable assets loaded from `timeline.json`.
///
/// Each [TimelineAsset] encapsulates all the relevant properties for drawing,
/// as well as maintaining a reference to its original [TimelineEntry].
class TimelineAsset {
  TimelineAsset(
    this.width,
    this.height,
    this.filename,
    this.scale,
  );

  final double width;
  final double height;
  final String filename;

  /// Can be overwritten
  double scale;

  /// We create the asset before we create the timeline entry so init this ASAP
  late final TimelineEntry entry;

  double opacity = 0.0;
  double scaleVelocity = 0.0;
  double y = 0.0;
  double velocity = 0.0;
}

/// A renderable image.
class TimelineImage extends TimelineAsset {
  TimelineImage(
    this.image,
    double width,
    double height,
    String filename,
    double scale,
  ) : super(
          width,
          height,
          filename,
          scale,
        );

  final ui.Image image;
}

/// This asset also has information regarding its animations.
class TimelineAnimatedAsset extends TimelineAsset {
  TimelineAnimatedAsset(
    this.loop,
    this.offset,
    this.gap,
    this.animationTime,
    double width,
    double height,
    String filename,
    double scale,
  ) : super(
          width,
          height,
          filename,
          scale,
        );

  final bool loop;
  final double offset;
  final double gap;

  /// Can be overwritten
  double animationTime;
}

/// A `Flare` Asset.
class TimelineFlare extends TimelineAnimatedAsset {
  TimelineFlare(
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    String filename,
    double scale,
  ) : super(
          loop,
          offset,
          gap,
          0.0,
          width,
          height,
          filename,
          scale,
        );

  final flare.FlutterActorArtboard actorStatic;
  final flare.FlutterActorArtboard actor;
  final flare.AABB setupAABB;

  /// Can be overwritten
  flare.ActorAnimation animation;

  /// Some Flare assets will have multiple idle animations (e.g. 'Humans'),
  /// others will have an intro&idle animation (e.g. 'Sun is Born').
  /// All this information is in `timeline.json` file, and it's de-serialized in the
  /// [Timeline.loadFromBundle()] method, called during startup.
  /// and custom-computed AABB bounds to properly position them in the timeline.
  flare.ActorAnimation? intro;
  flare.ActorAnimation? idle;
  List<flare.ActorAnimation>? idleAnimations;
}

/// An `Nima` Asset.
class TimelineNima extends TimelineAnimatedAsset {
  TimelineNima(
    this.actorStatic,
    this.actor,
    this.setupAABB,
    this.animation,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    String filename,
    double scale,
  ) : super(
          loop,
          offset,
          gap,
          0.0,
          width,
          height,
          filename,
          scale,
        );

  final nima.FlutterActor actorStatic;
  final nima.FlutterActor actor;
  final nima.AABB setupAABB;
  final nima.ActorAnimation animation;
}

/// A label for [TimelineEntry].
enum TimelineEntryType {
  Era,
  Incident,
}

/// Each entry in the timeline is represented by an instance of this object.
/// Each favorite, search result and detail page will grab the information from a reference
/// to this object.
///
/// They are all initialized at startup time by the [BlocProvider] constructor.
class TimelineEntry {
  TimelineEntry(
    this._label,
    this.type,
    this.startMs,
    this.endMs,
    this.articleFilename,
    this.asset,
    this.accent,
    this.id,
  ) {
    _handleLabelNewlineCount();
  }

  static final int todaysAdTimeYears = TimeController.to.now2().year;
  final String _label;
  final TimelineEntryType type;
  final double startMs;
  final double endMs;
  final String articleFilename;
  final TimelineAsset asset;

  /// not always given in json input file, thus nullable:
  Color? accent;
  String? id;

  /// Used to calculate how many lines to draw for the bubble in the timeline.
  int lineCount = 1;

  /// Each entry constitutes an element of a tree:
  /// eras are grouped into spanning eras and events are placed into the eras
  /// they belong to. If not null, this is the root entry, if null it's a child.
  TimelineEntry? parent;

  /// holds all entries under the parent/era. If a child will be null.
  List<TimelineEntry>? children;

  /// All the timeline entries are also linked together to easily access the next/previous event.
  /// After a couple of seconds of inactivity on the timeline, a previous/next entry button will appear
  /// to allow the user to navigate faster between adjacent events.
  /// Should only be null when on the first or last entry.
  TimelineEntry? next;
  TimelineEntry? previous;

  /// All these parameters are used by the [Timeline] object to properly position the current entry.
  double y = 0.0;
  double endY = 0.0;
  double length = 0.0;
  double opacity = 0.0;
  double labelOpacity = 0.0;
  double targetLabelOpacity = 0.0;
  double delayLabel = 0.0;
  double targetAssetOpacity = 0.0;
  double delayAsset = 0.0;
  double legOpacity = 0.0;
  double labelY = 0.0;
  double labelVelocity = 0.0;
  double gutterEventY = 0.0;

  /// I think it is true when one gutter event hides another
  bool isGutterEventOccluded = false;

  bool get isVisible {
    return opacity > 0.0;
  }

  String get label => _label;

  /// Some labels have a newline characters to adjust their alignment.
  /// Detect the occurrence and add information regarding the line-count.
  _handleLabelNewlineCount() {
    lineCount = 1;

    int startIdx = 0;
    while (true) {
      startIdx = _label.indexOf('\n', startIdx);
      if (startIdx == -1) {
        break;
      }
      lineCount++; // found a new line, continue
      startIdx++; // to go past current new line
    }
  }

  /// Debug information.
  @override
  String toString() {
    return 'TIMELINE ENTRY: $label -($startMs,$endMs)';
  }

  /// Pretty-printing for the entry date.
  String formatYearsAgo({double? eventYear}) {
    eventYear ??= startMs;

    if (eventYear <= -10000) {
      return TimelineEntry.formatYears(startMs) + ' Ago';
    }

    double yearsAgo;
    String bc = ' AD (';
    if (eventYear <= 0) {
      bc = ' BC (';
      yearsAgo = eventYear.abs() + todaysAdTimeYears;
    } else {
      yearsAgo = todaysAdTimeYears - eventYear;
    }
    return eventYear.abs().toStringAsFixed(0) +
        bc +
        yearsAgo.toStringAsFixed(0) +
        ' Years Ago)';
  }

  /// Shortens large numbers, e.g. 10,000,000 returns "10 million years"
  /// Dart int supports -9223372036854775808 - 9223372036854775807
  static String formatYears(double eventYear) {
    String label;
    int valueAbs = eventYear.round().abs();
    if (valueAbs >= 1000000000000000000) {
      double v = (valueAbs / 100000000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' Quintillion ';
    } else if (valueAbs >= 1000000000000000) {
      double v = (valueAbs / 100000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' Quadrillion ';
    } else if (valueAbs >= 1000000000000) {
      double v = (valueAbs / 100000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' Trillion ';
    } else if (valueAbs >= 1000000000) {
      double v = (valueAbs / 100000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' Billion';
    } else if (valueAbs >= 1000000) {
      double v = (valueAbs / 100000.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' Million';
    } else if (valueAbs >= 10000) {
      double v = (valueAbs / 100.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' Thousand';
    } else {
      label = valueAbs.toStringAsFixed(0);
      return label + (label == '1' ? ' Year' : ' Years');
    }
    return label + ' Years';
  }
}
