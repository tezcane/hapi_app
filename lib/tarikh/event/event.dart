import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/surah/surah.dart';
import 'package:hapi/relic/ummah/prophet.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// Tell certain UIs (Timeline/Relic views) what type(s) of events to use. This
/// Name is used to init relics, get tk keys to translate, used to index
/// the database maps storing ajrLevels, etc.
///
/// NOTE: After adding an EVENT, you must update the [EnumUtil] extension.
enum EVENT {
  /// From here on are Relics:
  /// Each relic subsection/RelicSet (e.g. Ummah->Prophet) needs to have a
  /// EVENT so it can be easily filtered/found/accessed later. TODO

//   // LEADERS
//   Al_Asma_ul_Husna, // اَلاسْمَاءُ الْحُسناى TODO all names mentioned in Quran? AsmaUlHusna - 99 names of allah
  Anbiya, // Prophets TODO non-Quran mentioned prophets
//   Muhammad, // Laqab, Family Tree here?
//   Righteous, // People: Mentioned in Quran/possible prophets/Sahabah/Promised Jannah
//
//   //ISLAM
//   Delil, //Quran,Sunnah,Nature,Ruins // See "Miracles of Quran" at bottom of file
//   Tenets, // Islam_5Pillars/6ArticlesOfFaith
//   Jannah, // Doors/Levels/Beings(Insan,Angels,Jinn,Hurlieen,Servants,Burak)
// //Heaven_LevelsOfHell,
//
//   //ACADEMIC
//   Scriptures, //  Hadith Books/Quran/Injil/Torah/Zabur/Scrolls of X/Talmud?
  Surah, // Mecca/Medina/Revelation Date/Ayat Length/Quran Order
//   Scholars, // Tabieen, TabiTabieen, Ulama (ImamAzam,Madhab+ Tirmidihi, Ibn Taymiyah), Dai (Givers of Dawah),
//   Relics, // Kaba, black stone, Prophets Bow, Musa Staff, Yusuf Turban, etc. Coins?
//   Quran_Mentions, // Tribes, Animals, Foods, People (disbelievers)
//   Arabic, // Alphabet (Muqattaʿat letters 14 of 28: ʾalif أ, hā هـ, ḥā ح, ṭā ط, yā ي, kāf ك, lām ل, mīm م, nūn ن, sīn س, ʿain ع, ṣād ص, qāf ق, rā ر.)
//
//   // Ummah
//   Amir, // Khalif/Generals
//   Muslims, // alive/dead, AlBayt (Zojah, Children), Famous (Malcom X, Mike Tyson, Shaqeel Oneil), // Amirs/Khalif not in Dynasties, Athletes,
//   Places, // HolyPlaces, Mosques, Schools, Cities  (old or new), mentioned in the Quran,Ruins, Conquered or not, Istanbul, Rome
//
//   // Dynasties (Leaders/Historical Events/Battles)
//   Dynasties, // Muhammad, Rashidun, Ummayad, Andalus, Abbasid, Seljuk, Ayyubi, Mamluk, Ottoman,
//   Rasulallah, //Muhammad Battles (Badr, Uhud, etc.)
//   Rashidun,
//   Ummayad,
//   Andalus,
//   Abbasid,
//   Seljuk,
//   Ayyubi,
//   Mamluk,
//   Ottoman,

  /// Originally from timeline.json data, put last to not throw off DB indexes
  Era, // spans a time-span (uses start and end in input)
  Incident, // Single event/incident in history (uses "date" in input)
}

extension EnumUtil on EVENT {
  String get tkRelicSetTitle => tkArabeeIsim; // name of EVENT is "a." title
  String get trPath => isRelic ? 'r/' : 't/';

  bool get isRelic => index < EVENT.Era.index;

  List<Relic> initRelics() {
    switch (this) {
      case EVENT.Anbiya:
        return relicsProphet;
      case EVENT.Surah:
        return relicsSurah;
      case EVENT.Era:
      case EVENT.Incident:
        return l.E('$name is not a relic');
    }
  }

  List<RelicSetFilter> initRelicSetFilters() {
    switch (this) {
      case EVENT.Anbiya:
        return relicSetFiltersProphet;
      case EVENT.Surah:
        return relicSetFiltersSurah;
      case EVENT.Era:
      case EVENT.Incident:
        return l.E('$name is not a relic');
    }
  }
}

/// The timeline displays these objects, if their startMs is not 0. The
/// Favorite, Search and Relics also use this object.
/// NOTE: It is a const so all Relics/subclasses can also be const.
class Event {
  Event({
    required this.eventType,
    required this.tkEra,
    required this.tkTitle,
    required this.startMs, // TODO are these ms or years?!
    required this.endMs,
    this.startMenu,
    this.endMenu,
    required this.accent,
  }) {
    saveTag = '${tkTitle}_${eventType.index}'; // Relics names not unique->Hud
    reinitBubbleText();
  }
  final EVENT eventType;
  final String tkEra;
  final String tkTitle;
  final double startMs;
  final double endMs;
  final double? startMenu; // use these when menu->timeline doesn't show well
  final double? endMenu;
  final Color? accent; // not always given in json input file, thus nullable

  /// Favorites may have same name (e.g. Muhammad in Prophets and Surah name) so
  /// we must give a more unique name for each event so we can save favorites or
  /// make sure we are accessing the right event in EventC.getMap/Fav() lookups.
  late final String saveTag;

  /// Used to calculate how many lines to draw for the bubble in the timeline:
  late String tvTitle; // holds translation
  late String tvTitleLine1;
  late String tvTitleLine2;
  late bool isBubbleThick;
  late String tvBubbleText;

  late String tvRelicTitleLine1;
  late String tvRelicTitleLine2;
  late bool isRelicThick;

  /// Only update bubble text on init, language change, or screen orientation
  /// changes.
  ///
  /// NOTE: If in landscape mode, no need to put the text on two lines (I hope).
  reinitBubbleText() {
    List<String> lines = tvGetTitleLines(22, 44);
    tvTitleLine1 = lines[0];
    tvTitleLine2 = lines[1];
    isBubbleThick = lines[1] == '' ? false : true;
    tvBubbleText = isBubbleThick ? lines[0] + '\n' + lines[1] : lines[0];

    // Relic Chip Views are smaller so char limits are less
    lines = tvGetTitleLines(9, 18); // TODO test/implement
    tvRelicTitleLine1 = lines[0];
    tvRelicTitleLine2 = lines[1];
    isRelicThick = lines[1] == '' ? false : true;
  }

  /// So relics can init at compile time easier, we set this later since it
  /// requires async and we don't want complex code during Relic init. Ideally
  /// we can turn these into const for future optimizations.
  late final EventAsset asset;

  bool get isTimeLineEvent => startMs != 0 && endMs != 0; // TODO need both?

  /// Pretty-printing for the event date.
  String tvYearsAgo({double? eventYear}) {
    if (!isTimeLineEvent) return 'Coming Soon'.tr; // TODO Year is not known yet

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

  /// Expensive, doing so many translations so we call this only when needed
  List<String> tvGetTitleLines(int portrait, int landscape) {
    tvTitle = a(tkTitle); // lang/orientation update so new tr needed
    String tvLine1 = tvTitle;
    String tvLine2 = '';

    final int maxCharsOnLine1 = MainC.to.isPortrait ? portrait : landscape;

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
        int halfOfChars = (tvTitle.length ~/ 2) + 1;

        tvLine1 = words.removeAt(0);
        bool buildLine1 = true;
        while (words.isNotEmpty) {
          String nextWord = words.removeAt(0);
          if (buildLine1) {
            int ifWordAddedToLine1Length = tvLine1.length + nextWord.length;
            if (ifWordAddedToLine1Length < maxCharsOnLine1 &&
                ifWordAddedToLine1Length <= halfOfChars) {
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
