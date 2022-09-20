import 'dart:ui';

import 'package:get/get.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// Tell certain UIs (Timeline/Relic views) what type(s) of events to use
enum EVENT_TYPE {
  // from json data:
  Era,
  Incident, // All timeline events and relics that have a time
  // from hapi data:
  Relic, // All relics (which can be Timeline events if their time is known)
}

/// The timeline displays these objects, if their startMs is not 0. The
/// Favorite, Search and Relics also use this object.
class Event {
  Event({
    required this.type,
    required this.trKeyEra,
    required this.trKeyTitle,
    required this.startMs, // TODO are these ms or years?!
    required this.endMs,
    required this.asset,
    this.accent,
  }) {
    // Some labels have a newline characters because they are too big
    int startIdx = a(trKeyTitle).indexOf('\n', 3); // pass 'i.', 'a.', etc.
    if (startIdx == -1) {
      titleLineCount = 1;
    } else {
      titleLineCount = 2;
    }
  }

  final EVENT_TYPE type;
  final String trKeyEra;
  final String trKeyTitle;
  final double startMs;
  final double endMs;
  final EventAsset asset;

  /// not always given in json input file, thus nullable:
  Color? accent;

  /// Used to calculate how many lines to draw for the bubble in the timeline.
  late final int titleLineCount;

  /// Each event constitutes an element of a tree:
  /// eras are grouped into spanning eras and events are placed into the eras
  /// they belong to. If not null, this is the root event, if null it's a child.
  Event? parent;

  /// holds all events under the parent/era. If a child will be null.
  List<Event>? children;

  /// All the timeline events are also linked together to easily access the next/previous event.
  /// After a couple of seconds of inactivity on the timeline, a previous/next event button will appear
  /// to allow the user to navigate faster between adjacent events.
  /// Should only be null when on the first or last event.
  Event? next;
  Event? previous;

  /// All these parameters are used by the [Timeline] object to properly position the current event.
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

  bool get isVisible => opacity > 0.0;

  // TODO asdf use this
  bool isTimeLineEvent() => startMs != 0 && endMs != 0;

  // String get trValTitle => Event.trValFromTrKeyEndTag(trKeyTitle);
  //
  // /// Attempts to translate 'i.<trKeyEndTag>' if fails, tries 'a.<trKeyEndTag>'.
  // static String trValFromTrKeyEndTag(String trKeyEndTag) {
  //   String trVal = 'i.$trKeyEndTag'.tr;
  //   return trVal.startsWith('i.') ? a('a.$trKeyEndTag') : trVal;
  // }

  // /// Some labels have a newline characters to adjust their alignment.
  // /// Detect the occurrence and add information regarding the line-count.
  // _handleLabelNewlineCount() {
  //   lineCount = 1;
  //
  //   int startIdx = 0;
  //   while (true) {
  //     startIdx = a(trKeyTitle).indexOf('\n', startIdx);
  //     if (startIdx == -1) break;
  //     lineCount++; // found a new line, continue
  //     startIdx++; // to go past current new line
  //   }
  // }

  // /// Debug information.
  // @override
  // String toString() => 'TIMELINE EVENT: $label -($startMs,$endMs)';

  /// Pretty-printing for the event date.
  String trValYearsAgo({double? eventYear}) {
    eventYear ??= startMs;

    if (eventYear <= -10000) return trValYears(startMs) + ' ' + 'i.Ago'.tr;

    double trValYearsAgo;
    String adBc = ' ${'i.AD'.tr} (';

    if (eventYear <= 0) {
      adBc = ' ${'i.BC'.tr} (';
      trValYearsAgo = eventYear.abs() + TimeC.thisYear;
    } else {
      trValYearsAgo = TimeC.thisYear - eventYear;
    }
    return cns(eventYear.abs().toStringAsFixed(0)) +
        adBc +
        cns(trValYearsAgo.toStringAsFixed(0)) +
        ' ' +
        'i.Years Ago'.tr +
        ')';
  }

  /// Shortens large numbers, e.g. 10,000,000 returns "10 million years"
  /// Dart int supports -9223372036854775808 - 9223372036854775807
  String trValYears(double eventYear) {
    String label;
    int valueAbs = eventYear.round().abs();
    if (valueAbs >= 1000000000000000000) {
      double v = (valueAbs / 100000000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'i.Quintillion'.tr;
    } else if (valueAbs >= 1000000000000000) {
      double v = (valueAbs / 100000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'i.Quadrillion'.tr;
    } else if (valueAbs >= 1000000000000) {
      double v = (valueAbs / 100000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'i.Trillion'.tr;
    } else if (valueAbs >= 1000000000) {
      double v = (valueAbs / 100000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'i.Billion'.tr;
    } else if (valueAbs >= 1000000) {
      double v = (valueAbs / 100000.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' ' +
              'i.Million'.tr;
    } else if (valueAbs >= 10000) {
      double v = (valueAbs / 100.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' ' +
              'i.Thousand'.tr;
    } else {
      label = cns(valueAbs.toStringAsFixed(0));
      return label + ' ' + (label == '1' ? 'i.Year'.tr : 'i.Years'.tr);
    }
    return cns(label) + ' ' + 'i.Years'.tr;
  }
}
