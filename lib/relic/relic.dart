import 'package:hapi/tarikh/timeline/timeline_entry.dart';

class Relic { //}extends TimelineEntry {
  Relic(
    this.category,
    this.nameEn,
    this.nameAr,
    this.trKeySummary,  // e.g. Prophet Summary (ps. keys)
    this.trKeySummary2, // e.g. Prophet Quran Mentions (pq. keys)
    this.dateEra,
    this.dateBegin,
    this.dateEnd,
  );// : super('', null, 0.0, 0.0, null, null);
  final String category;
  final String nameEn;
  final String nameAr;
  final String trKeySummary;
  final String trKeySummary2;
  final String? dateEra;
  final int? dateBegin;
  final int? dateEnd;
}
