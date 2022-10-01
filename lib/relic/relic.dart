import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/surah/surah.dart';
import 'package:hapi/relic/ummah/prophet.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// Each relic subsection/RelicSet (e.g. Ummah->Prophet) needs to have a
/// RELIC_TYPE so it can be easily filtered/found/accessed later.
///
/// NOTE: After adding relic type, you must update the [EnumUtil] extension.
enum RELIC_TYPE {
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
}

extension EnumUtil on RELIC_TYPE {
  String get trDirectoryTag => name.toLowerCase();
  String get tkRelicSetTitle => 'a.$name';

  List<Relic> initRelics() {
    switch (this) {
      case RELIC_TYPE.Anbiya:
        return relicsProphet;
      case RELIC_TYPE.Surah:
        return relicsSurah;
    }
  }

  List<RelicSetFilter> initRelicSetFilters() {
    switch (this) {
      case RELIC_TYPE.Anbiya:
        return relicSetFiltersProphet;
      case RELIC_TYPE.Surah:
        return relicSetFiltersSurah;
    }
  }
}

/// Abstract class that all relics need to extend. Also extends Events so we can
/// Relics on the Timeline (if they have dates), you're welcome.
abstract class Relic extends Event {
  Relic({
    // Event data:
    required String trValEra,
    required double startMs,
    required double endMs,
    // Relic data:
    required this.relicType,
    required this.e,
  }) : super(
          type: EVENT_TYPE.Relic,
          tkEra: trValEra,
          tkTitle: e.name,
          startMs: startMs,
          endMs: endMs,
          accent: null, // TODO
        );
  // DB stores Map<'int relicType.index', Map<'int relicId', int ajrLevel>>.
  // Using '' quotes above since firestore only allows string keys, not ints.
  final RELIC_TYPE relicType;
  final Enum e; // Unique relicId for this RELIC_TYPE

  int get ajrLevel => RelicC.to.getAjrLevel(relicType, e.index);

  /// Abstract methods:
  RelicAsset getRelicAsset({width = 200.0, height = 200.0, scale = 1.0});
  Widget get widget; // widget with all relic info
}

/// Stores all information needed to show a RelicSet, see RelicSetUI().
class RelicSet {
  RelicSet({
    required this.relicType,
    required this.relics,
    required this.tkTitle,
  });
  final RELIC_TYPE relicType;
  final List<Relic> relics;
  final String tkTitle;

  /// Must init after relics are entered into this class or Tree filters fail.
  late final List<RelicSetFilter> filterList; // TODO cleaner way to init?
}

/// Used to tell RelicSetUI() what filter view to build and show.
enum FILTER_TYPE {
  Default, // TODO needed? Can just use IdxList
  IdxList,
  Tree,
}

enum FILTER_FIELD {
  QuranMentionCount,
}

/// Used to be able to change Relic's view/information as a way for the user to
/// learn from a RelicSet, e.g. see only or highlight Ulu Al-Azm Prophets from
/// the list of all the Prophet relics. Another example, to show the Prophets or
/// Muhammad's Al-Bayt family tree views.
class RelicSetFilter {
  /// We must ensure tprMin/tprMax for all filters can support this value:
  static const DEFAULT_TPR = 5; // TODO

  RelicSetFilter({
    required this.type,
    required this.trValLabel,
    this.tprMin = 1,
    this.tprMax = 12,
    this.field,
    this.idxList,
    this.treeGraph1,
    this.treeGraph2,
  }) {
    isResizeable = tprMin != tprMax; // if tpr Min/Max different it's resizeable
  }
  final FILTER_TYPE type; // used to build UI around this filter
  final String
      trValLabel; // TODO make tkKey filter label/Subtitle of filter options menu
  /// Work with "tpr" variable found and initialized in RelicSetUI (Sorry...)
  final int tprMin;
  final int tprMax;

  // Optional Parameters
  /// OPTIONAL: You can add a string/int/object? and we will have a switch in
  /// the UI to detect this and then display it appropriately.
  final FILTER_FIELD? field;

  /// OPTIONAL: List of indexes to original relic list to display a full or
  /// subset of that list. For example, you can send in order of Prophets
  /// mentioned in the Quran count, i.e. [13, (136 Musa), 5, (69 Ibrahim)...]).
  final List<int>? idxList;

  final Graph? treeGraph1;
  final Graph? treeGraph2; // TODO may not use this for some Family Trees

  // Tells UI if it should show -/+ buttons:
  late final bool isResizeable; // TODO needed?
}

/*  Miracles of Quran:
The universe expands all the time. (adh-Dhariyat 51/47)
Big-Bang, the skies and the earth being cleft asunder. (al-Anbiya 21/30, Fussilat 41/11)
Winds fecundating clouds and plants. (al-Hijr 15/22)
The word "nahl", that is, "bee" being used as a feminine word and its verb forms being used with feminine forms. (an-Nahl 16/68-69)
Planets are not fixed; they have certain orbits and courses. (Ya-Sin 36/38 and 40, al-Anbiya 21/33, Luqman 31/29)
Two seas not mixing with each other; the law of "surface tension". (ar-Rahman 55/19-20, al-Furqan 25/53)
Underground waters being formed by rain water. (az-Zumar 39/21)
The earth being reduced from its outlying borders. (ar-Ra'd 13/41, al-Anbiya 21/44)
The dangers of the house built by the female spider and its insecurity. (al-Ankabut 29/41)
Femininity and masculinity in plants. (Ta-Ha 20/53, ar-Ra'd 13/3)
The three stages of the baby in the uterus: abdominal wall, uterine wall, amnionic membrane. (az-Zumar 39/6)
The phase of mudghah - a little lump of flesh (chewed substance) in the uterus. (al-Mu'minun 23/14)
Clouds are actually very heavy. (al-A'raf 7/57, ar-Ra'd 13/12)
Mountains are not fixed; they move. (an-Naml 27/88)
Iron came to the world from outer space. (al-Hadid 57/25)
We need to move while sleeping. (al-Kahf 18/18)
Ears are active during sleep. (al-Kahf 18/11)
Creation in pairs; everything is created in pairs and with opposites. (Ya-Sin 36/36)
The world is round. (az-Zumar 39/5, an-Naziat 79/30)
Oxygen decreases as altitude increases. (al-An'am 6/125)
Meteors; the atmosphere, which prevents us from harmful sun rays and adversities like space cold. (al-Anbiya 21/32)
The sky that returns; meteors, harmful rays, heat, radio waves... (at-Tariq 86/11)
Mountains with duties. (al-Anbiya 21/31, an-Naba 78/6-7, Luqman 31/10)
The star that knocks. (at-Tariq 86/1)
The red rose in the sky "Rosetta Nebula". (ar-Rahman 55/37)
Relativity of time. (as-Sajda 32/5, al-Maarij 70/4)
It is not possible to leave the atmosphere without a propelling power and a burning will occur in the meantime. (ar-Rahman 55/ 33-36)
Everybody has different fingerprints. (al-Qiyamah 75/4)
Everybody has different tongue prints. (ar-Rum 30/22)
Cattle were sent down from the sky. (az-Zumar 39/6)
 */
