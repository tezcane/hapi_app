import 'dart:ui';

import 'package:flutter/material.dart';
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
/// NOTE: It is a const so all Relics/subclasses can also be const.
class Event {
  Event({
    required this.type,
    required this.trKeyEra,
    required this.trKeyTitle,
    required this.startMs, // TODO are these ms or years?!
    required this.endMs,
    required this.accent,
  }) {
    reinitBubbleText();
  }
  final EVENT_TYPE type;
  final String trKeyEra;
  final String trKeyTitle;
  final double startMs;
  final double endMs;

  /// not always given in json input file, thus nullable:
  Color? accent;

  /// Used to calculate how many lines to draw for the bubble in the timeline:
  late String tvEventTitleLine1;
  late String tvEventTitleLine2;
  late bool isBubbleThick;
  late String tvBubbleText;

  /// Only update bubble text on init or if orientation changes.  If we are in
  /// landscape mode there is no need to put the text on two lines (hopefully).
  reinitBubbleText() {
    List<String> lines = tvGetTitleLines(); // expensive so call less on paints
    tvEventTitleLine1 = lines[0];
    tvEventTitleLine2 = lines[1];
    isBubbleThick = lines[1] == '' ? false : true;
    tvBubbleText = isBubbleThick ? lines[0] + '\n' + lines[1] : lines[0];
  }

  /// So relics can init at compile time easier, we set this later since it
  /// requires async and we don't want complex code during Relic init. Ideally
  /// we can turn these into const for future optimizations.
  late final EventAsset asset;

  bool get isTimeLineEvent => startMs != 0 && endMs != 0; // TODO need both?

  /// Pretty-printing for the event date.
  String trValYearsAgo({double? eventYear}) {
    if (!isTimeLineEvent) return 'i.Coming Soon'; // TODO Year is not known yet

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

  /// TODO Should call this on language changes
  List<String> tvGetTitleLines() {
    String tvLine1 = a(trKeyTitle); // translated here, why we must force update
    String tvLine2 = '';

    final int maxCharsOnLine1 = MainC.to.isPortrait ? 22 : 44;

    // split line if it is passed X characters.
    if (tvLine1.length > maxCharsOnLine1) {
      List<String> words = tvLine1.split(' '); // may just be a long word...
      if (words.length == 2) {
        tvLine1 = words[0];
        tvLine2 = words[1];
      } else if (words.length == 3) {
        String word1 = words[0];
        String word2 = words[1];
        String word3 = words[2];

        int line1WordsDiff = (word1.length + word2.length - word3.length).abs();
        int line2WordsDiff = (word1.length - word2.length + word3.length).abs();
        if (line1WordsDiff <= line2WordsDiff) {
          tvLine1 = words[0] + ' ' + words[1];
          tvLine2 = words[2];
        } else {
          tvLine1 = words[0];
          tvLine2 = words[1] + ' ' + words[2];
        }
      } else if (words.length > 3) {
        // TODO better optimize?
        tvLine1 = words.removeAt(0);
        bool buildLine1 = true;
        while (words.isNotEmpty) {
          String nextWord = words.removeAt(0);
          if (buildLine1) {
            if (words.length == 2 &&
                words[0].length + words[1].length < maxCharsOnLine1) {
              tvLine1 += ' ' + nextWord;
              buildLine1 = false;
              continue;
            }
            if (tvLine1.length + nextWord.length < maxCharsOnLine1) {
              tvLine1 += ' ' + nextWord;
            } else {
              buildLine1 = false;
              tvLine2 += nextWord;
              continue;
            }
          } else {
            tvLine2 += ' ' + nextWord;
          }
        }
      }
    }
    return [tvLine1, tvLine2];
  }

  // TODO Original codes from her on, can probably optimize a lot:

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
}
