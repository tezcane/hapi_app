enum RELIC_TYPE {
  // UMMAH:
  Prophet,
}

class Relic {
  //}extends TimelineEntry {
  Relic({
    this.ajrLevel,
    required this.relicId,
    required this.relicType,
    required this.nameEn,
    required this.nameAr,
    required this.trKeySummary, // e.g. Prophet Summary (ps. keys)
    required this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
    this.dateEra,
    this.dateBegin,
    this.dateEnd,
  }); // : super('', null, 0.0, 0.0, null, null);
  final int? ajrLevel;
  final RELIC_ID relicId;
  final RELIC_TYPE relicType;
  final String nameEn;
  final String nameAr;
  final String trKeySummary;
  final String trKeySummary2;
  final String? dateEra;
  final int? dateBegin;
  final int? dateEnd;
}

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
