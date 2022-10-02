/// Use this class to nicely display Quran and Hadith on the UI.
abstract class Aya {
  Aya({this.tkNoteBefore, this.tkNoteAfter});
  String? tkNoteBefore; // OPTIONAL: note to display before verse
  String? tkNoteAfter; // OPTIONAL: note to display after verse

  bool get isNoteBeforeAndAfter => isNoteBefore && isNoteAfter;
  bool get isNoteBefore => tkNoteBefore != null;
  bool get isNoteAfter => tkNoteAfter != null;

  String tvAyaText(Aya aya) =>
      (isNoteBefore ? '\n\n$tkNoteBefore' : '') +
      '\n\n$tvGetAyaText' +
      (isNoteAfter ? '\n\n$tkNoteAfter\n\n' : '\n\n');

  /// Replace {0}, {1}... with Aya Text
  String tvlInsertAyas(String tvTemplate, List<Aya> ayasToInsert) {
    String rv = tvTemplate; // does normal tr or "a."

    // loop through translated text and add arabic/transliteration text:
    for (int idx = 0; idx < ayasToInsert.length; idx++) {
      rv = rv.replaceFirst('{$idx}', tvAyaText(ayasToInsert[idx]));
    }

    return rv;
  }

  // Abstract methods:
  String get tvGetAyaText; // TODO probably want to return a widget too:
}

/// AQ = Aya Quran (TODO rename to AQ)
class QV extends Aya {
  QV(
    this.surah,
    this.start, {
    this.end,
    String? tkNoteBefore,
    String? tkNoteAfter,
  }) : super(
          tkNoteBefore: tkNoteBefore,
          tkNoteAfter: tkNoteAfter,
        );
  final int surah;
  final int start;
  int? end; // use to specify end of range, e.g. Surah 1, verse 2-3 (the 3 here)

  bool get isOneVerse => end == null;
  bool get isMultiVerse => end != null; // grow up...

  @override
  // TODO: implement getAyaText
  String get tvGetAyaText => throw UnimplementedError();
}
