import 'package:hapi/quran/quran.dart';

enum HADITH_BOOK {
  Sahih_Bukhari,
  Sahih_Muslim,
  Muwatta_Imam_Malik,
  Sunan_Ibn_Majah,
  Musnad_Imam_Ahmad,
  Jami_Tirmidhi,
  Sunan_Nisaa,
  Sunan_Abi_Dawud,
}

enum HADITH_BOOK_CHAPTER {
  Sahih_Bukhari_TOOD,
  Sahih_Muslim_TOOD,
  Muwatta_Imam_Malik_TOOD,
  Sunan_Ibn_Majah_TOOD,
  Musnad_Imam_Ahmad_TOOD,
  Jami_Tirmidhi_TOOD,
  Sunan_Nisaa_TOOD,
  Sunan_Abi_Dawud_TOOD,
}

/// AH = Aya Hadith
class AH extends Aya {
  AH(
    this.book,
    this.chapter,
    this.location, {
    String? tkNoteBefore,
    String? tkNoteAfter,
  }) : super(tkNoteBefore: tkNoteBefore, tkNoteAfter: tkNoteAfter);
  final HADITH_BOOK book;
  final HADITH_BOOK_CHAPTER chapter;
  final String location; // TODO further classify hadiths in different books

  @override
  // TODO: implement getAyaText
  String get tvGetAyaText => throw UnimplementedError();
}
