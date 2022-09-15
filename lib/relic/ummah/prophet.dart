import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

const String _ = ' '; // space/gap

class Prophet extends FamilyTree {
  Prophet({
    // TimelineEntry data:
    required String trValEra,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,

    // Relic data not needed to pass in, it is auto-generated in super() call

    // Required Fam data:
    required Isim isim,
    required List<Enum> trValPredecessors,
    // Optional Fam data:
    List<String>? trValLaqab, // Laqab - Nicknames
    List<Enum>? trValSuccessors,
    List<Enum>? trValSpouses,
    List<Enum>? trValDaughters,
    List<Enum>? trValSons,
    List<Enum>? trValRelatives,
    List<RELATIVE>? trValRelativesTypes,
    Enum? trValMother,
    Enum? trValFather,

    // Required prophet data:
    required this.trValSentTo,
    required this.quranMentionCount,
    required this.qvNabi,
    // Optional prophet data:
    this.qvRasul,
    this.trValKitab,
    this.qvsUluAlAzm,
    this.trValLocationBirth,
    this.trValLocationDeath,
    this.trValTomb,
  }) : super(
          // TimelineEntry data:
          trValEra: trValEra,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          // Relic data:
          relicType: RELIC_TYPE.Quran_AlAnbiya,
          trKeySummary: 'ps.${isim.trKeyEndTagLabel}', // ps=Prophet Summary
          trKeySummary2: 'pq.${isim.trKeyEndTagLabel}', // pq=Prophet Quran
          // Required Fam data:
          isim: isim,
          trValLaqab: trValLaqab,
          trValPredecessors: trValPredecessors,
          // Optional Fam data:
          trValSuccessors: trValSuccessors,
          trValSpouses: trValSpouses,
          trValDaughters: trValDaughters,
          trValSons: trValSons,
          trValRelatives: trValRelatives,
          trValRelativesTypes: trValRelativesTypes,
          trValMother: trValMother,
          trValFather: trValFather,
        );
  // Required prophet data:
  final String trValSentTo; // nation the prophet was sent to:
  final int quranMentionCount;
  final QV qvNabi; // Prophet (nabī) نَبِيّ
  // Optional prophet data:
  final QV? qvRasul; // Messenger (rasūl) رَسُول
  final String? trValKitab;
  final List<QV>? qvsUluAlAzm; // Archprophet (ʾUlu Al-'Azm)
  final String? trValLocationBirth;
  final String? trValLocationDeath;
  final String? trValTomb;

  bool isRasul() => qvRasul != null;
  bool isUluAlAzm() => qvsUluAlAzm != null && qvsUluAlAzm!.isNotEmpty;

  @override
  int get gapIdx => PF.Gap.index;

  @override
  String get trValRelicSetTitle => a('a.Anbiya');
  @override
  List<RelicSetFilter> get relicSetFilters {
    if (_relicSetFilters.isNotEmpty) return _relicSetFilters;

    // Add special cases here, if needed
    Graph graph = getFamilyTreeGraph();

    _relicSetFilters.addAll([
      RelicSetFilter(
        type: FILTER_TYPE.Default,
        trValLabel: a('a.Nabi'),
      ),
      RelicSetFilter(
        type: FILTER_TYPE.IdxList,
        trValLabel: a('a.Rasul'),
        idxList: [
          PF.Adam.index,
          PF.Nuh.index,
          PF.Hud.index,
          PF.Salih.index,
          PF.Ibrahim.index,
          PF.Lut.index,
          PF.Ismail.index,
          PF.Yusuf.index,
          PF.Shuayb.index,
          PF.Musa.index,
          PF.Harun.index,
          PF.Dawud.index,
          PF.Ilyas.index,
          PF.Yunus.index,
          PF.Isa.index,
          PF.Muhammad.index,
        ],
      ),
      RelicSetFilter(
        type: FILTER_TYPE.IdxList,
        trValLabel: a('a.Ulu Al-Azm'),
        tprMax: 5,
        idxList: [
          PF.Nuh.index,
          PF.Ibrahim.index,
          PF.Musa.index,
          PF.Isa.index,
          PF.Muhammad.index,
        ],
      ),
      RelicSetFilter(
        type: FILTER_TYPE.IdxList,
        trValLabel: 'i.Quran Name Mentions'.tr,
        field: FILTER_FIELD.Prophet_quranMentionCount,
        idxList: [
          PF.Musa.index, //    136 <-Mentions in Quran
          PF.Ibrahim.index, //  69
          PF.Nuh.index, //      43
          PF.Lut.index, //      27
          PF.Yusuf.index, //    27
          PF.Adam.index, //     25
          PF.Isa.index, //      25
          PF.Harun.index, //    20
          PF.Ishaq.index, //    17
          PF.Suleyman.index, // 17
          PF.Yaqub.index, //    16
          PF.Dawud.index, //    16
          PF.Ismail.index, //   12
          PF.Salih.index, //     9
          PF.Shuayb.index, //    9
          PF.Hud.index, //       7
          PF.Zakariya.index, //  7
          PF.Yahya.index, //     5
          PF.Ayyub.index, //     4
          PF.Yunus.index, //     4
          PF.Muhammad.index, //  4
          PF.Idris.index, //     2
          PF.DhulKifl.index, //  2 TODO other righteous men/women counts
          PF.Ilyas.index, //     2
          PF.Alyasa.index, //    2
        ],
      ),
      RelicSetFilter(
        type: FILTER_TYPE.Tree,
        trValLabel: 'i.Family Tree'.tr,
        treeGraph: graph,
      ),
    ]);

    return _relicSetFilters;
  }
}

Future<List<Prophet>> initProphets() async {
  List<Prophet> rv = [];

  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Birth of Humans'.tr,
    startMs: -3400000,
    endMs: -3399050,
    asset: await _getTimelineImageAsset(PF.Adam),
    // Fam data:
    isim: Isim(
      PF.Adam,
      trValHebrew: 'אדם (Adam) - ' + 'p.Meaning:_'.tr + 'p.man'.tr,
      trValGreek: 'Αδάμ (Adam)',
      trValLatin: 'Adam',
    ),
    trValLaqab: null,
    trValPredecessors: [], // must be blank, root of the tree
    trValSuccessors: [PF.Sheth],
    trValMother: null, // must leave blank for tree logic
    trValFather: null, // must leave blank for tree logic
    trValSpouses: [PF.Hawwa],
    trValSons: [PF.Habel, PF.Qabel, PF.Anaq, PF.Sheth],
    trValDaughters: null, // TODO
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: 'p.Earth from Heaven'.tr + _ + cns('(4:1)'),
    quranMentionCount: 25,
    qvNabi: QV(2, 31),
    // Optional prophet data:
    qvRasul: QV(2, 31),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: a('a.Jennah'),
    trValLocationDeath: null,
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Birth of Humans'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Idris),
    // Fam data:
    isim: Isim(PF.Idris,
        trValHebrew: 'חֲנוֹך (Hanokh) - ' + 'p.Meaning:_'.tr + 'i.dedicated'.tr,
        trValGreek: 'Ἐνώχ (Enoch)',
        trValLatin: 'Enoch'),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Adam,
      PF.Sheth,
      PF.Anwas,
      PF.Qinan,
      PF.Mahlail,
    ],
    trValSuccessors: [PF.Nuh],
    trValMother: null,
    trValFather: PF.Yarid,
    trValSpouses: null,
    trValSons: [PF.Matulshalkh],
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Babylon'),
    quranMentionCount: 2,
    qvNabi: QV(19, 56),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: a('a.Babylon'),
    trValLocationDeath: 'p.Sixth Heaven'.tr,
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Great Flood'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Nuh),
    // Fam data:
    isim: Isim(
      PF.Nuh,
      trValHebrew: 'נֹחַ (Noach) - ' + 'p.Meaning:_'.tr + 'i.rest, repose'.tr,
      trValGreek: 'Νῶε (Noe)',
      trValLatin: null,
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Idris,
      PF.Matulshalkh,
    ],
    trValSuccessors: [PF.Hud],
    trValMother: null,
    trValFather: PF.Lamik,
    trValSpouses: [PF.Naamah],
    trValDaughters: null, // TODO
    trValSons: [PF.Ham, PF.Yam, PF.Yafith, PF.Sam],
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: 'p.The people of_'.tr + a('a.Nuh') + _ + cns('(26:105)'),
    quranMentionCount: 43,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(25, 107),
    trValKitab: null,
    qvsUluAlAzm: [QV(46, 35), QV(33, 7)],
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    startMs: -2400,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Hud),
    // Fam data:
    isim: Isim(
      PF.Hud,
      trValHebrew: 'עבר (Eber) - ' + 'p.Meaning:_'.tr + 'i.region beyond'.tr,
      trValGreek: null,
      trValLatin: null,
      possibly: true, //Possibly Eber or his son
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Nuh,
      PF.Sam,
      PF.Irem,
      PF.Aush,
      PF.Ad,
      PF.Khalud,
      PF.Raya,
    ],
    trValSuccessors: [PF.Salih],
    trValMother: null,
    trValFather: PF.Abdullah,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Ad') + _ + a('a.Tribe') + _ + cns('(7:65)'),
    quranMentionCount: 7,
    qvNabi: QV(26, 125),
    // Optional prophet data:
    qvRasul: QV(26, 125),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        'p.Possibly in Qabr Nabi Hud, Hadhramaut, Yemen; Near the Zamzam well; south wall of the Umayyad Mosque, Damascus, Syria.'
            .tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Salih),
    // Fam data:
    isim: Isim(
      PF.Salih,
      trValHebrew: null,
      trValGreek: null,
      trValLatin: null,
      possibly: true,
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Nuh,
//    PF.Sam,
      PF.Irem,
      PF.Ars,
      PF.Samud,
      PF.Hadzir,
      PF.Ubayd,
      PF.Masih,
      PF.Auf,
    ],
    trValSuccessors: [PF.Ibrahim],
    trValMother: null,
    trValFather: PF.Abir_Ubayd,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    trValRelativesTypes: null,
    // Required prophet data:
    trValSentTo: a('a.Thamud') + _ + a('a.Tribe') + _ + cns('(7:73)'),
    quranMentionCount: 9,
    qvNabi: QV(26, 143),
    // Optional prophet data:
    qvRasul: QV(26, 143),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: "p.Possibly in Mada'in Salih or Hasik, Oman.".tr, // TODO
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Ibrahim),
    // Fam data:
    isim: Isim(
      PF.Ibrahim,
      trValHebrew:
          'אַבְרָהָם (Abraham) - ' + 'p.Meaning:_'.tr + 'i.many, multitude'.tr,
      trValGreek: 'Ἀβραάμ (Abraam)',
      trValLatin: 'Abraham',
    ),
    trValLaqab: [
      a('a.Khalilullah'), // Friend of Allah
      'Father of Abrahimic faiths', // TODO
    ],
    trValPredecessors: [
//    PF.Nuh,
      PF.Sam,
      PF.Arfakhshad,
      PF.Shalikh,
      PF.Abir,
      PF.Falikh,
      PF.Rau_Ergu,
      PF.Sarukh,
      PF.Nahur,
    ],
    trValSuccessors: [PF.Ishaq, PF.Ismail],
    trValMother: PF.Mahalath,
    trValFather: PF.Azar_Taruh,
    trValSpouses: [PF.Sarah, PF.Hajar],
    trValDaughters: null,
    trValSons: [PF.Ismail, PF.Ishaq, PF.Madyan],
    trValRelatives: [PF.Lut],
    trValRelativesTypes: [RELATIVE.Nephew],
    // Required prophet data:
    trValSentTo: a('a.Babylon') +
        'i.,_'.tr +
        'i.The people of_'.tr +
        a('a.Al-Eiraq') + // Iraq العراق
        'i._and_'.tr +
        a('a.Suria') + // Syria سوريا
        _ +
        cns('(22:43)'),
    quranMentionCount: 69,
    qvNabi: QV(19, 41),
    // Optional prophet data:
    qvRasul: QV(9, 70),
    trValKitab: 'p.Scrolls of_'.tr + a('a.Ibrahim') + _ + cns('(87:19)'),
    qvsUluAlAzm: [QV(2, 124)],
    trValLocationBirth: 'p.Ur al-Chaldees, Bilād ar-Rāfidayn'.tr,
    trValLocationDeath: 'a.Al-Khalil'.tr + // Hebron الخليل
        'i.,_'.tr +
        a('a.Bilad al-Sham'), // Greater Syria لبِلَاد الشَّام
    trValTomb: 'p.Ibrahimi Mosque, Hebron'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Lut),
    // Fam data:
    isim: Isim(
      PF.Lut,
      trValHebrew: 'לוֹט (Lot) - ' + 'p.Meaning:_'.tr + 'p.covering, veil'.tr,
      trValGreek: null,
      trValLatin: null,
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Nuh,
//    PF.Sam,
      PF.Arfakhshad,
      PF.Shalikh,
      PF.Abir,
      PF.Falikh,
      PF.Rau_Ergu,
      PF.Sarukh,
      PF.Nahur,
    ],
    trValSuccessors: null,
    trValMother: null,
    trValFather: PF.Haran,
    trValSpouses: null,
    // TODO Possibly had 2+ daughters, but the daughters referenced in the
    //  Quran could also mean the women of his nation:
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Ibrahim, PF.Ayyub, PF.Shuayb],
    trValRelativesTypes: [RELATIVE.Uncle, RELATIVE.Grandson, RELATIVE.Grandson],
    // Required prophet data:
    trValSentTo: a('a.Saddoom') + // سدوم Sodom
        'i._and_'.tr +
        a("a.'Amoorah") + //  عمورة Gomorrah
        _ +
        cns('(7:80)'), // TODO arabee
    quranMentionCount: 27,
    qvNabi: QV(6, 86),
    // Optional prophet data:
    qvRasul: QV(37, 133),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: a(
        "a.Bani Na'im"), //  بني نعيم  Palestinian town in the southern West Bank located 8 kilometers (5.0 mi) east of Hebron.
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    startMs: -1800,
    endMs: -1664,
    asset: await _getTimelineImageAsset(PF.Ismail),
    // Fam data:
    isim: Isim(
      PF.Ismail,
      trValHebrew:
          'יִשְׁמָעֵאל (Yishmael) - ' + 'p.Meaning:_'.tr + 'i.God will hear'.tr,
      trValGreek: 'Ἰσμαήλ (Ismael)',
      trValLatin: 'Ismahel',
    ),
    trValLaqab: ['p.Father of the Arabs'], // TODO
    trValPredecessors: [], // must be blank, Father->Son used to build tree
    trValSuccessors: null,
    trValMother: PF.Hajar,
    trValFather: PF.Ibrahim,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Ishaq],
    trValRelativesTypes: [RELATIVE.HalfBrother],
    // Required prophet data:
    trValSentTo: 'p.Pre-Islamic_' +
        a('a.Al-Arabiyyah') +
        'i.,_'.tr +
        a('a.Makkah al-Mukarramah'),
    quranMentionCount: 12,
    qvNabi: QV(19, 54),
    // Optional prophet data:
    qvRasul: QV(19, 54),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    trValLocationDeath:
        a('a.Makkah al-Mukarramah'), // Mecca مكة المكرمة 'Makkah the Noble',
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Ishaq),
    // Fam data:
    isim: Isim(
      PF.Ishaq,
      trValHebrew: 'יִצְחָק (Yitzhaq) - ' +
          'p.Meaning:_'.tr +
          'i.he will laugh, he will rejoice'.tr,
      trValGreek: 'Ισαάκ ()',
      trValLatin: 'Isaac',
    ),
    trValLaqab: ['p.Father of the Hebrews/Jews'], // TODO
    trValPredecessors: [],
    trValSuccessors: [PF.Yaqub],
    trValMother: PF.Sarah,
    trValFather: PF.Ibrahim,
    trValSpouses: [PF.Rafeqa],
    trValDaughters: null,
    trValSons: [PF.Yaqub, PF.Isu],
    trValRelatives: [PF.Ismail],
    trValRelativesTypes: [RELATIVE.HalfBrother],
    // Required prophet data:
    trValSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    quranMentionCount: 17,
    qvNabi: QV(19, 49),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Old Egyptian Kingdom'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Yaqub),
    // Fam data:
    isim: Isim(
      PF.Yaqub,
      trValHebrew: 'יַעֲקֹב (Yaaqov) - ' +
          'p.Meaning:_'.tr +
          'i.Possibly "holder of the heel" or derived from "may God protect"'
              .tr,
      trValGreek: 'Ἰακώβ (Iakob)',
      trValLatin: 'Iacob',
    ),
    trValLaqab: [
      a('a.Israel'), //  إِسْرَآءِيل
      'Father of the 12 tribes of Israel',
    ],
    trValPredecessors: [],
    trValSuccessors: [PF.Yusuf],
    trValMother: PF.Rafeqa,
    trValFather: PF.Ishaq,
    trValSpouses: [PF.Rahil_Bint_Leban, PF.Lia],
    trValDaughters: null,
    trValSons: [
      PF.Yusuf,
      PF.Bunyamin,
      PF.Lawi,
      PF.Yahudzha,
      // TODO And all 12 tribe founders
    ],
    trValRelatives: null,
    trValSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    quranMentionCount: 16,
    qvNabi: QV(19, 49),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Old Egyptian Kingdoms'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Yusuf),
    // Fam data:
    isim: Isim(
      PF.Yusuf,
      trValHebrew: 'יוֹסֵף (Yosef) - ' + 'p.Meaning:_'.tr + 'i.he will add'.tr,
      trValGreek: 'Ἰωσήφ (Ioseph)',
      trValLatin: 'Ioseph',
    ),
    trValLaqab: null,
    trValPredecessors: [],
    trValSuccessors: null,
    trValMother: PF.Rahil_Bint_Leban,
    trValFather: PF.Yaqub,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Bunyamin], // TODO 10 more!
    trValRelativesTypes: [RELATIVE.Brother], // TODO 10 more!
    // Required prophet data:
    trValSentTo: 'p.Ancient Kingdom of_'.tr + a('a.Misr'), // Egypt
    quranMentionCount: 27,
    qvNabi: QV(4, 89),
    // Optional prophet data:
    qvRasul: QV(40, 34),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Ayyub),
    // Fam data:
    isim: Isim(
      PF.Ayyub,
      trValHebrew:
          'אִיּוֹב (Iyyov) - ' + 'p.Meaning:_'.tr + 'i.persecuted, hated'.tr,
      trValGreek: 'Ἰώβ (Iob)',
      trValLatin: 'Iob',
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Ishaq,
      PF.Isu,
      PF.Rimil,
    ],
    trValSuccessors: null,
    trValMother: PF.DaughterOfLut,
    trValFather: PF.Amose,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: [PF.DhulKifl],
    trValRelatives: [PF.Lut],
    trValRelativesTypes: [RELATIVE.Grandfather],
    // Required prophet data:
    trValSentTo: a('a.Edom'), // TODO Arabee version
    quranMentionCount: 4,
    qvNabi: QV(4, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Al-Qarah Mountains in southern Oman'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr, // TODO
    startMs: 0, // TODO Buddha: 6th or 5th century BCE
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.DhulKifl),
    // Fam data:
    isim: Isim(
      PF.DhulKifl,
      trValHebrew: 'יְחֶזְקֵאל (Yechezkel) - ' +
          'p.Meaning:_'.tr +
          'i.God will strengthen'.tr,
      trValGreek: 'Ἰεζεκιήλ (Iezekiel)',
      trValLatin: 'Ezechiel, Hiezecihel',
      possibly: true,
    ),
    trValLaqab: null,
    trValPredecessors: [],
    trValSuccessors: null,
    trValMother: null,
    trValFather: PF.Ayyub,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    // TODO Kifl or Kapilavastu in the northern Indian subcontinent:
    trValSentTo: 'p.Possibly Babylon or Indain subcontinent'.tr,
    quranMentionCount: 2,
    qvNabi: QV(21, 85, ayaEnd: 86),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Makam Dağı in Ergani province of Diyarbakir'.tr +
        'i.,_'.tr +
        a('a.Turkiye'),
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Shuayb),
    // Fam data:
    isim: Isim(
      PF.Shuayb,
      trValHebrew: 'יִתְרוֹ (Yitro) - ' + 'p.Meaning:_'.tr + 'i.abundance'.tr,
      trValGreek: null,
      trValLatin: 'Jethro',
      possibly: true,
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Ibrahim,
      PF.Madyan,
      PF.Yashjar,
    ],
    trValSuccessors: [PF.Musa],
    trValMother: PF.DaughterOfLut,
    trValFather: PF.Mikeel,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Lut],
    trValRelativesTypes: [RELATIVE.Grandfather],
    // Required prophet data:
    trValSentTo: a('a.Madyan') + // Midian
        _ +
        cns('(7:85)'),
    quranMentionCount: 9,
    qvNabi: QV(26, 178),
    // Optional prophet data:
    qvRasul: QV(26, 178),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        'p.Possibly in Wadi Shuʿayb, Jordan, Guriyeh, Shushtar, Iran or Hittin in the Galilee'
            .tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    startMs: -1300,
    endMs: -1200,
    asset: await _getTimelineImageAsset(PF.Musa),
    // Fam data:
    isim: Isim(
      PF.Musa,
      trValHebrew: 'מֹשֶׁה (Moshe) - ' +
          'p.Meaning:_'.tr +
          'i.Possibly from Egyptian "son" or Hebrew "deliver"'.tr,
      trValGreek: 'Μωϋσῆς (Mouses)',
      trValLatin: 'Moyses',
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Yaqub,
      PF.Lawi,
      PF.Kehath_Yashur,
    ],
    trValSuccessors: [PF.Harun],
    trValMother: PF.Yukabid,
    trValFather: PF.Imran,
    trValSpouses: [PF.Saffurah],
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Harun, PF.Miriam, PF.Asiya],
    trValRelativesTypes: [
      RELATIVE.Brother,
      RELATIVE.Sister,
      RELATIVE.FosterMother,
    ],
    // Required prophet data:
    trValSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 136,
    qvNabi: QV(20, 47),
    // Optional prophet data:
    qvRasul: QV(20, 47),
    trValKitab: 'p.Ten Commandments, Tawrah (Torah); Scrolls of Moses (53:36)',
    qvsUluAlAzm: [QV(46, 35), QV(33, 7)],
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.An-Nabi Musa, Jericho'.tr, // ٱلنَّبِي مُوْسَى
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    startMs: -1303,
    endMs: -1200,
    asset: await _getTimelineImageAsset(PF.Harun),
    // Fam data:
    isim: Isim(
      PF.Harun,
      trValHebrew: 'אַהֲרֹן (Aharon) - ' +
          'p.Meaning:_'.tr +
          'i.Possibly from unknown Egyptian origin or a derivation of Hebrew "high mountain" or "exalted"'
              .tr,
      trValGreek: 'Ἀαρών (Aaron)',
      trValLatin: 'Aaron',
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Yaqub,
//    PF.Lawi,
      PF.Kehath_Yashur,
    ],
    trValSuccessors: [PF.Dawud],
    trValMother: PF.Yukabid,
    trValFather: PF.Imran,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Musa, PF.Miriam],
    trValRelativesTypes: [RELATIVE.Brother, RELATIVE.Sister],
    // Required prophet data:
    trValSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 20,
    qvNabi: QV(19, 53),
    // Optional prophet data:
    qvRasul: QV(20, 47),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Jabal Harun, Jordan or in Sinai'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    startMs: -1000,
    endMs: -971,
    asset: await _getTimelineImageAsset(PF.Dawud),
    // Fam data:
    isim: Isim(
      PF.Dawud,
      trValHebrew: 'דָּוִד (Dawid) - ' + 'p.Meaning:_'.tr + 'i.beloved'.tr,
      trValGreek: 'Δαυίδ (Dauid)',
      trValLatin: 'David',
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Dawud,
      PF.Yahudzha,
      PF.Gap,
    ], // TODO 'p.In kingship: Possibly Talut (Saul), in prophethood: Samuil (Samuel)'
    trValSuccessors: [PF.Suleyman],
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: [PF.Suleyman],
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Al-Quds'), // Jerusalem - القدس
    quranMentionCount: 16,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(6, 89),
    trValKitab: a('a.Zabur') + // Psalms
        _ +
        cns('(17:55, 4:163, 17:55, 21:105)'),
    qvsUluAlAzm: null,
    trValLocationBirth: a('a.Al-Quds'),
    trValLocationDeath: a('a.Al-Quds'),
    trValTomb: 'p.Tomb of Harun, Jabal HarUn in Petra, Jordan'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    startMs: -971,
    endMs: -931,
    asset: await _getTimelineImageAsset(PF.Suleyman),
    // Fam data:
    isim: Isim(
      PF.Suleyman,
      trValHebrew: 'שְׁלֹמֹה (Shelomoh) - ' +
          'p.Meaning:_'.tr +
          'p.Derived from "peace"'.tr +
          ' (שָׁלוֹם shalom)',
      trValGreek: 'Σαλωμών (Salomon)',
      trValLatin: 'Solomon',
    ),
    trValLaqab: null,
    trValPredecessors: [],
    trValSuccessors: [PF.Ilyas],
    trValMother: null,
    trValFather: PF.Dawud,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Al-Quds'),
    quranMentionCount: 17,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    trValLocationDeath:
        a('a.United') + _ + 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    trValTomb: 'p.Al-Ḥaram ash-Sharīf, Jerusalem'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Ilyas),
    // Fam data:
    isim: Isim(
      PF.Ilyas,
      trValHebrew: 'אֱלִיָּהוּ (Eliyyahu), אֵלִיָה (Eliya) - ' +
          'p.Meaning:_'.tr +
          'i.my God is Yahweh'.tr,
      trValGreek: 'Ηλίας (Ilias)',
      trValLatin: 'Elias',
    ),
    trValLaqab: null,
    trValPredecessors: [
      PF.Harun,
      PF.Izar,
      PF.Fahnaz,
    ],
    trValSuccessors: [PF.Alyasa],
    trValMother: null,
    trValFather: PF.Yasin,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Samaria') + //  TODO
        'i.,_'.tr +
        'i.The people of_'.tr +
        a('a.Ilyas') +
        _ +
        cns('(37:124)'),
    quranMentionCount: 2,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(37, 123),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Baalbek, Lebanon'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Alyasa),
    // Fam data:
    isim: Isim(
      PF.Alyasa,
      trValHebrew: 'אֱלִישַׁע (Alysha\'e/Elisha) - ' +
          'p.Meaning:_'.tr +
          'i.my God is salvation'.tr,
      trValGreek: 'Ἐλισαιέ (Elisaie)',
      trValLatin: 'Eliseus',
    ),
    trValLaqab: null,
    trValPredecessors: [
      PF.Yusuf,
      PF.Efraim,
      PF.Shultem,
    ],
    trValSuccessors: [PF.Yunus],
    trValMother: null,
    trValFather: PF.Adi,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Samaria') + //  TODO
        'i.,_'.tr +
        a('a.East') +
        _ +
        a('a.Al-Arabiyyah') +
        'i._and_' +
        a('a.Fars'), //Fars? Persia
    quranMentionCount: 2,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Eğil district of Diyarbakir Province'.tr +
        'i.,_'.tr +
        a('a.Turkiye'), //' or Al-Awjam, Saudi Arabia.'
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    startMs:
        -800, // uncertain (8th century BCE or post-exilic period) in Wikipedia
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Yunus),
    // Fam data:
    isim: Isim(
      PF.Yunus,
      trValHebrew: 'יוֹנָה (Yonah) - ' + 'p.Meaning:_'.tr + 'i.dove'.tr,
      trValGreek: 'Ἰωνᾶς (Ionas)',
      trValLatin: 'Ionas',
    ),
    trValLaqab: [a('a.Dhul-Nun')], // ذُو ٱلنُّوْن - The One of the Fish
    trValPredecessors: [
      PF.Bunyamin,
      PF.Gap,
    ],
    trValSuccessors: [PF.Zakariya],
    trValMother: null,
    trValFather: PF.Matta,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: a('a.Nineveh') + // TODO Ninevah? arabee?
        'i.,_'.tr +
        'i.The people of_'.tr +
        a('a.Yunus') +
        cns('(10:98)'),
    quranMentionCount: 4,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(37, 139),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        "p.Possibly at the Mosque of Yunus, Mosul, Iraq, Mashhad Village Gath-hepher, Israel; Halhul, Palestinian West Bank; Sarafand, Lebanon; Giv'at Yonah (Jonah's Hill) in Ashdod, Israel, near Fatih Pasha Mosque in Diyarbakir"
                .tr +
            'i.,_'.tr +
            a('a.Turkiye'),
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    startMs: 0,
    endMs: 0,
    asset: await _getTimelineImageAsset(PF.Zakariya),
    // Fam data:
    isim: Isim(
      PF.Zakariya,
      trValHebrew:
          'זְכַרְיָה (Zekharyah) - ' + 'p.Meaning:_'.tr + 'i.God remembers'.tr,
      trValGreek: 'Ζαχαρίας (Zacharias)',
      trValLatin: 'Zaccharias',
    ),
    trValLaqab: null,
    trValPredecessors: [
//    PF.Yaqub,
//    PF.Yahudzha,
//    PF.Gap,
      PF.Suleyman,
      PF.Gap,
    ],
    trValSuccessors: [PF.Yahya],
    trValMother: null,
    trValFather: null,
    trValSpouses: [PF.Ishba],
    trValDaughters: null,
    trValSons: [PF.Yahya],
    trValRelatives: null, // TODO relation to Isa?
    // Required prophet data:
    trValSentTo: a('a.Al-Quds'),
    quranMentionCount: 7,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Great Mosque of Aleppo, Syria'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    startMs: -100,
    endMs: 28, // AD 28–36
    asset: await _getTimelineImageAsset(PF.Yahya),
    // Fam data:
    isim: Isim(
      PF.Yahya,
      trValHebrew:
          'יוֹחָנָן (Yochanan) - ' + 'p.Meaning:_'.tr + 'i.God is gracious'.tr,
      trValGreek: 'Ἰωάννης (Ioannes)',
      trValLatin: 'Iohannes',
    ),
    trValLaqab: ['p.Christians add "the Babtist" to the end of his name'.tr],
    trValPredecessors: [],
    trValSuccessors: [PF.Isa],
    trValMother: PF.Ishba,
    trValFather: PF.Zakariya,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Isa],
    trValRelativesTypes: [RELATIVE.DistantCousin],
    // Required prophet data:
    trValSentTo:
        at('p.{0} of {1} in {2}', ['a.Children', 'a.Israel', 'a.Al-Quds']),
    quranMentionCount: 5,
    qvNabi: QV(3, 39),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLocationBirth: null,
    trValLocationDeath: 'p.Decapitated by the ruler Herod Antipas'.tr,
    trValTomb: 'p.His head is possibly at the Umayyad Mosque in Damascus'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    startMs: -4,
    endMs: 30,
    asset: await _getTimelineImageAsset(PF.Isa),
    // Fam data:
    isim: Isim(
      PF.Isa,
      trValAramaic: 'יֵשׁוּעַ (Ishoʿ)',
      trValGreek: 'Ιησους (Iesous)',
      trValLatin: 'Iesus',
    ),
    trValLaqab: [a('a.Masih')], // Messiah
    trValPredecessors: [
      PF.Suleyman,
      PF.Gap,
      PF.ImranAbuMaryam,
    ],
    trValSuccessors: [PF.Muhammad],
    trValMother: PF.Maryam,
    trValFather: null,
    trValSpouses: null,
    trValDaughters: null,
    trValSons: null,
    trValRelatives: [PF.Zakariya, PF.Yahya],
    trValRelativesTypes: [RELATIVE.DistantCousin, RELATIVE.DistantCousin],
    // Required prophet data:
    trValSentTo:
        at('p.{0} of {1} in {2}', ['a.Children', 'a.Israel', 'a.Al-Quds']) +
            'p._as written in the_' +
            a('a.Quran') +
            _ +
            cns('61:6') +
            "p._which references the Bible's Matthew_".tr +
            cns('15:24'),
    quranMentionCount: 25,
    qvNabi: QV(19, 30),
    // Optional prophet data:
    qvRasul: QV(4, 171),
    trValKitab: a('a.Injil') + // Gospel
        _ +
        cns('(57:27)'),
    qvsUluAlAzm: [QV(42, 13)],
    trValLocationBirth: 'p.Judea, Roman Empire'.tr,
    trValLocationDeath:
        'p.Still alive, was raised to Heaven from_'.tr + a('a.Falastin'),
    trValTomb: 'p.None yet'.tr,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Muhammad'), // Muhammad
    startMs: 570,
    endMs: 632,
    asset: await _getTimelineImageAsset(PF.Muhammad),
    // Fam data:
    isim: Isim(PF.Muhammad),
    trValLaqab: [
      a('a.Khātam al-Nabiyyīn'),
      a('a.Abu al-Qasim'),
      a('a.Ahmad'),
      a('a.Al-Mahi'),
      a('a.al-Hashir'),
      a('a.Al-Aqib'),
      a('a.al-Nabī'),
      a('a.Rasūl’Allāh'),
      a('a.al-Ḥabīb'),
      a('a.Ḥabīb Allāh'),
      a("a.al-Raḥmah lil-'Ālamīn"),
      a('a.An-Nabiyyu l-Ummiyy'),
      a('a.Mustafa'),
    ],
    trValPredecessors: [
      PF.Ismail,
      PF.Gap,
      PF.Abdull_Muttalib,
    ],
    trValSuccessors: [PF.Mahdi, PF.Isa],
    trValMother: PF.Amina_Bint_Wahb,
    trValFather: PF.Abdullah_,
    trValSpouses: [
      // TODO Link to RELIC_TYPE.Bayt:
      //https://en.wikipedia.org/wiki/Muhammad%27s_wives
      //https://www.quora.com/After-the-death-of-Prophet-Muhammad-which-of-his-wives-died-first
      PF.Khadijah, //     cns('595–619: ') + a('a.Khadijah'),
      PF.Sawdah, //       cns('619–632: ') + a('a.Sawdah'),
      PF.Aisha, //        cns('623–632: ') + a('a.Aisha'), //- Only virgin',
      PF.Hafsah, //       cns('625–632: ') + a('a.Hafsah'),
      PF.UmmAlMasakin, // cns('625–626: ') + a('a.Umm al-Masakin'),
      PF.UmmSalamah, //   cns('625–632: ') + a('a.Umm Salamah'),
      PF.Zaynab, //       cns('627–632: ') + a('a.Zaynab'),
      PF.Juwayriyah, //   cns('628–632: ') + a('a.Juwayriyah'),
      PF.UmmHabibah, //   cns('628–632: ') + a('a.UmmHabibah'),
      PF.Safiyyah, //     cns('629–632: ') + a('a.Safiyyah'),
      PF.Maymunah, //     cns('629–632: ') + a('a.Maymunah'),
      PF.Rayhana, //      cns('627–631: ') + a('a.Rayhana'), // concubine later married?
      PF.Maria, //        cns('628–632: ') + a('a.Maria'), // concubine later married?
    ],
    // TODO Link to RELIC_TYPE.Bayt:
    trValDaughters: null,
    // trValDaughters: [ // TODO Disable for now since UI gets too big
    //   PF.Zainab, //       cns('599–629 ') + a('a.Zainab'),
    //   PF.Ruqayyah, //     cns('601–624 ') + a('a.Ruqayyah'),
    //   PF.Umm_Kulthum, //  cns('603–630 ') + a('a.Umm Kulthum'),
    //   PF.Fatimah, //      cns('605–632 ') + a('a.Fatimah'),
    // ],
    trValSons: null,
    // trValSons: [
    //   // https://en.wikipedia.org/wiki/Muhammad%27s_children
    //   PF.Zayd_Ibn_Harithah, //    cns('581-629 ') + a('a.Zayd ibn Harithah'),
    //   PF.Qasim, //                cns('598–601 ') + a('a.Al-Qasim'),
    //   PF.Abdullah_Ibn_Muhmmad, // cns('611–613 ') + a('a.Abdullah'),
    //   PF.Ibrahim_Ibn_Muhmmad, //  cns('630–632 ') + a('a.Ibrahim'),
    // ],
    trValRelatives: null,
    // Required prophet data:
    trValSentTo: 'p.All the worlds'.tr +
        'i.,_'.tr +
        a('a.Nas') + // mankind
        'i._and_'.tr +
        a('a.Jinn') +
        _ +
        cns('(21:107)'),
    quranMentionCount: 4,
    qvNabi: QV(33, 40),
    // Optional prophet data:
    qvRasul: QV(33, 40),
    trValKitab: a('a.Quran') +
        _ +
        cns('(42:7)') +
        'i._and_'.tr +
        a('a.Sunnah') +
        _ +
        cns('(3:31, 3:164, 4:59, 4:115, 59:7)'),
    qvsUluAlAzm: [QV(2, 124)],
    trValLocationBirth: a(DAY_OF_WEEK.Monday.trKey) +
        'i.,_'.tr +
        cni(12) +
        _ +
        a("a.Rabi' Al-Thani") +
        _ +
        cni(53) +
        'i.BH'.tr +
        '/' +
        cni(570) +
        'i.AD'.tr +
        'i.,_'.tr +
        a('a.Aliathnayn') +
        'i.,_'.tr +
        a('a.Al-Madinah') + // Al Madinah Al Munawwarah المدينة المنورة,
        'i.,_'.tr +
        a('a.Al-Hejaz') +
        'i.,_'.tr +
        a('a.Al-Arabiyyah'),
    trValLocationDeath: a(DAY_OF_WEEK.Monday.trKey) +
        'i.,_'.tr +
        cni(12) +
        _ +
        a("a.Rabi' Al-Thani") +
        _ +
        cni(11) +
        'i.AH'.tr +
        '/' +
        cni(632) +
        'i.AD'.tr +
        'i.,_'.tr +
        a('a.Aliathnayn') + // Monday
        'i.,_'.tr +
        a('a.Al-Madinah') +
        'i.,_'.tr +
        a('a.Al-Hejaz') + // ٱلْحِجَاز al-Ḥijaz
        'i.,_'.tr +
        a('a.Al-Arabiyyah'), // Arabia - الْعَرَبِيَّة
    trValTomb: at('p.Green Dome in {0}, {1}',
        ['a.Al-Masjid an-Nabawi', 'a.Al-Madinah']), //المسجد النبوي
  ));

  return rv;
}

Future<TimelineAsset> _getTimelineImageAsset(
  PF prophet, {
  double width = 192,
  double height = 192,
  double scale = 0,
}) async =>
    await TarikhC.tih.loadImageAsset(
      'assets/images/anbiya/${prophet.name}.png',
      width,
      height,
      scale,
    );

// PROPHET FAMILY (TODO Turkish Words: Hızır, Lukman, Yuşa, Kâlib b. Yüfena, Hızkıl, Şemûyel, Şâ'yâ
enum PF {
  Adam, //      0 Adem
  Idris, //     1 İdris
  Nuh, //       2
  Hud, //       3
  Salih, //     4
  Ibrahim, //   5 İbrahim
  Lut, //       6 İsmail
  Ismail, //    7 İshak
  Ishaq, //     8
  Yaqub, //     9 Yakub
  Yusuf, //    10
  Ayyub, //    11 Eyyub
  DhulKifl, // 12 Zülkifl
  Shuayb, //   13 Şuayb
  Musa, //     14
  Harun, //    15
  Dawud, //    16 Davud
  Suleyman, // 17 Süleyman
  Ilyas, //    18 İlyas
  Alyasa, //   19 Elyesa
  Yunus, //    20
  Zakariya, // 21
  Yahya, //    22
  Isa, //      23
  Muhammad, // 24

  // special case area
  Gap, // We probably know trValPredecessor

  // Wife of:
  Hawwa, //        Adam-Havva
  Naamah, //       Nuh // TODO find arabic name
  Sarah, //        Ibrahim 1-Sare
  Hajar, //        Ibrahim 2-Hacer
  Rafeqa, //       Ishaq, mother of Ishaq Rebekah-Refaka
  Rahil_Bint_Leban, //        Yaqub Rachel
  Lia, //          Yaqub Leah
  Saffurah, //     Musa  صفورة

  // Mother of:
  Mahalath, // Ibrahim
  DaughterOfLut, // Ayyub and Shuayb's Mother
  Yukabid, // Musa and Harun يوكابد  Latin: Jochebed // Other possible names are Ayaarkha or Ayaathakht (Ibn Katheer), Lawha (Al-Qurtubi) and Yoohaana (Ibn 'Atiyyah)
  Asiya, // Musa foster mother, wife of Firaun

  // Sister of:
  Miriam, // Musa and Harun // TODO Sister that followed Musa down river (Same name as Maryam?)

//   Adam
  /* TODO has ~40-120 more kids! */
  /* */ Habel, //       Cain-Habil
  /* */ Qabel, //       Abel-Kabil
  /* */ Anaq, //        ?
  /* */ Sheth, //       Seth? Shayth? Seth-Şit
  /*    */ Anwas, //    Anoush? Enush? Enosh-Enuş
  /*    */ Qinan, //    Kenan-Kinan
  /*    */ Mahlail, //  Mahlabeel? Mahalel
  /*    */ Yarid, //    Yard? Jared-Yarid
//         Idris AKA Ahnuh/Uhnuh
  /*    */ Matulshalkh, // Mitoshilkh?  Methusaleh-Mettu Şelah
  /*    */ Lamik, //       Lamech-Lamek/Lemek/Lemk
//         Nuh
  /*       */ Ham, //      Ham
  /*       */ Yam, //      Yam (Killed in flood)
  /*       */ Yafith, //   Japeth
  /*       */ Sam, //      Shem
  /*          */ Irem,
  /*             */ Aush, //        ?-Avs
  /*                */ Ad, //       ?
  /*                */ Khalud, //   ?-Halud
  /*                */ Raya, //     ?-Rebah
  /*                */ Abdullah, // ?
//                     Hud
  /*             */ Ars, //       Abir?
  /*                */ Samud, //  -Semud
  /*                */ Hadzir, // -Hadir
  /*                */ Ubayd, //  -Ubeyd
  /*                */ Masih, //  Kemaşic?
  /*                */ Auf, //    -Esif/Asit
  /*                */ Abir_Ubayd, //   Ubayd?
//                     Salih
  /*          */ Arfakhshad, // -Erfahşed
  /*          */ Shalikh, // -Şalıh
  /*          */ Abir, // NOTE: NOT HUD
  /*          */ Falikh, // -Falığ
  /*          */ Rau_Ergu, // AKA Ergu
  /*          */ Sarukh, // AKA Sharug -Şarug
  /*          */ Nahur, // -Nahor
  /*          */ Azar_Taruh, // AKA Taruh -Tarah // TODO Mentioned in Quran
  /*             */ Haran, // AKA Taruh -Tarah, brother of Ibrahim
//                     Lut - Nephew of Abraham
//                  Ibrahim
  /*                */ Madyan, // Midian-Medyen
  /*                   */ Yashjar, // Mubshakar? Issachar-Yeşcur
  /*                   */ Mikeel, //  Mankeel? Safyon? -Mikail
//                        Shuayb
//                     Ismail
//                        ... <- Save for Muhammad's SAW Family Tree
//                        Muhammad
//                     Ishaq
  /*                   */ Isu, //   AlEls? Els? Ish? Isu? Easu-Ays Brother of Jacob
  /*                      */ Rimil, // Razih? Tarekh? Rimil-Razıh
  /*                      */ Amose, // Mose-Mus
//                           Ayyub
//                           Dhul-Kifl
//                        Yaqub  TODO And all 12 tribe founders
  /*                      */ Bunyamin, // (son of Rahil) Benjamin-Bünyamin
  //                             Abumatta?
  /*                          */ Matta, // متى - Amittai latin, Matthew
//                               Yunus
//                           Yusuf  (son of Rahil)
  /*                         */ Efraim, //  Ephraim-Efrâîm // TODO branch out to Yusa here: Yuşa: b. Nûn b. Ephraim-Efrâim b. Yûsuf
  /*                         */ Shultem, // Shultam-Şütlem
  /*                         */ Adi, //     -Adiy
//                              Alyasa TODO It is also said that Alyasa is the son of Ilyas's uncle Ukhtub-Ahtub (Through Harun, Not Yusuf like here).
  /*                      */ Lawi,
  /*                         */ Kehath_Yashur, //       Kohath-Kahis_Yashür
  /*                         */ Imran, // عمران   -Lavi
//                                 Musa
//                                 Harun
  /*                               */ Izar, // -Ayzar,
  /*                               */ Fahnaz, // -Finhas,
  /*                               */ Yasin,
//                                    Ilyas
  /*                      */ Yahudzha,
  //                         UNKNOWN GAP?
//                           Dawud,
//                           Suleyman,
//                           UNKNOWN GAP? TODO Danyal, Uzeyir AND Bridge Isa + Zakariya/Yahya
  /*                         */ Faqud, // TODO Mothers side of Isa, Zakariya, Yahya so not solid line?
  /*                            */ Ishba, // Wife of Zakariya, Mother / of Yahya/Elizabeth', // TODO find arabic + Barren all her life until miracle birth of Yahya in her old age
  //                               +
//                                 Zakariya
//                                    Yahya
  /*                            */ Hanna,
  //                               +
  /*                            */ ImranAbuMaryam,
  /*                                  */ Maryam, // Specia case,  prophethood through mom
//                                          Isa

// Muhammad's Bayt:
  Mahdi, // Future!
  Amina_Bint_Wahb, // Mother // آمِنَة ٱبْنَت وَهْب
  Abdull_Muttalib, // Grandfather
  Abdullah_, //       Father عَبْد ٱللَّٰه ٱبْن عَبْد ٱلْمُطَّلِب
// Wives:
  Khadijah, //     Muhammad 1
  Sawdah, //       Muhammad 2
  Aisha, //        Muhammad 3
  Hafsah, //       Muhammad 4
  UmmAlMasakin, // Muhammad 5
  UmmSalamah, //   Muhammad 6
  Zaynab, //       Muhammad 7
  Juwayriyah, //   Muhammad 8
  UmmHabibah, //   Muhammad 9
  Safiyyah, //     Muhammad 10
  Maymunah, //     Muhammad 11
  Rayhana, //      Muhammad 12
  Maria, //        Muhammad 13
// Daughters:
  Zainab,
  Ruqayyah,
  Umm_Kulthum,
  Fatimah,
// Sons:
  Zayd_Ibn_Harithah, // زَيْد ٱبْن حَارِثَة  (foster son)
  Qasim,
  Abdullah_Ibn_Muhmmad,
  Ibrahim_Ibn_Muhmmad,
}

/// Isim=("Name" in Arabic). Used to identify a prophet/person as they are known
/// in scripture (Bible/Torah/Quran relations).
class Isim {
  Isim(
    this.e, {
    this.trValAramaic,
    this.trValHebrew,
    this.trValGreek,
    this.trValLatin,
    this.possibly = false,
  });
  final Enum e;
  final String? trValAramaic;
  final String? trValHebrew;
  final String? trValGreek;
  final String? trValLatin;
  // Something in data is unsure, e.g. Hud is Eber in Bible.
  final bool possibly; // TODO convert to string with why possibly

  String get trValTransilteration => e.name;
  String get trValTranslation => a('a.${e.name}');
  String get trValArabic => LanguageC.to.ar('a.${e.name}');

  /// Arabic Transileration
  String get trKeyEndTagLabel => e.name;
  //if (pf == PF.DhulKifl) return 'Dhul-Kifl'; // TODO auto make nice?

  int get relicId => e.index;

  /// Add * to mark something as "Possibly" being true
  String addPossibly(String trVal) => trVal + (possibly ? '*' : '');
}

enum RELATIVE {
  Possibly, // Possibly a distant relative
  Uncle,
  Grandson,
  Grandfather,
  Daughter,
  Nephew,
  HalfBrother,
  Brother,
  Sister,
  FosterMother,
  DistantCousin,
}

/// Used to save all we can about a Prophet's/Leader's/Person's family lineauge
/// so we use to build a family tree or nice UI about this relic.  A few rules:
///   1. If Father->Son are both relics, Father must declare son in trValSons.
///   2. If Father->Son are both relics, Son must have trValPredecessors = []
///   3. The root node must have trValPredecessors = []
abstract class FamilyTree extends Relic {
  FamilyTree({
    // TimelineEntry data:
    required String trValEra,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,
    // Relic data:
    required RELIC_TYPE relicType,
    required String trKeySummary,
    required String trKeySummary2,
    // Fam Required
    required this.isim,
    required this.trValPredecessors,
    // Fam Optional
    this.trValLaqab,
    this.trValSuccessors,
    this.trValMother,
    this.trValFather,
    this.trValSpouses,
    this.trValSons,
    this.trValDaughters,
    this.trValRelatives,
    this.trValRelativesTypes,
  }) : super(
          // TimelineEntry data:
          trValEra: trValEra,
          trKeyEndTagLabel: isim.trKeyEndTagLabel,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          // Relic data:
          relicType: relicType,
          relicId: isim.relicId,
          trKeySummary: trKeySummary,
          trKeySummary2: trKeySummary2,
        );
  // Required Fam data:
  final Isim isim;
  final List<Enum> trValPredecessors;
  // Optional Fam data:
  final List<String>? trValLaqab;
  final List<Enum>? trValSuccessors;
  final List<Enum>? trValSpouses;
  final List<Enum>? trValDaughters;
  final List<Enum>? trValSons;
  final List<Enum>? trValRelatives;
  final List<RELATIVE>? trValRelativesTypes;
  final Enum? trValMother;
  final Enum? trValFather;

  final List<RelicSetFilter> _relicSetFilters = [];

  // Implement on inhertting classes
  int get gapIdx;

  Graph getFamilyTreeGraph() {
    final Graph graph = Graph()..isTree = true;
    for (Relic relic in RelicC.to.getRelicSet(relicType).relics) {
      addFamilyNodes(graph, relic as FamilyTree);
    }
    return graph;
  }

  /// Init tree with all relics and the relic's ancestors, parents, and kids.
  addFamilyNodes(Graph graph, FamilyTree ft) {
    Node? lastNode;
    bool paintGapEdgeNext = false;

    /// Embedded function so we can use this methods variables
    addEdge(int idx, String dbgMsg, String name, {bool updateLastNode = true}) {
      Node node = Node.Id(idx);

      if (lastNode == null) {
        lastNode = node; // lastNode inits to whoever calls addEdge() first
        l.d('FAM_NODE:INIT:$dbgMsg: ${lastNode!.key}->$idx $name');
        return;
      }

      l.d('FAM_NODE:$dbgMsg: ${lastNode!.key}->$idx $name');

      graph.addEdge(
        lastNode!,
        node,
        paint: Paint()
          ..color = paintGapEdgeNext ? Colors.red : Colors.green
          ..strokeWidth = 3,
      );

      paintGapEdgeNext = false; // if it was set we clear it now
      if (updateLastNode) lastNode = node; // needed to add next node
    }

    // add predecessors, is [] on root and when Father->Son set previously
    for (Enum e in ft.trValPredecessors) {
      if (e.index == gapIdx) {
        paintGapEdgeNext = true;
        l.d('FAM_NODE:Predecessors:GAP: set flag paintGapEdgeNext=true');
        continue; // don't add "Gap" edge, flag makes next edge red
      }
      addEdge(e.index, 'Predecessors', e.name);
    }

    // add mother (Nothing for now, can handle on UI or special case init area)

    // add father, may already been created, e.g. Ibrahim->Ismail/Issac
    if (ft.trValFather != null) {
      addEdge(ft.trValFather!.index, 'Father', ft.trValFather!.name);
    }

    // Add Prophet (Handles case of Adam fine)
    addEdge(ft.relicId, 'Prophet', ft.trKeyEndTagLabel);

    // add daughters to Prophet node
    for (Enum e in ft.trValDaughters ?? []) {
      addEdge(e.index, 'Daughters', e.name, updateLastNode: false);
    }
    // add sons to Prophet node
    for (Enum e in ft.trValSons ?? []) {
      addEdge(e.index, 'Sons', e.name, updateLastNode: false);
    }
  }
}

// TODO: https://www.quora.com/Is-it-true-that-all-the-Christian-prophets-are-well-quoted-in-The-Holy-Quran
// Idris: Idris has been identified by most Islamic scholars as the same person as Enoch in Genesis. This is mostly because the Qur’an identifies him as truthful: “And mention in the Book, Idrees. Indeed, he was a man of truth and a prophet.” (19:56) and patient: “And [mention] Ishmael and Idrees and Dhul-Kifl; all were of the patient.” (21:85) Although, some people debate that Idris was actually the same person as Hermes Trismegtus.
//
// Hud: Hud has sometimes been identified with Eber in Genesis (even though Eber is usually known as Abir in the family tree of prophets), but there is little evidence supporting this. The story of Hud is not equated with any story in the Bible.
//
// Saleh: Similar to Hud, Saleh’s story is not equated with any story in the Bible, but he is sometimes associated with Salah in Genesis, even though in Genesis, Salah is the father of Eber, who is associated with Hud, who came before Saleh, and in the family tree of prophets, the father of Abir is Shalikh, who is a different person from Saleh, and Hud and Saleh are actually fifth cousins, twice removed, not father and son, and that they are descended from Aram, not Arfachshad, and that there is little evidence supporting this.
//
// Shu’ayb: Shu’ayb is sometimes identified with the Biblical Jethro, the father-in-law of Moses. This is because of a single verse in the Qur’an which states: “[Shu’ayb] said [to Moses]: “Indeed, I wish to wed you to one of these, my two daughters, on the condition that you serve me for eight years; but if you complete ten, it will be [as a favor] from you. And I do not wish to put you in difficulty. You will find me, if Allah wills, from the righteous.”” (28:27). For this reason, it is believed that Shu’ayb was the father-in-law of Moses, and thus, the same person as Jethro.
//
// Dhul-Kifl: Not much is known about Dhul-Kifl, and for this reason, it is impossible to identify a story in the Bible with him. However, the name “Dhu al-Kifl”, for various reasons, has sometimes been identified with “Ezekiel”, and therefore, some scholars believe that Dhul-Kifl and Ezekiel were the same person.

// TODO: https://sorularlaislamiyet.com/peygamberlerin-soy-agaci-ve-gelis-sirasi-hakkinda-bilgi-verir-misiniz-0
// 19. Yuşa: b. Nûn b. Ephraim-Efrâim b. Yûsuf
// 18. Hizir: Rivayete göre: Hizir ın soyu: Belya (or İlya) b. Milkân b. Falığ b. Âbir b. Salih b. Erfahşed b. Sâm b.Nuh olup babası, büyük bir kraldı. Kendisinin; Âdem ın oğlu or Ays b. Ishaq ın oğullarından olduğu or Ibrahim a iman ve Babil'den, Onunla birlikte hicret edenlerden birisinin ya da Farslı bir babanın oğlu olduğu, kral Efridun ve Ibrahim devrinde yaşadığı, büyük Zülkarneyn'e Kılavuzluk ettiği, İsrailoğulları krallarından İbn. Emus'un zamanında İsrailoğullarına peygamber olarak gönderildiği, halen, sağ olup her yıl, Hacc Mevsiminde Ilyas la buluştukları da rivayet edilir.
// 18. Khidr: According to the rumor: Khidr 's lineage: Belya (or İlya) b. Milkan b. Falığ b. Âbir b. Salih b. Erfahşed b. Sam b. Nuh and his father was a great king. himself; Son of Adem or Ays b. He was one of the sons of Ishaq, or Abraham was from faith and Babylon, one of those who migrated with him, or he was the son of a Persian father, lived during the reign of King Efridun and Ibrahim, and guided the great Dhul-Qarnayn, one of the kings of the Israelites, Ibn. It is also rumored that Emus was sent as a prophet to the Children of Israel in his time, and that he is still alive and meets with Ilyas every year during the Hajj Season.
// 20. Kalib b. Yufena: Kalib b. Yufena b. Bariz (Fariz) b. Yehuza b. Yaqub b. Ishaq b. Ibrahim Kalib b. Yüfenna was the husband of Mary, the sister of Moses, or the son-in-law of Moses.
// 20. Kâlib b. Yüfena: Kâlib b. Yüfena b. Bariz (Fariz) b. Yehuza b. Yâkub b. Ishaq b. İbrahim dır. Kâlib b. Yüfenna, Mûsâ ın kız kardeşi Meryem'in kocası or Mûsâ ın damadı idi.
// 21. Hızkil: Hızkil b. He is Nuri. After Hizkil 's mother became old and infertile, she wished for a son from Almighty Allah and Hizkil was bestowed. For this reason, he was called Hızkil (İbnül'acûz = Son of Husband).
// 21. Hızkıl: Hızkıl b. Nûridir. Hızkıl ın annesi yaşlanıp çocuk doğurmaz hale geldikten sonra, Yüce Allâh'dan bir oğul dilemiş ve Hızkıl, ihsan olunmuştur. Bunun için, Hızkıl (İbnül'acûz = Koca Karının Oğlu) diye anılmıştır.
// 25. Şemûyel: Şemûyel b. Bali b. Alkama b. Yerham b. Yehu b. Tehu b. It is Savf. Shamuyel was from the sons of Israel and from the offspring of Harun. Shemuyel 's mother, Hanne, was a member of the Dynasty of Lâvi b.Yaqub
// 25. Şemûyel: Şemûyel b. Bali b. Alkama b. Yerham b. Yehu b. Tehu b. Savf'dır. Şemuyel, İsrailoğullarından ve Hârûn ın zürriyetindendi. Şemuyel ın annesi Hanne olup Lâvi b.Yâkub ın Hanedanına mensuptu.
// 28. Luqman: Luqman b. Saran b. Murid b. Defend. Luqman; He lived in the time of David. Itself; He belonged to the Egyptian Nub tribe. He was from the people of Midian and Eyke. While he was the slave of a man from the Children of Israel, he was freed by him and he was also given property.
// 28. Luqman: Luqman b. Sâran b. Mürîd b. Savun. Luqman; Dâvûd ın devrinde yaşamıştır. Kendisi; Mısır Nub kabilesine mensubtu. Medyen ve Eyke halkındandı. İsrailoğullarından bir adamın kölesi iken, onun tarafından âzâd edilmiş ve kendisine ayrıca mal da, verilmişti.
// 29. Şâ'yâ: Şâ'yâ b. Emus or Emsıya'dır.
// 29. Şâ'yâ: Şâ'yâ b. It is Emus or Emsıya.
// 30. Irmiya: Irmiya b. Hılkıya; Lavi b. Harun b. He was a descendant of Imran.
// 30. İrmiya: İrmiya b. Hılkıya; Lavi b. Yâkub 'ın soyundan gelen Hârûn b. İmran ın soyundandı.
// 31. Daniel: Daniel b. Hızkil'ül 'asgar is one of the sons of the Prophet, Suleyman b. He was a descendant of David s.
// 31. Danyal: Danyal b. Hızkıl'ül 'asgar, Peygamber oğullarından, Suleyman b. Dâvud ların soyundandı.
// 32. Uzeyr: Uzeyr b. Cerve Hârûn ın zürriyetindendir.
// 32. Uzeyr: Uzeyr b. Cerve Harun is from the offspring of
// 33. Dhu al-Qarnayn: There are many and contradictory rumors about Dhul-Qarnayn's name, lineage and whether he is a Prophet or not. He, Sa'b b. As it is said to be Abdullah'ülkahtanî, it is also claimed that his father was from the Himyarites.
// 33. Dhu al-Qarnayn: Zülkarneyn ın ismi, soyu ve Peygamber olup olmadığı... Hakkında birçok ve çelişkili rivayetler bulunmaktadır. Kendisinin, Sa'b b. Abdullah'ülkahtânî olduğu söylendiği gibi, babasının Hımyerîlerden olduğu da ileri sürülmektedir.
// About Dhul-Qarnayn: "He was both a Nabi and a Rasul." As there are those who say, "No! He was a Nabi who was not a Rasul. His being a Nabi who was not a Rasul is, insha'Allah, Sahih!" There are those who say. According to Ali, Dhul-Qarnayn : He was neither a prophet nor a king. However, he was a righteous servant of Allah, who loved Allah and Allah loved him.
// Zülkarneyn hakkında: "Hem Nebi idi, hem Resul idi." diyenler olduğu gibi, "Hayır! O, Resul olmayan bir Nebi idi. Resul olmayan bir Nebî oluşu, inşâallâh, Sahih'dir!" diyenler de vardır. Ali'ye göre, Zülkarneyn : Ne bir Nebi, ne de, bir kraldı. Fakat, Allan'ın Salih bir kulu idi ki, o, Allâhı, sevmiş, Allah da, onu, sevmişti.
// Ibn. Habîb also gave the names of the Hımyer kings to Hisham b. While transferring from Kelbî to his book, Sa'b b. Karîn b. After noting that Hemal was mentioned as Dhul-Qarnayn in his Book, the king explains that Zayd b.
// İbn. Habîb de Hımyer krallarının isimlerini Hişam b. Kelbî'den sırasıyla kitabına geçirirken, Sa'b b. Karîn b. Hemal'ı, -Yüce Allah'ın, Kitabında- Zülkarneyn diye anmış olduğunu kayd ettikten sonra, kral Zeyd b.Hemal'ı kayd edip ona da Yüce Allah'ın Tübba' adını vermiş olduğunu açıklar.
