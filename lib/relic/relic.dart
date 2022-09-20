import 'package:graphview/GraphView.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// Each relic subsection/RelicSet (e.g. Ummah->Prophet) needs to have a
/// RELIC_TYPE so it can be easily filtered/found/accessed later.
enum RELIC_TYPE {
  Heaven_Allah, // AsmaUlHusna - 99 names of allah
  Heaven_Books, // Books revealed Zabur, Torah, Injil, Scrolls of X, Quran
  Heaven_Angels,
  Heaven_DoorsOfJannah,
  Heaven_LevelsOfJannah,
  Heaven_LevelsOfHell,

  Quran_AlAnbiya, // Prophets
  Quran_Surahs,
  Quran_Saliheen, // righteous people
  Quran_Disbelievers, // bad people mentioned in the quran
  Quran_Tribes,
  Quran_Animals,
  Quran_Foods,

  Delil_Quran, // See "Miracles of Quran" at bottom of file
  Delil_Sunnah,
  Delil_Prophecies,
  Delil_Nature,
  Delil_Ruins,

  Islam_5Pillars, // Shahadah details
  Islam_6ArticlesOfFaith,
  Islam_HadithBooks, // Sahih Bukhari, Sahih Muslim, Muwatta Imam Malik, Sunan Ibn Majah, Musnad Imam Ahmad, Jami Tirmidhi, Sunan Nisaa'i, Sunan Abi Dawud
  Islam_HolyPlaces,
  Islam_Relics, // Kaba, black stone, Prophets Bow, etc. Coins?

  Ummah_Muhammad_Laqab,
  Ummah_Muhammad_AlBayt, //Zojah, Children,
  Ummah_Sahabah,
  Ummah_Ulama, // Madhab+, alive/dead
  Ummah_Dai, // Givers of Dawah
  Ummah_Famous, // Amirs/Khalif not in Dynasties, Athletes,
  Ummah_Battles, // Badr, Uhud, etc. Battles

  Dynasty_Rashidun,
  Dynasty_Ummayad,
  Dynasty_Andalus,
  Dynasty_Abbasid,
  Dynasty_Selcuk,
  Dynasty_Ayyubi,
  Dynasty_Mamluk,
  Dynasty_Ottoman,

  Places_Mosques,
  Places_Schools, // Still functioning or not
  Places_Cities, // mentioned in the Quran,Ruins,  Conquered or not, Istanbul, Rome
}

/// Abstract class that all relics need to extend. Also extends Events so we can
/// Relics on the Timeline (if they have dates), you're welcome.
abstract class Relic extends Event {
  Relic({
    // Event data:
    required String trValEra,
    required String trKeyEndTagLabel,
    required double startMs,
    required double endMs,
    required EventAsset asset,
    // Relic data:
    required this.relicType,
    required this.relicId,
    required this.trKeySummary, // e.g. Prophet Summary (ps. keys)
    required this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
  }) : super(
          type: EVENT_TYPE.Relic,
          trValEra: trValEra,
          trKeyEndTagLabel: trKeyEndTagLabel,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          accent: null,
        );
  // DB stores Map<'int relicType.index', Map<'int relicId', int ajrLevel>>.
  // Using '' quotes above since firestore only allows string keys, not ints.
  final RELIC_TYPE relicType;
  final int relicId;
  final String trKeySummary;
  final String trKeySummary2;

  /// NOTE 1: Uses 'late' to force external/db init before UI can use it.
  /// NOTE 2: Not final so we can update UI to reflect relic upgrades.
  late int ajrLevel;

  // Abstract classes subclasses must implement:
  String get trValRelicSetTitle;
  List<RelicSetFilter> get relicSetFilters;

  /// Used to prevent UI from constantly rebuilding
  final List<RelicSetFilter> relicSetFiltersInit = [];
}

/// Stores all information needed to show a RelicSet, see RelicSetUI().
class RelicSet {
  const RelicSet({required this.relicType, required this.relics});
  final RELIC_TYPE relicType;
  final List<Relic> relics;

  String get trValTitle => relics[0].trValRelicSetTitle;
  List<RelicSetFilter> get filterList => relics[0].relicSetFilters;
}

/// Used to tell RelicSetUI() what filter view to build and show.
enum FILTER_TYPE {
  Default,
  IdxList,
  Tree,
}

enum FILTER_FIELD {
  Prophet_quranMentionCount,
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
    this.treeGraph,
  }) {
    isResizeable = tprMin != tprMax; // if tpr Min/Max different it's resizeable
  }
  final FILTER_TYPE type; // used to build UI around this filter
  final String trValLabel; // filter label/Subtitle of filter options menu
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

  final Graph? treeGraph;

  // Tells UI if it should show -/+ buttons:
  late final bool isResizeable;
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
