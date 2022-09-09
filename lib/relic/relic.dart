import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Each relic subsection (e.g. Ummah->Prophet) needs to have a RELIC_TYPE so
/// it can be easily filtered/found later. TODO WIP
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

class Relic extends TimelineEntry {
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
