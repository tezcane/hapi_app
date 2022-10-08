import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/event/et.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// The timeline displays these objects, if their startMs is not 0. The
/// Favorite, Search and Relics also use this object.
/// NOTE: It is a const so all Relics/subclasses can also be const.
class Event {
  Event({
    required this.et,
    required this.tkEra,
    required this.tkTitle,
    required this.startMs, // TODO are these ms or years?!
    required this.endMs,
    this.startMenu,
    this.endMenu,
    required this.accent,
  }) {
    isEra = startMs != endMs && endMs != 0; // TODO tune

    saveTag = '${tkTitle}_${et.index}'; // Relics names not unique->Hud
    reinitTranslationTexts();
  }
  final ET et;
  final String tkEra;
  final String tkTitle;
  final double startMs;
  final double endMs;
  final double? startMenu; // use these when menu->timeline doesn't show well
  final double? endMenu;
  final Color? accent; // not always given in json input file, thus nullable

  /// Era, spans a time-span (uses start and end in input)
  late final bool isEra;

  /// Favorites may have same name (e.g. Muhammad in Prophets and Surah name) so
  /// we must give a more unique name for each event so we can save favorites or
  /// make sure we are accessing the right event in EventC.getMap/Fav() lookups.
  late final String saveTag;

  /// Used to calculate how many lines to draw for the bubble in the timeline:
  late String tvTitle; // holds translation
  late String tvTitleLine1;
  late String tvTitleLine2;
  late bool isBubbleTextThick;
  late String tvBubbleText;

  late String tvRelicTitleLine1;
  late String tvRelicTitleLine2;
  late bool isRelicTextThick;

  /// Only update bubble text on init, language change, or screen orientation
  /// changes.
  ///
  /// NOTE: If in landscape mode, no need to put the text on two lines (I hope).
  reinitTranslationTexts() {
    List<String> lines = tvGetTitleLines(22, 44, false, null); // null=force tr
    tvTitleLine1 = lines[0];
    tvTitleLine2 = lines[1];
    isBubbleTextThick = lines[1] == '' ? false : true;
    tvBubbleText = isBubbleTextThick ? lines[0] + '\n' + lines[1] : lines[0];

    // Relic Chip Views are smaller so char limits are less
    lines = tvGetTitleLines(10, 18, true, tvTitle); // just tr'd, don't do again
    tvRelicTitleLine1 = lines[0];
    tvRelicTitleLine2 = lines[1];
    isRelicTextThick = lines[1] == '' ? false : true;
  }

  /// So relics can init at compile time easier, we set this later since it
  /// requires async and we don't want complex code during Relic init. Ideally
  /// we can turn these into const for future optimizations.
  late final EventAsset asset;

  bool get isTimeLineEvent => startMs != 0 && endMs != 0; // TODO need both?

  /// Pretty-printing for the event date.
  String tvYearsAgo({double? eventYear}) {
    if (!isTimeLineEvent) return 'Date Estimate Coming Soon'.tr; // TODO

    eventYear ??= startMs;

    if (eventYear <= -10000) return tvYears(startMs) + ' ' + 'Ago'.tr;

    double tvYearsAgo;
    String adBc = ' ${'AD'.tr} (';

    if (eventYear <= 0) {
      adBc = ' ${'BC'.tr} (';
      tvYearsAgo = eventYear.abs() + TimeC.thisYear;
    } else {
      tvYearsAgo = TimeC.thisYear - eventYear;
    }
    return cns(eventYear.abs().toStringAsFixed(0)) +
        adBc +
        cns(tvYearsAgo.toStringAsFixed(0)) +
        ' ' +
        'Years Ago'.tr +
        ')';
  }

  /// Shortens large numbers, e.g. 10,000,000 returns "10 million years"
  /// Dart int supports -9223372036854775808 - 9223372036854775807
  String tvYears(double eventYear) {
    String label;
    int valueAbs = eventYear.round().abs();
    if (valueAbs >= 1000000000000000000) {
      double v = (valueAbs / 100000000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'Quintillion'.tr;
    } else if (valueAbs >= 1000000000000000) {
      double v = (valueAbs / 100000000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'Quadrillion'.tr;
    } else if (valueAbs >= 1000000000000) {
      double v = (valueAbs / 100000000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'Trillion'.tr;
    } else if (valueAbs >= 1000000000) {
      double v = (valueAbs / 100000000.0).floorToDouble() / 10.0;

      label = (valueAbs / 1000000000)
              .toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
          ' ' +
          'Billion'.tr;
    } else if (valueAbs >= 1000000) {
      double v = (valueAbs / 100000.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' ' +
              'Million'.tr;
    } else if (valueAbs >= 10000) {
      double v = (valueAbs / 100.0).floorToDouble() / 10.0;
      label =
          (valueAbs / 1000).toStringAsFixed(v == v.floorToDouble() ? 0 : 1) +
              ' ' +
              'Thousand'.tr;
    } else {
      label = cns(valueAbs.toStringAsFixed(0));
      return label + ' ' + (label == '1' ? 'Year'.tr : 'Years'.tr);
    }
    return cns(label) + ' ' + 'Years'.tr;
  }

  /// This is tricky to do, convert list of words into 2 similar sized strings.
  static List<String> splitWordsEvenlyToTwoLines(List<String> words) {
    List<String> line1Words = [];
    List<String> line2Words = [];
    int line1Chars = 0;
    int line2Chars = 0;

    int size = words.length;
    for (int idx = 0; idx < size; idx++) {
      if (idx < size / 2) {
        line1Words.add(words[idx]);
        line1Chars += words[idx].length;
      } else {
        line2Words.add(words[idx]);
        line2Chars += words[idx].length;
      }
    }

    /// Return true if nothing left to move, false otherwise
    bool moveWordToNewLine(bool moveFromLine1, int charDiffAbs) {
      if (moveFromLine1) {
        if (line2Words[0].length > charDiffAbs) return true;
        String moveToEndOfLine1 = line2Words.removeAt(0);
        line1Chars += moveToEndOfLine1.length;
        line2Chars -= moveToEndOfLine1.length;
        line1Words.add(moveToEndOfLine1);
      } else {
        if (line1Words[line1Words.length - 1].length > charDiffAbs) return true;
        String moveToStartOfLine2 = line1Words.removeAt(line1Words.length - 1);
        line1Chars -= moveToStartOfLine2.length;
        line2Chars += moveToStartOfLine2.length;
        line2Words.insert(0, moveToStartOfLine2);
      }

      return false; // possible move words remain
    }

    int moveCount = 0;
    int charDiff = line1Chars - line2Chars;
    while (charDiff.abs() > 2) {
      moveCount++;
      bool moveFromLine1 = charDiff < 0; // true=line 1, false=line 2

      if (moveWordToNewLine(moveFromLine1, charDiff.abs())) {
        break;
      }

      // after swapping, we now check if polarity switched to know to stop
      charDiff = line1Chars - line2Chars;
      if (moveFromLine1) {
        if (charDiff >= 0) break;
      } else {
        if (charDiff <= 0) break;
      }

      // TODO test more to remove this hacky edge case protection:
      if (moveCount > 5) {
        l.w('moveWordToNewLine: moveCount > 5 for $line1Words and $line2Words');
        break;
      }
    }

    String line1 = line1Words[0];
    for (int idx = 1; idx < line1Words.length; idx++) {
      line1 += ' ' + line1Words[idx];
    }
    String line2 = line2Words[0];
    for (int idx = 1; idx < line2Words.length; idx++) {
      line2 += ' ' + line2Words[idx];
    }
    return [line1, line2];
  }

  /// Expensive, doing so many translations so we call this only when needed
  List<String> tvGetTitleLines(
    int portrait, // portrait orientation max chars per line
    int landscape, // landscape orientation max chars per line
    bool forceTwoLines,
    String? tvTitleToNotReinit,
  ) {
    if (tvTitleToNotReinit == null) {
      tvTitle = a(tkTitle); // lang/orientation update so new tr needed
    }
    String tvLine1 = tvTitle;
    String tvLine2 = '';

    final int maxCharsOnLine1 = MainC.to.isPortrait ? portrait : landscape;

    // split line if it is passed X characters.
    if (tvLine1.length > maxCharsOnLine1 || forceTwoLines) {
      List<String> words = tvLine1.split(' '); // may just be a long word...
      if (words.length == 1) {
        // do nothing (forceTwoLines used but only one word is inputted)
      } else if (words.length == 2) {
        tvLine1 = words[0];
        tvLine2 = words[1];
      } else if (words.length > 2) {
        List<String> lines = splitWordsEvenlyToTwoLines(words);
        tvLine1 = lines[0];
        tvLine2 = lines[1];
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

  /// All these parameters are used by the [Timeline] object to properly
  /// position the current event. TODO prune/tune these?
  double y = 0.0;
  double endY = 0.0;
  double length = 0.0;
  double opacity = 0.0; // used to show/hide/dim an asset?
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

  bool get isVisible => opacity > 0.0; // TODO Pics hidden too long, tune this?
}
