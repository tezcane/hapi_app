class Relic {
  Relic(
    this.category,
    this.nameEn,
    this.nameAr,
    this.trKeySummary,  // e.g. Prophet Summary (ps. keys)
    this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
    this.dateEra,
    this.dateBegin,
    this.dateEnd,
  );
  final String category;
  final String nameEn;
  final String nameAr;
  final String trKeySummary;
  final String trKeySummary2;
  final String? dateEra;
  final int? dateBegin;
  final int? dateEnd;
}

/// Quran Verse
class QV {
  QV(this.surah, this.ayaStart, {this.ayaEnd});
  final int surah;
  final int ayaStart;
  int? ayaEnd;
}
