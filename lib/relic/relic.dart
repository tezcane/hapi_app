import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Each relic subsection/RelicSet (e.g. Ummah->Prophet) needs to have a
/// RELIC_TYPE so it can be easily filtered/found/accessed later.
enum RELIC_TYPE {
  Heaven_Allah, // AsmaUlHusna - 99 names of allah
  Heaven_Angels,
  Heaven_DoorsOfJannah,
  Heaven_LevelsOfJannah,
  Heaven_LevelsOfHell,

  Quran_AlAnbiya, // Prophets
  Quran_Saliheen, // righteous people
  Quran_Disbelievers, // bad people mentioned in the quran
  Quran_Tribes,
  Quran_Foods,

  Delil_Quran,
  Delil_Sunnah,
  Delil_Prophecies,
  Delil_Nature,
  Delil_Ruins,

  Islam_5Pillars,
  Islam_6ArticlesOfFaith,
  Islam_HolyPlaces,
  Islam_Relics, // Kaba, black stone, Prophets Bow, etc.

  Muhammad_Laqab,
  Muhammad_AlBayt,
  Muhammad_Zojah,
  Muhammad_Children,

  Ummah_Sahabah,
  Ummah_Ulama,
  Ummah_Dai, // Givers of Dawah
  Ummah_Leaders, // Amirs/Khalif

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

/// Abstract class that all relics need to extend. Also extends TimelineEntry so
/// we can show Relics on the Timeline (if they have dates), you're welcome.
abstract class Relic extends TimelineEntry {
  Relic({
    // TimelineEntry data:
    required String trValEra,
    required String trKeyEndTagLabel,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,
    // Relic data:
    required this.relicType,
    required this.relicId,
    required this.trKeySummary, // e.g. Prophet Summary (ps. keys)
    required this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
  }) : super(
          type: TimelineEntryType.Relic,
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

  // Tells UI if it should show -/+ buttons:
  late final bool isResizeable;
}
