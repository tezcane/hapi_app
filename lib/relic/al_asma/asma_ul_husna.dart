import 'package:flutter/material.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';

/// Asma Ul-Husna - The Most Beautiful Names, the 99 names of Allah.
class AsmaUlHusna extends Relic {
  AsmaUlHusna(Enum e, this.ayas, this.gts, this.quranMentionCount)
      : super(
          // Event data:
          et: ET.Asma_ul__Husna,
          tkEra: ET.Asma_ul__Husna.tkIsimA,
          tkTitle: e.tkIsimA,
          start: 0,
          end: 0,
          // Relic data:
          e: e,
        ) {
    if (quranMentionCount != this.ayas.length) {
      print('asdf $e');
    }
  }
  final List<Aya> ayas; // quran or hadith ayas containing/explaining the name
  final List<GT> gts; // grammatical types
  final int quranMentionCount;

  @override
  Asset getAsset({width = 200.0, height = 200.0, scale = 1.0}) => Asset(
        filename: 'images/Allah/asma_ul__husna/'
            '${e.index < 9 ? '0${e.index + 1}' : e.index + 1}_${e.name}.svg',
        width: width,
        height: height,
        scale: scale,
      );

  @override
  // TODO: implement widget
  Widget get widget => throw UnimplementedError();

  static List<Relic> get relics => _relics;
  static List<RelicSetFilter> get relicSetFilters => _relicSetFilters;
}

final List<Relic> _relics = [
  AsmaUlHusna(
      AUH.Ar__Rahman,
      [
        AQ(1, 1,
            tkNoteBefore:
                'Beginning of every Surah (chapter) except one, and numerous other places.'),
        AQ(55, 1,
            tkNoteBefore:
                'The first verse of Surah ar-Rahman (Surah 55) consists only of this Name.')
      ],
      [GT.Direct],
      158),
  AsmaUlHusna(
      AUH.Ar__Rahim,
      [
        AQ(1, 1,
            tkNoteBefore:
                'Beginning of every Surah (chapter) except one, and numerous other places.')
      ],
      [GT.Direct],
      147),
  AsmaUlHusna(
      AUH.Al__Malik, [AQ(59, 23), AQ(20, 114), AQ(23, 116)], [GT.Direct], 3),
  AsmaUlHusna(AUH.Al__Quddus, [AQ(59, 23), AQ(62, 1)], [GT.Direct], 2),
  AsmaUlHusna(AUH.As__Salam, [AQ(59, 23)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Mu_a_min, [AQ(59, 23)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Muhaymin, [AQ(59, 23)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Aziz,
      [AQ(3, 6), AQ(4, 158), AQ(9, 40), AQ(48, 7), AQ(59, 23)], [GT.Direct], 5),
  AsmaUlHusna(AUH.Al__Jabbar, [AQ(59, 23)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Mutakabbir, [AQ(59, 23)], [GT.Direct], 1),
  AsmaUlHusna(
      AUH.Al__Khaliq,
      [AQ(6, 102), AQ(13, 16), AQ(36, 81), AQ(39, 62), AQ(40, 62), AQ(59, 24)],
      [GT.Direct],
      6),
  AsmaUlHusna(AUH.Al__Bari_a_, [AQ(59, 24)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Musawwir, [AQ(59, 24)], [GT.Direct], 1),
  AsmaUlHusna(
      AUH.Al__Ghaffar,
      [AQ(20, 82), AQ(38, 66), AQ(39, 5), AQ(40, 42), AQ(71, 10)],
      [GT.Direct],
      5),
  AsmaUlHusna(
      AUH.Al__Qahhar,
      [AQ(12, 39), AQ(13, 16), AQ(14, 48), AQ(38, 65), AQ(39, 4), AQ(40, 16)],
      [GT.Direct],
      6),
  AsmaUlHusna(AUH.Al__Wahhab, [AQ(38, 9), AQ(38, 35)], [GT.Direct], 2),
  AsmaUlHusna(AUH.Ar__Razzaq, [AQ(51, 58)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Fattah, [AQ(34, 26)], [GT.Direct], 1),
  AsmaUlHusna(
      AUH.Al___a_Alim,
      [AQ(2, 158), AQ(3, 92), AQ(4, 35), AQ(24, 41), AQ(33, 40)],
      [GT.Direct],
      5),
  AsmaUlHusna(AUH.Al__Qabid, [AQ(6, 05)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Basit, [AQ(6, 05)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Khafidh, [AQ(56, 3)], [GT.Verb], 1), // Tez Other
  AsmaUlHusna(AUH.Ar__Rafi_a_, [AQ(58, 11), AQ(6, 83)], [GT.Verb], 2),
  AsmaUlHusna(AUH.Al__Mu_a_izz, [AQ(3, 26)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Muzill, [AQ(3, 26)], [GT.Verb], 1),
  AsmaUlHusna(AUH.As__Sami_a_, [AQ(2, 127), AQ(2, 256), AQ(8, 17), AQ(49, 1)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Basir, [AQ(4, 58), AQ(17, 1), AQ(42, 11), AQ(42, 27)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Hakam, [AQ(23, 09)], [GT.Verb], 1),
  AsmaUlHusna(
      AUH.Al___a_Adl,
      [
        AQ(6, 115,
            tkNoteBefore:
                'Not explicitly mentioned as a name of Allah in the Quran or Sahih Hadith but justice (Adl) is mentioned and discussed often in the Quran.')
      ],
      [GT.Not_In_Quran],
      0),
  AsmaUlHusna(
      AUH.Al__Latif, [AQ(22, 63), AQ(31, 16), AQ(33, 34)], [GT.Direct], 3),
  AsmaUlHusna(AUH.Al__Khabir, [AQ(6, 18), AQ(17, 30), AQ(49, 13), AQ(59, 18)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Halim, [AQ(2, 235), AQ(17, 44), AQ(22, 59), AQ(35, 41)],
      [GT.Adjective], 4),
  AsmaUlHusna(
      AUH.Al___a_Athim, [AQ(2, 255), AQ(42, 4), AQ(56, 96)], [GT.Direct], 3),
  AsmaUlHusna(AUH.Al__Ghafur, [AQ(2, 173), AQ(8, 69), AQ(16, 110), AQ(41, 32)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Ash__Shakur, [AQ(35, 30), AQ(35, 34), AQ(42, 23), AQ(64, 17)],
      [GT.Adjective], 4),
  AsmaUlHusna(
      AUH.Al___a_Ali,
      [AQ(4, 34), AQ(31, 30), AQ(42, 4), AQ(42, 51), AQ(34, 23)],
      [GT.Direct],
      5),
  AsmaUlHusna(AUH.Al__Kabir, [AQ(13, 9), AQ(22, 62), AQ(31, 30), AQ(34, 23)],
      [GT.Direct], 4),
  AsmaUlHusna(
      AUH.Al__Hafiz, [AQ(11, 57), AQ(34, 21), AQ(42, 6)], [GT.Adjective], 3),
  AsmaUlHusna(AUH.Al__Muqit, [AQ(5, 25)], [GT.Indefinite_Noun], 1),
  AsmaUlHusna(AUH.Al__Hasib, [AQ(4, 6), AQ(4, 86), AQ(33, 39)],
      [GT.Indefinite_Noun], 3),
  AsmaUlHusna(
      AUH.Al__Jalil, [AQ(55, 27), AQ(7, 143)], [GT.Adjective, GT.Verb], 2),
  AsmaUlHusna(AUH.Al__Karim, [AQ(27, 40), AQ(82, 6)], [GT.Direct], 2),
  AsmaUlHusna(AUH.Ar__Raqib, [AQ(4, 1), AQ(5, 117)], [GT.Direct], 2),
  AsmaUlHusna(AUH.Al__Mujib, [AQ(12, 01)], [GT.Adjective], 1),
  AsmaUlHusna(
      AUH.Al__Wasi_a_, [AQ(2, 268), AQ(3, 73), AQ(5, 54)], [GT.Adjective], 3),
  AsmaUlHusna(AUH.Al__Hakim, [AQ(31, 27), AQ(46, 2), AQ(57, 1), AQ(66, 2)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Wadud, [AQ(11, 90), AQ(85, 14)], [GT.Direct], 2),
  AsmaUlHusna(AUH.Al__Majid, [AQ(12, 13)], [GT.Adjective], 1),
  AsmaUlHusna(AUH.Al__Ba_a_ith, [AQ(22, 7)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Ash__Shahid, [AQ(4, 166), AQ(22, 17), AQ(41, 53), AQ(48, 28)],
      [GT.Adjective], 4),
  AsmaUlHusna(AUH.Al__Haqq, [AQ(6, 62), AQ(22, 6), AQ(23, 116), AQ(24, 25)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Wakil, [AQ(3, 173), AQ(4, 171), AQ(28, 28), AQ(73, 9)],
      [GT.Adjective], 4),
  AsmaUlHusna(AUH.Al__Qawi, [AQ(22, 40), AQ(22, 74), AQ(42, 19), AQ(57, 25)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Matin, [AQ(51, 58)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Wali, [AQ(4, 45), AQ(7, 196), AQ(42, 28), AQ(45, 19)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Hamid, [AQ(14, 8), AQ(31, 12), AQ(31, 26), AQ(41, 42)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Muhsi, [AQ(72, 28), AQ(78, 29)], [GT.Verb], 2),
  AsmaUlHusna(AUH.Al__Mubdi, [AQ(10, 34), AQ(27, 64), AQ(29, 19), AQ(85, 13)],
      [GT.Verb], 4),
  AsmaUlHusna(AUH.Al__Mu_a_id, [AQ(10, 34), AQ(27, 64), AQ(29, 19), AQ(85, 13)],
      [GT.Verb], 4),
  AsmaUlHusna(AUH.Al__Muhyi, [AQ(7, 158), AQ(15, 23), AQ(30, 50), AQ(57, 2)],
      [GT.Verb], 4),
  AsmaUlHusna(AUH.Al__Mumit, [AQ(3, 156), AQ(7, 158), AQ(15, 23), AQ(57, 2)],
      [GT.Verb], 4),
  AsmaUlHusna(
      AUH.Al__Hayy,
      [AQ(2, 255), AQ(3, 2), AQ(20, 111), AQ(25, 58), AQ(40, 65)],
      [GT.Direct],
      5),
  AsmaUlHusna(
      AUH.Al__Qayyum, [AQ(2, 255), AQ(3, 2), AQ(20, 111)], [GT.Direct], 3),
  AsmaUlHusna(AUH.Al__Wajid, [AQ(38, 44)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Maajid, [AQ(85, 15), AQ(11, 73)], [GT.Adjective], 2),
  AsmaUlHusna(AUH.Al__Wahid, [AQ(13, 16), AQ(14, 48), AQ(38, 65), AQ(39, 4)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Ahad, [AQ(112, 1)], [GT.Adjective], 1),
  AsmaUlHusna(AUH.As__Samad, [AQ(112, 2)], [GT.Direct], 1),
  AsmaUlHusna(
      AUH.Al__Qadir, [AQ(6, 65), AQ(46, 33), AQ(75, 40)], [GT.Direct], 3),
  AsmaUlHusna(
      AUH.Al__Muqtadir, [AQ(18, 45), AQ(54, 42), AQ(6, 65)], [GT.Adjective], 3),
  AsmaUlHusna(AUH.Al__Muqaddim, [AQ(17, 01)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Mu_a_akhkhir, [AQ(71, 4)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Awwal, [AQ(57, 3)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Akhir, [AQ(57, 3)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Az__Zahir, [AQ(57, 3)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Batin, [AQ(57, 3)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Waali, [AQ(13, 11)], [GT.Indefinite_Noun], 1),
  AsmaUlHusna(AUH.Al__Muta_a_ali, [AQ(13, 9)], [GT.Direct], 1),
  AsmaUlHusna(AUH.Al__Barr, [AQ(52, 28)], [GT.Direct], 1),
  AsmaUlHusna(AUH.At__Tawwab, [AQ(2, 128), AQ(4, 64), AQ(49, 12), AQ(110, 3)],
      [GT.Direct], 4),
  AsmaUlHusna(AUH.Al__Muntaqim, [AQ(32, 22), AQ(43, 41), AQ(44, 16)],
      [GT.Plural_Noun], 3),
  AsmaUlHusna(
      AUH.Al___a_Afu,
      [AQ(4, 43), AQ(4, 99), AQ(4, 149), AQ(22, 60), AQ(58, 2)],
      [GT.Verb, GT.Indefinite_Noun],
      5),
  AsmaUlHusna(AUH.Ar__Ra_a_uf, [AQ(9, 117), AQ(57, 9), AQ(59, 10)],
      [GT.Indefinite_Noun], 3),
  AsmaUlHusna(AUH.Malik_ul__Mulk, [AQ(3, 26)], [GT.Direct], 1),
  AsmaUlHusna(
      AUH.Dhul__Jalali_Wal__Ikram, [AQ(55, 27), AQ(55, 78)], [GT.Direct], 2),
  AsmaUlHusna(
      AUH.Al__Muqsit, [AQ(3, 18)], [GT.Adjective, GT.Verb], 1), //Tez Other
  AsmaUlHusna(AUH.Al__Jami_a_, [AQ(3, 9)], [GT.Indefinite_Noun], 1),
  AsmaUlHusna(AUH.Al__Ghani, [AQ(39, 7), AQ(47, 38), AQ(57, 24)],
      [GT.Indefinite_Noun, GT.Adjective, GT.Direct], 3),
  AsmaUlHusna(AUH.Al__Mughni, [AQ(9, 28)], [GT.Verb], 1),
  AsmaUlHusna(
      AUH.Al__Mani_a_,
      [
        AU('Not explicitly mentioned as a name of Allah in the Quran. However, many word connotations based off the Arabic root word meem-noon (من) exist in the Quran. For example: prevent, hold back, restrain, deny, impede, resist, forbid, refuse, prohibit, guard, defend, protect, etc.')
      ],
      [GT.Not_In_Quran],
      0),
  AsmaUlHusna(AUH.Ad__Dharr, [AQ(6, 17)], [GT.Verb], 1), // Tez added
  AsmaUlHusna(
      AUH.An__Nafi_a_, [AQ(30, 37)], [GT.Indefinite_Noun], 1), // Tez added
  AsmaUlHusna(AUH.An__Nur, [AQ(24, 35)], [GT.Indefinite_Noun], 1),
  AsmaUlHusna(AUH.Al__Hadi, [AQ(22, 54)], [GT.Indefinite_Noun], 1),
  AsmaUlHusna(
      AUH.Al__Badi_a_, [AQ(2, 117), AQ(6, 101)], [GT.Indefinite_Noun], 2),
  AsmaUlHusna(AUH.Al__Baqi, [AQ(55, 27)], [GT.Verb], 1),
  AsmaUlHusna(AUH.Al__Warith, [AQ(15, 23), AQ(57, 10)], [GT.Plural_Noun], 2),
  AsmaUlHusna(
      AUH.Ar__Rashid,
      [
        AU('Not explicitly mentioned in the Quran as a name of God. However, many word connotations based off the Arabic root word raa-sheen-dal (رشذ) exist in the Quran. For example: directed aright, follow the correct course, directed to the correct way, hold a correct belief, adopt the correct path, etc.'),
        AQ(11, 87,
            tkNoteBefore:
                'Note, the word is used in this aya; however, it is not referring to Allah'),
      ],
      [GT.Not_In_Quran],
      0),
  AsmaUlHusna(AUH.As__Sabur, [AQ(2, 153), AQ(3, 200), AQ(103, 3)],
      [GT.Indefinite_Noun], 3),
];

final List<RelicSetFilter> _relicSetFilters = [
  RelicSetFilter(
    tkLabel: ET.Asma_ul__Husna.tkIsimA,
    idxList: List.generate(
      _relics.length,
      (index) => _relics[index].e.index,
    ),
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Direct.isim,
    idxList: [
      AUH.Ar__Rahman.index,
      AUH.Ar__Rahim.index,
      AUH.Al__Malik.index,
      AUH.Al__Quddus.index,
      AUH.As__Salam.index,
      AUH.Al__Mu_a_min.index,
      AUH.Al__Muhaymin.index,
      AUH.Al__Aziz.index,
      AUH.Al__Jabbar.index,
      AUH.Al__Mutakabbir.index,
      AUH.Al__Khaliq.index,
      AUH.Al__Bari_a_.index,
      AUH.Al__Musawwir.index,
      AUH.Al__Ghaffar.index,
      AUH.Al__Qahhar.index,
      AUH.Al__Wahhab.index,
      AUH.Ar__Razzaq.index,
      AUH.Al__Fattah.index,
      AUH.Al___a_Alim.index,
      AUH.As__Sami_a_.index,
      AUH.Al__Basir.index,
      AUH.Al__Latif.index,
      AUH.Al__Khabir.index,
      AUH.Al___a_Athim.index,
      AUH.Al__Ghafur.index,
      AUH.Al___a_Ali.index,
      AUH.Al__Kabir.index,
      AUH.Al__Karim.index,
      AUH.Ar__Raqib.index,
      AUH.Al__Hakim.index,
      AUH.Al__Wadud.index,
      AUH.Al__Haqq.index,
      AUH.Al__Qawi.index,
      AUH.Al__Matin.index,
      AUH.Al__Wali.index,
      AUH.Al__Hamid.index,
      AUH.Al__Hayy.index,
      AUH.Al__Qayyum.index,
      AUH.Al__Wahid.index,
      AUH.As__Samad.index,
      AUH.Al__Qadir.index,
      AUH.Al__Awwal.index,
      AUH.Al__Akhir.index,
      AUH.Az__Zahir.index,
      AUH.Al__Batin.index,
      AUH.Al__Muta_a_ali.index,
      AUH.Al__Barr.index,
    ],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Verb.isim,
    idxList: [
      AUH.Al__Qabid.index,
      AUH.Al__Basit.index,
      AUH.Al__Khafidh.index,
      AUH.Ar__Rafi_a_.index,
      AUH.Al__Mu_a_izz.index,
      AUH.Al__Muzill.index,
      AUH.Al__Hakam.index,
      AUH.Al__Jalil.index,
      AUH.Al__Ba_a_ith.index,
      AUH.Al__Muhsi.index,
      AUH.Al__Mubdi.index,
      AUH.Al__Mu_a_id.index,
      AUH.Al__Muhyi.index,
      AUH.Al__Mumit.index,
      AUH.Al__Wajid.index,
      AUH.Al__Muqaddim.index,
      AUH.Al__Mu_a_akhkhir.index,
      AUH.Al___a_Afu.index,
      AUH.Al__Muqsit.index,
      AUH.Al__Mughni.index,
      AUH.Ad__Dharr.index,
      AUH.Al__Baqi.index,
    ],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Adjective.isim,
    idxList: [
      AUH.Al__Halim.index,
      AUH.Ash__Shakur.index,
      AUH.Al__Hafiz.index,
      AUH.Al__Jalil.index,
      AUH.Al__Mujib.index,
      AUH.Al__Wasi_a_.index,
      AUH.Al__Majid.index,
      AUH.Ash__Shahid.index,
      AUH.Al__Wakil.index,
      AUH.Al__Maajid.index,
      AUH.Al__Ahad.index,
      AUH.Al__Muqtadir.index,
      AUH.Al__Muqsit.index,
      AUH.Al__Ghani.index,
    ],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Indefinite_Noun.isim,
    idxList: [
      AUH.Al__Muqit.index,
      AUH.Al__Hasib.index,
      AUH.Al__Waali.index,
      AUH.Al___a_Afu.index,
      AUH.Ar__Ra_a_uf.index,
      AUH.Al__Jami_a_.index,
      AUH.Al__Ghani.index,
      AUH.An__Nafi_a_.index,
      AUH.An__Nur.index,
      AUH.Al__Hadi.index,
      AUH.Al__Badi_a_.index,
      AUH.As__Sabur.index,
    ],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Plural_Noun.isim,
    idxList: [AUH.Al__Muntaqim.index, AUH.Al__Warith.index],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: GT.Not_In_Quran.isim,
    idxList: [
      AUH.Al___a_Adl.index,
      AUH.Al__Mani_a_.index,
      AUH.Ar__Rashid.index,
    ],
    tprMax: 33,
  ),
  RelicSetFilter(
    tkLabel: 'Quran Name Mentions',
    field: FILTER_FIELD.QuranMentionCount,
    idxList: [
      AUH.Ar__Rahman.index,
      AUH.Ar__Rahim.index,
      AUH.Al__Khaliq.index,
      AUH.Al__Qahhar.index,
      AUH.Al___a_Afu.index,
      AUH.Al__Aziz.index,
      AUH.Al__Ghaffar.index,
      AUH.Al___a_Alim.index,
      AUH.Al___a_Ali.index,
      AUH.Al__Hayy.index,
      AUH.Ash__Shahid.index,
      AUH.Al__Hamid.index,
      AUH.Al__Wali.index,
      AUH.Al__Kabir.index,
      AUH.Al__Wahid.index,
      AUH.Al__Qawi.index,
      AUH.At__Tawwab.index,
      AUH.Al__Wakil.index,
      AUH.Al__Haqq.index,
      AUH.Al__Ghafur.index,
      AUH.Ash__Shakur.index,
      AUH.Al__Basir.index,
      AUH.Al__Hakim.index,
      AUH.Al__Halim.index,
      AUH.Al__Khabir.index,
      AUH.As__Sami_a_.index,
      AUH.Al__Mumit.index,
      AUH.Al__Muhyi.index,
      AUH.Al__Mu_a_id.index,
      AUH.Al__Mubdi.index,
      AUH.Al__Ghani.index,
      AUH.Al__Hafiz.index,
      AUH.Al__Muntaqim.index,
      AUH.Al__Malik.index,
      AUH.Al__Wasi_a_.index,
      AUH.Al___a_Athim.index,
      AUH.Al__Muqtadir.index,
      AUH.Al__Qadir.index,
      AUH.As__Sabur.index,
      AUH.Al__Latif.index,
      AUH.Al__Hasib.index,
      AUH.Al__Qayyum.index,
      AUH.Ar__Ra_a_uf.index,
      AUH.Al__Maajid.index,
      AUH.Dhul__Jalali_Wal__Ikram.index,
      AUH.Al__Quddus.index,
      AUH.Al__Warith.index,
      AUH.Al__Badi_a_.index,
      AUH.Al__Wahhab.index,
      AUH.Ar__Rafi_a_.index,
      AUH.Al__Jalil.index,
      AUH.Al__Karim.index,
      AUH.Ar__Raqib.index,
      AUH.Al__Wadud.index,
      AUH.Al__Muhsi.index,
      AUH.Al__Matin.index,
      AUH.As__Samad.index,
      AUH.Al__Ahad.index,
      AUH.Al__Muqaddim.index,
      AUH.Al__Wajid.index,
      AUH.As__Salam.index,
      AUH.Al__Mu_a_akhkhir.index,
      AUH.Al__Muqsit.index,
      AUH.Al__Ba_a_ith.index,
      AUH.Al__Majid.index,
      AUH.Al__Awwal.index,
      AUH.Al__Mujib.index,
      AUH.Al__Akhir.index,
      AUH.Az__Zahir.index,
      AUH.Al__Batin.index,
      AUH.Al__Muqit.index,
      AUH.Ad__Dharr.index,
      AUH.An__Nafi_a_.index,
      AUH.Malik_ul__Mulk.index,
      AUH.Al__Hakam.index,
      AUH.Al__Muzill.index,
      AUH.Al__Mu_a_izz.index,
      AUH.Al__Waali.index,
      AUH.Al__Khafidh.index,
      AUH.Al__Basit.index,
      AUH.Al__Jami_a_.index,
      AUH.An__Nur.index,
      AUH.Al__Fattah.index,
      AUH.Ar__Razzaq.index,
      AUH.Al__Muta_a_ali.index,
      AUH.Al__Hadi.index,
      AUH.Al__Barr.index,
      AUH.Al__Musawwir.index,
      AUH.Al__Bari_a_.index,
      AUH.Al__Baqi.index,
      AUH.Al__Mutakabbir.index,
      AUH.Al__Jabbar.index,
      AUH.Al__Mughni.index,
      AUH.Al__Muhaymin.index,
      AUH.Al__Mu_a_min.index,
      AUH.Al__Qabid.index,
      AUH.Al___a_Adl.index,
      AUH.Ar__Rashid.index,
      AUH.Al__Mani_a_.index,
    ],
    tprMax: 33,
  ),
];

/// AUH = Asma Ul-Husna
enum AUH {
  Ar__Rahman,
  Ar__Rahim,
  Al__Malik,
  Al__Quddus,
  As__Salam,
  Al__Mu_a_min,
  Al__Muhaymin,
  Al__Aziz,
  Al__Jabbar,
  Al__Mutakabbir,
  Al__Khaliq,
  Al__Bari_a_,
  Al__Musawwir,
  Al__Ghaffar,
  Al__Qahhar,
  Al__Wahhab,
  Ar__Razzaq,
  Al__Fattah,
  Al___a_Alim,
  Al__Qabid,
  Al__Basit,
  Al__Khafidh,
  Ar__Rafi_a_,
  Al__Mu_a_izz,
  Al__Muzill,
  As__Sami_a_,
  Al__Basir,
  Al__Hakam,
  Al___a_Adl,
  Al__Latif,
  Al__Khabir,
  Al__Halim,
  Al___a_Athim,
  Al__Ghafur,
  Ash__Shakur,
  Al___a_Ali,
  Al__Kabir,
  Al__Hafiz,
  Al__Muqit,
  Al__Hasib,
  Al__Jalil,
  Al__Karim,
  Ar__Raqib,
  Al__Mujib,
  Al__Wasi_a_,
  Al__Hakim,
  Al__Wadud,
  Al__Majid,
  Al__Ba_a_ith,
  Ash__Shahid,
  Al__Haqq,
  Al__Wakil,
  Al__Qawi,
  Al__Matin,
  Al__Wali,
  Al__Hamid,
  Al__Muhsi,
  Al__Mubdi,
  Al__Mu_a_id,
  Al__Muhyi,
  Al__Mumit,
  Al__Hayy,
  Al__Qayyum,
  Al__Wajid,
  Al__Maajid,
  Al__Wahid,
  Al__Ahad,
  As__Samad,
  Al__Qadir,
  Al__Muqtadir,
  Al__Muqaddim,
  Al__Mu_a_akhkhir,
  Al__Awwal,
  Al__Akhir,
  Az__Zahir,
  Al__Batin,
  Al__Waali,
  Al__Muta_a_ali,
  Al__Barr,
  At__Tawwab,
  Al__Muntaqim,
  Al___a_Afu,
  Ar__Ra_a_uf,
  Malik_ul__Mulk,
  Dhul__Jalali_Wal__Ikram,
  Al__Muqsit,
  Al__Jami_a_,
  Al__Ghani,
  Al__Mughni,
  Al__Mani_a_,
  Ad__Dharr,
  An__Nafi_a_,
  An__Nur,
  Al__Hadi,
  Al__Badi_a_,
  Al__Baqi,
  Al__Warith,
  Ar__Rashid,
  As__Sabur,
}

/// GT = Grammatical Type
enum GT {
  Direct,
  Verb,
  Adjective, // Adjective or Adjectival Phrase
  Indefinite_Noun,
  Plural_Noun,
  Not_In_Quran,
//Other, // Deleted this, see "Tez Other" comments in this file.
}

/* TODO
99 Names of Allah (Al Asma Ul Husna)
The first pillar of imaan (faith) in Islam is Belief in Allah. As Muslims, we believe in Allah in accordance with His beautiful names and attributes. Allah has revealed His names repeatedly in the Holy Quran primarily for us to understand who He is. Learning and memorizing the names of Allah will help us to identify the correct way to believe in Him. There is nothing more sacred and blessed than understanding the names of Allah and living by them. How do we expect to worship, love, fear and trust our Lord, The Almighty Allah, if we don’t know who He is?

Allah says in the Quran:

And to Allah belong the best names, so invoke Him by them.. (Quran 7:180)

Allah – there is no deity except Him. To Him belong the best names. (Quran 20:8)

He is Allah, the Creator, the Inventor, the Fashioner; to Him belong the best names. (Quran 59:24)

Prophet Muhammad (ﷺ) said, “Allah has ninety-nine names, i.e. one-hundred minus one, and whoever knows them will go to Paradise.”
(Sahih Bukhari 50:894)
https://sunnah.com/bukhari/54/23

Abu Huraira reported Allah’s Messenger (ﷺ) as saying: There are ninety-nine names of Allah; he who commits them to memory would get into Paradise. Verily, Allah is Odd (He is one, and it is an odd number) and He loves odd number..”
(Sahih Muslim Book-48 Hadith-5)
https://sunnah.com/muslim/48/5


(17:110) Say to them (O Prophet!): "Call upon Him as Allah or call upon Him as al-Rahman; call Him by whichever name you will, all His names are beautiful. Neither offer your Prayer in too loud a voice, nor in a voice too low; but follow a middle course."

59:22-24
He is Allah—there is no god ˹worthy of worship˺ except Him: Knower of the seen and unseen. He is the Most Compassionate, Most Merciful.
He is Allah—there is no god except Him: the King, the Most Holy, the All-Perfect, the Source of Serenity, the Watcher ˹of all˺, the Almighty, the Supreme in Might,1 the Majestic. Glorified is Allah far above what they associate with Him ˹in worship˺!
He is Allah: the Creator, the Inventor, the Shaper. He ˹alone˺ has the Most Beautiful Names. Whatever is in the heavens and the earth ˹constantly˺ glorifies Him. And He is the Almighty, All-Wise.
 */
