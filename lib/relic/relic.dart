import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Each relic subsection (e.g. Ummah->Prophet) needs to have a RELIC_TYPE so
/// it can be easily filtered/found later. TODO WIP
enum RELIC_TYPE {
  // Ummah Tab:
  Prophet,
}

class Relic extends TimelineEntry {
  Relic({
    // TimelineEntry data:
    required String trKeyEndTagLabel,
    required String era,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,
    // Relic data:
    required this.relicType,
    required this.relicId,
    required this.ajrLevel,
    required this.trKeySummary, // e.g. Prophet Summary (ps. keys)
    required this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
  }) : super(
          TimelineEntryType.Relic,
          trKeyEndTagLabel,
          era,
          startMs,
          endMs,
          asset,
          null, // accent TODO
        );
  final int ajrLevel;
  final RELIC_ID relicId;
  final RELIC_TYPE relicType;
  final String trKeySummary;
  final String trKeySummary2;
}

/// For the DB to track ajrLevel, we need each relic to have a unique RELIC_ID.
/// DB will store the int value of the enum, e.g. RELIC_ID.Prophet_Adam.index
enum RELIC_ID {
  Prophet_Adam,
  Prophet_Idris,
  Prophet_Nuh,
  Prophet_Hud,
  Prophet_Saleh,
  Prophet_Ibrahim,
  Prophet_Lut,
  Prophet_Isma_il,
  Prophet_Is_haq,
  Prophet_Yaqub,
  Prophet_Yusuf,
  Prophet_Ayyub,
  Prophet_Shu_ayb,
  Prophet_Musa,
  Prophet_Harun,
  Prophet_Dawud,
  Prophet_Suleyman,
  Prophet_Ilyas,
  Prophet_Alyasa,
  Prophet_Yunus,
  Prophet_Dhu_al_Kifl,
  Prophet_Zakariyya,
  Prophet_Yahya,
  Prophet_Isa,
  Prophet_Muhammad,
}
