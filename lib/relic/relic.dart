import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Each relic subsection/RelicSet (e.g. Ummah->Prophet) needs to have a
/// RELIC_TYPE so it can be easily filtered/found/accessed later.
enum RELIC_TYPE {
  // Ummah Tab:
  Prophet,
  //TODO:
  // Muhammad Laqab (Nicknames similar to 99 names of Allah)
  // Bayt_Family,
  // Sahabah,
  // Ulamah,
  // Khalifa,
  // Leaders,
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
        ) {
    ajrLevel = RelicC.to.ajrLevels[relicId.index]; // loaded from db
  }
  final RELIC_ID relicId;
  final RELIC_TYPE relicType;
  final String trKeySummary;
  final String trKeySummary2;

  // not final so we can update UI to reflect relic upgrades
  int ajrLevel = 0;

  // Abstract classes subclasses must implement:
  String get trValRelicSetTitle;
  String get trValRelicSetSubtitle;
  List<RelicSetFilter> get relicSetFilters;
}

/// Stores all information needed to show a RelicSet, see RelicSetUI().
class RelicSet {
  const RelicSet({required this.relicType, required this.relics});
  final RELIC_TYPE relicType;
  final List<Relic> relics;

  String get trValTitle => relics[0].trValRelicSetTitle;
  String get trValSubtitle => relics[0].trValRelicSetSubtitle;
  List<RelicSetFilter> get filterList => relics[0].relicSetFilters;
}

/// Used to tell RelicSetUI() what filter view to build and show.
enum FILTER_TYPE {
  Default,
  IntSort,
  Tree,
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
    required this.trValSubtitle,
    this.isResizeAble = true,
    this.tprMin = 1,
    this.tprMax = 11,
    this.data,
  });
  final FILTER_TYPE type; // used to build UI around this filter
  final String trValSubtitle; // label/Subtitle of filter on filter options menu
  final bool isResizeAble; // Tells UI if it should show -/+ buttons
  final int tprMin; // tiles per row minimum (Can be used to size tiles too)
  final int tprMax; // tiles per row maximum (Can be used to size tiles too)

  // Optional Parameters
  final Object? data; // any data needed to create the filter TODO TBD
}

/// For the DB to track ajrLevel, we need each relic to have a unique RELIC_ID.
/// DB will store the int value of the enum, e.g. RELIC_ID.Prophet_Adam.index
enum RELIC_ID {
  Prophet_Adam,
  Prophet_Idris,
  Prophet_Nuh,
  Prophet_Hud,
  Prophet_Salih,
  Prophet_Ibrahim,
  Prophet_Lut,
  Prophet_Ismail,
  Prophet_Ishaq,
  Prophet_Yaqub,
  Prophet_Yusuf,
  Prophet_Ayyub,
  Prophet_Shuayb,
  Prophet_Musa,
  Prophet_Harun,
  Prophet_Dawud,
  Prophet_Suleyman,
  Prophet_Ilyas,
  Prophet_Alyasa,
  Prophet_Yunus,
  Prophet_DhulKifl,
  Prophet_Zakariya,
  Prophet_Yahya,
  Prophet_Isa,
  Prophet_Muhammad,
}
