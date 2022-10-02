import 'package:flutter/src/widgets/framework.dart';
import 'package:get/utils.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/family_tree/family_tree.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

const String _ = ' '; // space/gap

/// Peace be upon all (SAW) the Prophets mentioned in the code.
class Prophet extends FamilyTree {
  Prophet({
    // Event data:
    required String tvEra,
    required double startMs,
    required double endMs,

    // Relic data not needed to pass in, it is auto-generated in super() call
    required Enum e,

    // Required Fam data:
    required List<PF> predecessors,
    PF? dad,
    PF? mom,
    List<PF>? spouses,
    List<PF>? daughters,
    List<PF>? sons,
    List<PF>? relatives,
    List<RELATIVE>? relativesTypes,
    List<PF>? successors, // Next Prophet(s) in lineage, for collapsed list
    PF? successor, // Next Prophet in prophethood timeline

    // Required prophet data:
    required this.tvSentTo,
    required this.quranMentionCount,
    required this.aqNabi,
    this.aqRasul,
    this.tvKitab,
    this.aqUluAlAzmList,
    this.aqInDescriptionLists, // TODO complete for all Prophets
    this.tvLocationBirth,
    this.tvLocationDeath,
    this.tvTomb,
  }) : super(
          // Event data:
          tvEra: tvEra,
          startMs: startMs,
          endMs: endMs,
          // Relic data:
          relicType: RELIC_TYPE.Anbiya,
          e: e,
          // Required Fam data:
          predecessors: predecessors,
          // Optional Fam data:
          dad: dad,
          mom: mom,
          spouses: spouses,
          daughters: daughters,
          sons: sons,
          relatives: relatives,
          relativesTypes: relativesTypes,
          successors: successors,
          successor: successor,
        );
  // Required prophet data:
  final String tvSentTo; // nation the prophet was sent to:
  final int quranMentionCount;
  final AQ aqNabi; // Prophet (nabī) نَبِيّ
  // Optional prophet data:
  final AQ? aqRasul; // Messenger (rasūl) رَسُول
  final String? tvKitab;
  final List<AQ>? aqUluAlAzmList; // Archprophet (ʾUlu Al-'Azm)
  final List<List<AQ>>?
      aqInDescriptionLists; // Quran verses to put in description
  final String? tvLocationBirth;
  final String? tvLocationDeath;
  final String? tvTomb;

  bool isRasul() => aqRasul != null;
  bool isUluAlAzm() => aqUluAlAzmList != null && aqUluAlAzmList!.isNotEmpty;

  @override
  RelicAsset getRelicAsset({width = 200.0, height = 200.0, scale = 1.0}) =>
      RelicAsset(
        'assets/images/anbiya/${e.name}.png',
        width: width,
        height: height,
        scale: scale,
      );

  @override
  // TODO: implement widget
  Widget get widget => throw UnimplementedError();
}

final List<Prophet> relicsProphet = [
  Prophet(
    // Event data:
    tvEra: 'Intelligent Life'.tr,
    startMs: -340000,
    endMs: -339050,
    // Relic data:
    e: PF.Adam,
    // Fam data:
    predecessors: [], // must be blank, root of the tree
    dad: null, // must leave blank for tree logic
    mom: null, // must leave blank for tree logic
    spouses: [PF.Hawwa],
    sons: [PF.Habel, PF.Qabel, PF.Anaq, PF.Sheth],
    daughters: null, // TODO
    relatives: null,
    successors: [PF.Idris],
    successor: PF.Sheth,
    // Required prophet data:
    tvSentTo: 'p.Earth from Heaven'.tr + _ + cns('(4:1)'),
    quranMentionCount: 25,
    aqNabi: AQ(2, 31),
    // Optional prophet data:
    aqRasul: AQ(2, 31),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: a('a.Jennah'),
    tvLocationDeath: null,
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: 'Birth of Humans'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Idris,
    // Fam data:
    predecessors: [
//    PF.Adam,
      PF.Sheth,
      PF.Anwas,
      PF.Qinan,
      PF.Mahlail,
    ],
    dad: PF.Yarid,
    mom: null,
    spouses: null,
    sons: [PF.Matulshalkh],
    relatives: null,
    successors: [PF.Nuh],
    successor: PF.Nuh,
    // Required prophet data:
    tvSentTo: a('a.Babylon'),
    quranMentionCount: 2,
    aqNabi: AQ(19, 56),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [
      [AQ(19, 56, end: 57), AQ(21, 85, end: 86)],
    ],
    tvLocationBirth: a('a.Babylon'),
    tvLocationDeath: 'p.Sixth Heaven'.tr,
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: 'Great Flood'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Nuh,
    // Fam data:
    predecessors: [
//    PF.Idris,
      PF.Matulshalkh,
    ],
    dad: PF.Lamik,
    mom: null,
    spouses: [PF.Naamah],
    daughters: null, // TODO
    sons: [PF.Ham, PF.Yam, PF.Yafith, PF.Sam],
    relatives: null,
    successors: [PF.Hud, PF.Salih, PF.Ibrahim, PF.Lut],
    successor: PF.Hud,
    // Required prophet data:
    tvSentTo: 'p.The people of_'.tr + a('a.Nuh') + _ + cns('(26:105)'),
    quranMentionCount: 43,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: AQ(25, 107),
    tvKitab: null,
    aqUluAlAzmList: [AQ(46, 35), AQ(33, 7)],
    aqInDescriptionLists: [
      [
        AQ(4, 163, tkNoteBefore: 'As one of the first messengers'),
        AQ(6, 84),
        AQ(11, 25),
        AQ(26, 107),
        AQ(29, 14),
        AQ(37, 75),
        AQ(57, 26),
        AQ(71, 1, end: 2),
        AQ(71, 5),
      ],
      [
        AQ(4, 163, tkNoteBefore: "Noah's preaching"),
        AQ(7, 59),
        AQ(7, 61, end: 64),
        AQ(10, 71, end: 72),
        AQ(11, 25, end: 26),
        AQ(11, 28, end: 31),
        AQ(11, 42),
        AQ(23, 23),
        AQ(26, 105, end: 106),
        AQ(26, 108),
        AQ(26, 110),
        AQ(71, 1, end: 3),
        AQ(71, 8, end: 20),
      ],
      [
        AQ(7, 60, end: 61, tkNoteBefore: 'Challenges for Noah'),
        AQ(10, 71),
        AQ(11, 27),
        AQ(11, 32),
        AQ(14, 9),
        AQ(23, 24, end: 26),
        AQ(25, 37),
        AQ(26, 105),
        AQ(26, 111, end: 113),
        AQ(26, 116, end: 118),
        AQ(38, 12),
        AQ(40, 5),
        AQ(50, 12),
        AQ(53, 52),
        AQ(54, 9, end: 10),
        AQ(66, 10),
        AQ(71, 6, end: 7),
        AQ(71, 21, end: 24),
        AQ(71, 26, end: 27),
      ],
      [
        AQ(17, 3, tkNoteBefore: 'The Thankful Noah'),
      ],
      [
        AQ(21, 76, end: 77, tkNoteBefore: "Noah's wishes granted"),
        AQ(26, 119),
        AQ(37, 75),
        AQ(54, 11, end: 12),
      ],
      [
        AQ(7, 64, tkNoteBefore: "God destroyed Noah's people"),
        AQ(9, 70),
        AQ(10, 73),
        AQ(11, 37),
        AQ(11, 43, end: 44),
        AQ(11, 89),
        AQ(23, 27),
        AQ(25, 37),
        AQ(26, 120),
        AQ(29, 14),
        AQ(37, 82),
        AQ(40, 31),
        AQ(51, 46),
        AQ(53, 52),
        AQ(54, 11, end: 12),
        AQ(71, 25),
      ],
      [
        AQ(7, 64, tkNoteBefore: 'Noah was saved on the Ark'),
        AQ(10, 73),
        AQ(11, 37, end: 38),
        AQ(11, 40, end: 44),
        AQ(11, 48),
        AQ(23, 27, end: 29),
        AQ(26, 119),
        AQ(29, 15),
        AQ(37, 76),
        AQ(54, 13, end: 15),
        AQ(69, 11),
      ],
      [
        AQ(17, 3, tkNoteBefore: 'Appraisal for Noah'),
        AQ(37, 78, end: 81),
        AQ(66, 10),
      ],
    ],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Hud,
    // Fam data:
    predecessors: [
//    PF.Nuh,
      PF.Sam,
      PF.Irem,
      PF.Aush,
      PF.Ad,
      PF.Khalud,
      PF.Raya,
    ],
    dad: PF.Abdullah,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: null,
    successor: PF.Salih,
    // Required prophet data:
    tvSentTo: a('a.Ad') + _ + a('a.Tribe') + _ + cns('(7:65)'),
    quranMentionCount: 7,
    aqNabi: AQ(26, 125),
    // Optional prophet data:
    aqRasul: AQ(26, 125),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb:
        'p.Possibly in Qabr Nabi Hud, Hadhramaut, Yemen; Near the Zamzam well; south wall of the Umayyad Mosque, Damascus, Syria.'
            .tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Salih,
    // Fam data:
    predecessors: [
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
    dad: PF.Abir_Ubayd,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    relativesTypes: null,
    successors: null,
    successor: PF.Lut,
    // Required prophet data:
    tvSentTo: a('a.Thamud') + _ + a('a.Tribe') + _ + cns('(7:73)'),
    quranMentionCount: 9,
    aqNabi: AQ(26, 143),
    // Optional prophet data:
    aqRasul: AQ(26, 143),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [
      [
        AQ(7, 73, end: 79),
        AQ(11, 61, end: 69),
        AQ(26, 141, end: 158),
        AQ(15, 80, end: 84),
        AQ(7, 74),
        AQ(7, 75),
        AQ(7, 73),
        AQ(7, 77),
        AQ(11, 65),
        AQ(26, 157),
        AQ(7, 78),
        AQ(7, 79),
        AQ(27, 48),
        AQ(27, 49),
        AQ(11, 65),
      ]
    ],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: "p.Possibly in Mada'in Salih or Hasik, Oman.".tr, // TODO
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Ibrahim,
    // Fam data:
    predecessors: [
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
    dad: PF.Azar_Taruh,
    mom: PF.Mahalath,
    spouses: [PF.Sarah, PF.Hajar],
    daughters: null,
    sons: [PF.Madyan, PF.Ismail, PF.Ishaq],
    relatives: [PF.Lut],
    relativesTypes: [RELATIVE.Nephew],
    successors: [PF.Shuayb, PF.Ismail, PF.Ishaq],
    successor: PF.Ismail,
    // Required prophet data:
    tvSentTo: a('a.Babylon') +
        ',_'.tr +
        'The people of_'.tr +
        a('a.Al-Eiraq') + // Iraq العراق
        '_and_'.tr +
        a('a.Suria') + // Syria سوريا
        _ +
        cns('(22:43)'),
    quranMentionCount: 69,
    aqNabi: AQ(19, 41),
    // Optional prophet data:
    aqRasul: AQ(9, 70),
    tvKitab: 'p.Scrolls of_'.tr + a('a.Ibrahim') + _ + cns('(87:19)'),
    // qvsUluAlAzm: [QV(2, 124)],
    aqInDescriptionLists: [
      [
        AQ(2, 124, tkNoteBefore: "Ibrahim's attributes"),
        AQ(11, 75, end: 123),
        AQ(16, 120),
      ],
      [
        AQ(2, 130, tkNoteBefore: "Ibrahim's religion"),
        AQ(4, 125),
        AQ(6, 83, end: 84),
        AQ(6, 161),
        AQ(9, 114),
        AQ(11, 74),
        AQ(12, 6),
        AQ(16, 120),
        AQ(19, 41),
        AQ(19, 47),
        AQ(21, 51),
        AQ(22, 78),
        AQ(26, 83, end: 85),
        AQ(29, 27),
        AQ(37, 84),
        AQ(37, 88),
        AQ(37, 104),
        AQ(37, 109, end: 111),
        AQ(37, 113),
        AQ(38, 45, end: 47),
        AQ(43, 28),
        AQ(53, 37),
        AQ(57, 26),
        AQ(60, 4),
      ],
      [
        AQ(2, 124, tkNoteBefore: 'God tried Ibrahim'),
        AQ(37, 102),
      ],
      [
        AQ(2, 130, end: 231, tkNoteBefore: "Ibrahim's preaching"),
        AQ(2, 135, end: 136),
        AQ(2, 140),
        AQ(3, 67, end: 68),
        AQ(3, 84),
        AQ(3, 95),
        AQ(4, 125),
        AQ(4, 163),
        AQ(6, 74),
        AQ(6, 76, end: 81),
        AQ(6, 83),
        AQ(6, 161),
        AQ(14, 35, end: 37),
        AQ(14, 40),
        AQ(21, 52),
        AQ(21, 54),
        AQ(21, 56, end: 57),
        AQ(21, 67),
        AQ(22, 26),
        AQ(26, 69, end: 73),
        AQ(26, 75),
        AQ(26, 78, end: 80),
        AQ(26, 87),
        AQ(29, 16, end: 17),
        AQ(29, 25),
        AQ(37, 83),
        AQ(37, 85, end: 87),
        AQ(37, 89),
        AQ(37, 91),
        AQ(37, 92),
        AQ(37, 93),
        AQ(37, 94, end: 96),
        AQ(43, 26, end: 28),
        AQ(60, 4),
      ],
      [
        AQ(2, 127, tkNoteBefore: 'Development of the Kaaba'),
      ],
      [
        AQ(2, 128, tkNoteBefore: "Ibrahim's pilgrimage"),
        AQ(22, 27),
      ],
      [
        AQ(4, 125, tkNoteBefore: "Ibrahim as God's friend"),
      ],
      [
        AQ(9, 70, tkNoteBefore: "Punishment to Ibrahim's people"),
      ],
      [
        AQ(21, 71, tkNoteBefore: 'Moving to Shaam'),
        AQ(29, 26),
      ],
      [
        AQ(14, 37, tkNoteBefore: 'Ibrahim, Hagar, and Ismael'),
        AQ(37, 101),
      ],
      [
        AQ(2, 260, tkNoteBefore: 'Dreaming of resurrecting a dead body'),
      ],
      [
        AQ(2, 258, tkNoteBefore: 'Arguing with Nimrod'),
      ],
      [
        AQ(6, 74, tkNoteBefore: 'Ibrahim preached to his father'),
        AQ(19, 42, end: 45),
        AQ(21, 52),
        AQ(26, 70),
        AQ(37, 85),
        AQ(43, 26),
      ],
      [
        AQ(6, 74, tkNoteBefore: "His father's idolatry"),
        AQ(26, 71),
      ],
      [
        AQ(14, 41, tkNoteBefore: 'Ibrahim asked forgiveness for his father'),
        AQ(19, 47),
        AQ(60, 4),
      ],
      [
        AQ(21, 62, end: 63, tkNoteBefore: 'Arguing with the people'),
        AQ(21, 65, end: 66),
      ],
      [
        AQ(19, 48, end: 49, tkNoteBefore: 'Ibrahim moved away from the people'),
        AQ(29, 26),
        AQ(37, 99),
        AQ(43, 26),
        AQ(60, 4),
      ],
      [
        AQ(21, 57, end: 58, tkNoteBefore: "Ibrahim's warnings for the idols"),
        AQ(21, 60),
        AQ(37, 93),
      ],
      [
        AQ(21, 68, tkNoteBefore: 'Thrown into the fire'),
        AQ(29, 24),
        AQ(37, 97),
      ],
      [
        AQ(21, 69, end: 70, tkNoteBefore: 'Saved from the fire'),
        AQ(29, 24),
        AQ(37, 98),
      ],
      [
        AQ(6, 84, tkNoteBefore: 'Good news about Isaac and Jacob'),
        AQ(11, 69),
        AQ(11, 71, end: 72),
        AQ(14, 39),
        AQ(15, 53),
        AQ(15, 54, end: 55),
        AQ(21, 72),
        AQ(29, 27),
        AQ(37, 112),
        AQ(51, 28, end: 30),
      ],
      [
        AQ(37, 102, end: 103, tkNoteBefore: "Dreaming of his son's sacrifice"),
      ],
    ],
    tvLocationBirth: 'p.Ur al-Chaldees, Bilād ar-Rāfidayn'.tr,
    tvLocationDeath: 'a.Al-Khalil'.tr + // Hebron الخليل
        ',_'.tr +
        a('a.Bilad al-Sham'), // Greater Syria لبِلَاد الشَّام
    tvTomb: 'p.Ibrahimi Mosque, Hebron'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Lut,
    // Fam data:
    predecessors: [
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
    dad: PF.Haran,
    mom: null,
    spouses: null,
    // TODO Possibly had 2+ daughters, but the daughters referenced in the
    //  Quran could also mean the women of his nation:
    daughters: null,
    sons: null,
    relatives: [PF.Ibrahim, PF.Ayyub, PF.Shuayb],
    relativesTypes: [RELATIVE.Uncle, RELATIVE.Grandson, RELATIVE.Grandson],
    successors: null,
    successor: PF.Ibrahim,
    // Required prophet data:
    tvSentTo: a('a.Saddoom') + // سدوم Sodom
        '_and_'.tr +
        a("a.'Amoorah") + //  عمورة Gomorrah
        _ +
        cns('(7:80)'), // TODO arabee
    quranMentionCount: 27,
    aqNabi: AQ(6, 86),
    // Optional prophet data:
    aqRasul: AQ(37, 133),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: a(
        "a.Bani Na'im"), //  بني نعيم  Palestinian town in the southern West Bank located 8 kilometers (5.0 mi) east of Hebron.
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Ibrahim'),
    startMs: 0, //-1800, TODO must be younger than Yusuf!
    endMs: 0, //-1664,
    // Relic data:
    e: PF.Ismail,
    // Fam data:
    predecessors: [], // must be blank, Father->Son used to build tree
    dad: PF.Ibrahim,
    mom: PF.Hajar,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Ishaq],
    relativesTypes: [RELATIVE.HalfBrother],
    successors: [PF.Muhammad],
    successor: PF.Ishaq,
    // Required prophet data:
    tvSentTo: 'p.Pre-Islamic_' +
        a('a.Al-Arabiyyah') +
        ',_'.tr +
        a('a.Makkah al-Mukarramah'),
    quranMentionCount: 12,
    aqNabi: AQ(19, 54),
    // Optional prophet data:
    aqRasul: AQ(19, 54),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'Canaan'.tr,
    tvLocationDeath:
        a('a.Makkah al-Mukarramah'), // Mecca مكة المكرمة 'Makkah the Noble',
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Ishaq,
    // Fam data:
    predecessors: [],
    dad: PF.Ibrahim,
    mom: PF.Sarah,
    spouses: [PF.Rafeqa],
    daughters: null,
    sons: [PF.Yaqub, PF.Isu],
    relatives: [PF.Ismail],
    relativesTypes: [RELATIVE.HalfBrother],
    successors: [PF.Yaqub, PF.Ayyub],
    successor: PF.Yaqub,
    // Required prophet data:
    tvSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'Canaan'.tr,
    quranMentionCount: 17,
    aqNabi: AQ(19, 49),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Old Egyptian Kingdom'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Yaqub,
    // Fam data:
    predecessors: [],
    dad: PF.Ishaq,
    mom: PF.Rafeqa,
    spouses: [PF.Rahil_Bint_Leban, PF.Lia],
    daughters: null,
    sons: [
      PF.Yusuf,
      PF.Bunyamin,
      PF.Lawi,
      PF.Yahudzha,
      // TODO And all 12 tribe founders
    ],
    relatives: null,
    successors: [PF.Yusuf, PF.Yunus, PF.Musa, PF.Harun, PF.Dawud],
    successor: PF.Yusuf,
    // Required prophet data:
    tvSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'Canaan'.tr,
    quranMentionCount: 16,
    aqNabi: AQ(19, 49),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Ancient Egypt',
    startMs: -2400,
    endMs: -2400,
    // Relic data:
    e: PF.Yusuf,
    // Fam data:
    predecessors: [],
    dad: PF.Yaqub,
    mom: PF.Rahil_Bint_Leban,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Bunyamin], // TODO 10 more!
    relativesTypes: [RELATIVE.Brother], // TODO 10 more!
    successors: [PF.Alyasa],
    successor: null, // TODO
    // Required prophet data:
    tvSentTo: 'p.Ancient Kingdom of_'.tr + a('a.Misr'), // Egypt
    quranMentionCount: 27,
    aqNabi: AQ(4, 89),
    // Optional prophet data:
    aqRasul: AQ(40, 34),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: null,
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Ayyub,
    // Fam data:
    predecessors: [
//    PF.Ishaq,
      PF.Isu,
      PF.Rimil,
    ],
    dad: PF.Amose,
    mom: PF.DaughterOfLut,
    spouses: null,
    daughters: null,
    sons: [PF.DhulKifl],
    relatives: [PF.Lut],
    relativesTypes: [RELATIVE.Grandfather],
    successors: [PF.DhulKifl],
    successor: PF.DhulKifl,
    // Required prophet data:
    tvSentTo: a('a.Edom'), // TODO Arabee version
    quranMentionCount: 4,
    aqNabi: AQ(4, 89),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Possibly in Al-Qarah Mountains in southern Oman'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr, // TODO
    startMs: 0, // TODO Buddha: 6th or 5th century BCE
    endMs: 0,
    // Relic data:
    e: PF.DhulKifl,
    // Fam data:
    predecessors: [],
    dad: PF.Ayyub,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: null,
    successor: null,
    // Required prophet data:
    // TODO Kifl or Kapilavastu in the northern Indian subcontinent:
    tvSentTo: 'p.Possibly Babylon or Indain subcontinent'.tr,
    quranMentionCount: 2,
    aqNabi: AQ(21, 85, end: 86),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Makam Dağı in Ergani province of Diyarbakir'.tr +
        ',_'.tr +
        a('a.Turkiye'),
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr,
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Shuayb,
    // Fam data:
    predecessors: [
//    PF.Ibrahim,
      PF.Madyan,
      PF.Yashjar,
    ],
    dad: PF.Mikeel,
    mom: PF.DaughterOfLut,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Lut],
    relativesTypes: [RELATIVE.Grandfather],
    successors: null,
    successor: PF.Musa,
    // Required prophet data:
    tvSentTo: a('a.Madyan') + // Midian
        _ +
        cns('(7:85)'),
    quranMentionCount: 9,
    aqNabi: AQ(26, 178),
    // Optional prophet data:
    aqRasul: AQ(26, 178),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [
      [
        AQ(7, 85, end: 91),
        AQ(15, 78, end: 79),
        AQ(26, 176, end: 189),
        AQ(38, 13, end: 15),
        AQ(50, 12, end: 14),
        AQ(7, 85),
        AQ(11, 61, end: 94),
        AQ(23, 20),
      ],
    ],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb:
        'p.Possibly in Wadi Shuʿayb, Jordan, Guriyeh, Shushtar, Iran or Hittin in the Galilee'
            .tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Ancient Egypt',
    startMs: -1303,
    endMs: -1200,
    // Relic data:
    e: PF.Harun,
    // Fam data:
    predecessors: [
//    PF.Yaqub,
      PF.Lawi,
      PF.Kehath_Yashur,
    ],
    dad: PF.Imran,
    mom: PF.Yukabid,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Musa, PF.Miriam],
    relativesTypes: [RELATIVE.Brother, RELATIVE.Sister],
    successors: [PF.Ilyas],
    successor: PF.Dawud,
    // Required prophet data:
    tvSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 20,
    aqNabi: AQ(19, 53),
    // Optional prophet data:
    aqRasul: AQ(20, 47),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Possibly in Jabal Harun, Jordan or in Sinai'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Ancient Egypt',
    startMs: -1300,
    endMs: -1200,
    // Relic data:
    e: PF.Musa,
    // Fam data:
    predecessors: [
//    PF.Yaqub,
//    PF.Lawi,
      PF.Kehath_Yashur,
    ],
    dad: PF.Imran,
    mom: PF.Yukabid,
    spouses: [PF.Saffurah],
    daughters: null,
    sons: null,
    relatives: [PF.Harun, PF.Miriam, PF.Asiya],
    relativesTypes: [
      RELATIVE.Brother,
      RELATIVE.Sister,
      RELATIVE.FosterMother,
    ],
    successors: null,
    successor: PF.Harun,
    // Required prophet data:
    tvSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 136,
    aqNabi: AQ(20, 47),
    // Optional prophet data:
    aqRasul: AQ(20, 47),
    tvKitab: 'p.Ten Commandments, Tawrah (Torah); Scrolls of Musa (53:36)',
    aqUluAlAzmList: [AQ(46, 35), AQ(33, 7)],
    aqInDescriptionLists: [
      [
        AQ(2, 136, tkNoteBefore: 'Appraisals of Musa'),
        AQ(4, 164),
        AQ(6, 84),
        AQ(6, 154),
        AQ(7, 134),
        AQ(7, 142),
        AQ(19, 51),
        AQ(20, 9),
        AQ(20, 13),
        AQ(20, 36),
        AQ(20, 41),
        AQ(25, 35),
        AQ(26, 1),
        AQ(26, 21),
        AQ(27, 8),
        AQ(28, 7),
        AQ(28, 14),
        AQ(33, 69),
        AQ(37, 114),
        AQ(37, 118),
        AQ(44, 17),
      ],
      [
        AQ(7, 150, tkNoteBefore: "Musa' attributes"),
        AQ(20, 94),
        AQ(28, 15),
        AQ(28, 19),
        AQ(28, 26),
      ],
      [
        AQ(7, 144, tkNoteBefore: "Musa' prophecy"),
        AQ(20, 10, end: 24),
        AQ(26, 10),
        AQ(26, 21),
        AQ(27, 7, end: 12),
        AQ(28, 2, end: 35),
        AQ(28, 46),
        AQ(79, 15, end: 19),
      ],
      [
        AQ(2, 253, tkNoteBefore: 'The prophet whom God spoke to'),
        AQ(4, 164),
        AQ(7, 143, end: 144),
        AQ(19, 52),
        AQ(11, 24),
        AQ(20, 83, end: 84),
        AQ(26, 10, end: 16),
        AQ(27, 8, end: 11),
        AQ(28, 30, end: 35),
        AQ(28, 46),
        AQ(79, 16, end: 19),
      ],
      [
        AQ(2, 41, tkNoteBefore: 'The Torah', end: 44),
        AQ(2, 53),
        AQ(2, 87),
        AQ(3, 3),
        AQ(3, 48),
        AQ(3, 50),
        AQ(3, 65),
        AQ(3, 93),
        AQ(5, 43, end: 46),
        AQ(5, 66, end: 68),
        AQ(5, 110),
        AQ(6, 91),
        AQ(6, 154, end: 157),
        AQ(7, 145),
        AQ(7, 154, end: 157),
        AQ(9, 111),
        AQ(11, 110),
        AQ(17, 2),
        AQ(21, 48),
        AQ(23, 49),
        AQ(25, 3),
        AQ(28, 43),
        AQ(32, 23),
        AQ(37, 117),
        AQ(40, 53),
        AQ(41, 45),
        AQ(46, 12),
        AQ(48, 29),
        AQ(53, 36),
        AQ(61, 6),
        AQ(62, 5),
        AQ(87, 19),
      ],
      [
        AQ(20, 12, tkNoteBefore: 'The valley'),
        AQ(20, 20),
        AQ(28, 30),
        AQ(79, 16),
      ],
      [
        AQ(2, 56, tkNoteBefore: "Musa' miracle"),
        AQ(2, 60),
        AQ(2, 92),
        AQ(2, 211),
        AQ(7, 107, end: 108),
        AQ(7, 117, end: 120),
        AQ(7, 160),
        AQ(11, 96),
        AQ(17, 101),
        AQ(20, 17, end: 22),
        AQ(20, 69),
        AQ(20, 77),
        AQ(26, 30, end: 33),
        AQ(26, 45),
        AQ(26, 63),
        AQ(27, 10, end: 12),
        AQ(27, 12),
        AQ(28, 31, end: 32),
        AQ(40, 23),
        AQ(40, 28),
        AQ(43, 46),
        AQ(44, 19),
        AQ(44, 33),
        AQ(51, 38),
        AQ(79, 20),
      ],
      [
        AQ(20, 38,
            tkNoteBefore: "Musa' life inside the Pharoah's palace", end: 39),
        AQ(26, 18),
        AQ(28, 8, end: 12),
      ],
      [
        AQ(20, 4, tkNoteBefore: 'Returned to his mother'),
        AQ(28, 12, end: 13),
      ],
      [
        AQ(20, 38, tkNoteBefore: "God's revelation to Musa' mother", end: 39),
        AQ(28, 7, end: 10),
      ],
      [
        AQ(7, 103, tkNoteBefore: "Musa' preaching", end: 129),
        AQ(10, 84),
        AQ(20, 24),
        AQ(20, 42, end: 51),
        AQ(23, 45),
        AQ(26, 10, end: 22),
        AQ(28, 3),
        AQ(43, 46),
        AQ(44, 18),
        AQ(51, 38),
        AQ(73, 15, end: 17),
      ],
      [
        AQ(20, 58, tkNoteBefore: 'Musa met the Pharaoh', end: 59),
        AQ(20, 64, end: 66),
        AQ(26, 38, end: 44),
      ],
      [
        AQ(7, 111, tkNoteBefore: "The Pharaoh's magicians", end: 116),
        AQ(10, 79, end: 80),
        AQ(20, 60, end: 64),
        AQ(26, 37, end: 44),
      ],
      [
        AQ(7, 115, tkNoteBefore: 'Musa vs. the magicians', end: 122),
        AQ(10, 80, end: 81),
        AQ(20, 61, end: 70),
        AQ(26, 43, end: 48),
      ],
      [
        AQ(20, 62, tkNoteBefore: 'Dispute among the magicians'),
        AQ(26, 44, end: 47),
      ],
      [
        AQ(10, 81, tkNoteBefore: 'Musa warned the magicians'),
        AQ(20, 61),
      ],
      [
        AQ(7, 109,
            tkNoteBefore: 'Musa and Harun were suspected to be magicians too'),
        AQ(7, 132),
        AQ(10, 7, end: 77),
        AQ(17, 101),
        AQ(20, 63),
        AQ(40, 24),
        AQ(43, 49),
      ],
      [
        AQ(7, 119, tkNoteBefore: 'Belief of the magicians', end: 126),
        AQ(20, 70, end: 73),
        AQ(26, 46),
      ],
      [
        AQ(66, 11, tkNoteBefore: 'The belief of Asiya'),
      ],
      [
        AQ(7, 130, tkNoteBefore: "Trial to Pharaoh's family", end: 135),
      ],
      [
        AQ(7, 103, tkNoteBefore: "Pharaoh's weakness", end: 126),
        AQ(10, 75),
        AQ(11, 97, end: 98),
        AQ(17, 102),
        AQ(20, 51, end: 71),
        AQ(23, 46, end: 47),
        AQ(25, 36),
        AQ(26, 11),
        AQ(26, 23, end: 49),
        AQ(28, 36, end: 39),
        AQ(29, 39),
        AQ(38, 12),
        AQ(40, 24, end: 37),
        AQ(43, 51, end: 54),
        AQ(44, 17, end: 22),
        AQ(50, 13),
        AQ(51, 39),
        AQ(54, 41, end: 42),
        AQ(69, 9),
        AQ(73, 16),
        AQ(79, 21, end: 24),
      ],
      [
        AQ(20, 77, tkNoteBefore: 'Musa and his followers went away'),
        AQ(26, 52, end: 63),
        AQ(44, 23, end: 24),
      ],
      [
        AQ(2, 50, tkNoteBefore: 'Musa and his followers were safe'),
        AQ(7, 138),
        AQ(10, 90),
        AQ(17, 103),
        AQ(20, 78, end: 80),
        AQ(26, 65),
        AQ(37, 115, end: 116),
        AQ(44, 30, end: 31),
      ],
      [
        AQ(10, 90, tkNoteBefore: "Pharaoh's belief was too late"),
      ],
      [
        AQ(2, 50, tkNoteBefore: "Pharaoh's and his army"),
        AQ(3, 11),
        AQ(7, 136, end: 137),
        AQ(8, 52, end: 54),
        AQ(10, 88, end: 92),
        AQ(17, 103),
        AQ(20, 78, end: 79),
        AQ(23, 48),
        AQ(25, 36),
        AQ(26, 64, end: 66),
        AQ(28, 40),
        AQ(29, 40),
        AQ(40, 45),
        AQ(43, 55, end: 56),
        AQ(44, 24, end: 29),
        AQ(51, 40),
        AQ(54, 42),
        AQ(69, 10),
        AQ(73, 16),
        AQ(79, 25),
        AQ(85, 17, end: 18),
        AQ(89, 13),
      ],
      [
        AQ(40, 28, tkNoteBefore: "Believer among Pharaoh's family", end: 45),
      ],
      [
        AQ(2, 49, tkNoteBefore: 'The Pharaoh punished the Israelites'),
        AQ(7, 124, end: 141),
        AQ(10, 83),
        AQ(14, 6),
        AQ(20, 71),
        AQ(26, 22),
        AQ(26, 49),
        AQ(28, 4),
        AQ(40, 25),
      ],
      [
        AQ(10, 83,
            tkNoteBefore: 'The Pharaohs and Haman were among the rejected'),
        AQ(11, 97),
        AQ(28, 4, end: 8),
        AQ(28, 32),
        AQ(28, 42),
        AQ(29, 39),
        AQ(40, 36),
        AQ(44, 31),
      ],
      [
        AQ(20, 40, tkNoteBefore: 'Musa killed an Egyptian'),
        AQ(26, 19, end: 21),
        AQ(28, 15, end: 19),
        AQ(28, 33),
      ],
      [
        AQ(28, 25, tkNoteBefore: 'Musa at Median with Shuayb', end: 28),
      ],
      [
        AQ(28, 23, tkNoteBefore: 'Musa and two daughters of Shuayb', end: 27),
      ],
      [
        AQ(33, 69, tkNoteBefore: 'The people who insulted Musa'),
      ],
      [
        AQ(2, 58, tkNoteBefore: 'The Israelites entered the Promised Land'),
        AQ(5, 21, end: 23),
      ],
      [
        AQ(2, 51, tkNoteBefore: "Musa' dialogue with God"),
        AQ(7, 142, end: 143),
        AQ(7, 155),
        AQ(20, 83, end: 84),
      ],
      [
        AQ(2, 51, tkNoteBefore: 'The Israelites worshipped the calf', end: 54),
        AQ(2, 92, end: 93),
        AQ(4, 153),
        AQ(7, 148, end: 152),
        AQ(20, 85, end: 92),
      ],
      [
        AQ(7, 155, tkNoteBefore: 'Seven Israelites with Musa met God'),
      ],
      [
        AQ(20, 95, tkNoteBefore: 'Musa and Samiri', end: 97),
      ],
      [
        AQ(7, 143, tkNoteBefore: 'God manifested himself to the mountain'),
      ],
      [
        AQ(2, 246, tkNoteBefore: 'Refusal of the Israelites', end: 249),
        AQ(3, 111),
        AQ(5, 22, end: 24),
        AQ(59, 14),
      ],
      [
        AQ(2, 41, tkNoteBefore: 'Attributes of the Israelites', end: 44),
        AQ(2, 55, end: 59),
        AQ(2, 61, end: 71),
        AQ(2, 74, end: 76),
        AQ(2, 83),
        AQ(2, 93, end: 6),
        AQ(2, 100, end: 101),
        AQ(2, 104),
        AQ(2, 108),
        AQ(2, 140, end: 142),
        AQ(2, 246, end: 249),
        AQ(3, 24),
        AQ(3, 71),
        AQ(3, 75),
        AQ(3, 112),
        AQ(3, 181),
        AQ(3, 183),
        AQ(4, 44),
        AQ(4, 46, end: 47),
        AQ(4, 49),
        AQ(4, 51),
        AQ(4, 53, end: 54),
        AQ(4, 153),
        AQ(4, 155, end: 156),
        AQ(4, 161),
        AQ(5, 13),
        AQ(5, 20),
        AQ(5, 24),
        AQ(5, 42, end: 43),
        AQ(5, 57, end: 58),
        AQ(5, 62, end: 64),
        AQ(5, 70),
        AQ(5, 79, end: 82),
        AQ(7, 134),
        AQ(7, 138, end: 139),
        AQ(7, 149),
        AQ(7, 160),
        AQ(7, 162, end: 163),
        AQ(7, 169),
        AQ(9, 30),
        AQ(9, 34),
        AQ(16, 118),
        AQ(17, 4),
        AQ(17, 101),
        AQ(20, 85, end: 87),
        AQ(20, 92),
        AQ(58, 8),
        AQ(59, 14),
      ],
      [
        AQ(18, 60, tkNoteBefore: 'Musa and Khidir', end: 82),
      ],
      [
        AQ(28, 76, tkNoteBefore: 'Qarun', end: 82),
        AQ(29, 39, end: 40),
      ],
    ],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.An-Nabi Musa, Jericho'.tr, // ٱلنَّبِي مُوْسَى
  ),
  Prophet(
    // Event data:
    tvEra: 'Kings of_'.tr + a('a.Israel'),
    startMs: -1000,
    endMs: -971,
    // Relic data:
    e: PF.Dawud,
    // Fam data:
    predecessors: [
//    PF.Dawud,
      PF.Yahudzha,
      PF.Gap,
    ], // TODO 'p.In kingship: Possibly Talut (Saul), in prophethood: Samuil (Samuel)'
    dad: null,
    mom: null,
    spouses: null,
    daughters: null,
    sons: [PF.Suleyman],
    relatives: null,
    successors: [PF.Suleyman],
    successor: PF.Suleyman,
    // Required prophet data:
    tvSentTo: a('a.Al-Quds'), // Jerusalem - القدس
    quranMentionCount: 16,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: AQ(6, 89),
    tvKitab: a('a.Zabur') + // Psalms
        _ +
        cns('(17:55, 4:163, 17:55, 21:105)'),
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: a('a.Al-Quds'),
    tvLocationDeath: a('a.Al-Quds'),
    tvTomb: 'p.Tomb of Harun, Jabal HarUn in Petra, Jordan'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Kings of_'.tr + a('a.Israel'),
    startMs: -971,
    endMs: -931,
    // Relic data:
    e: PF.Suleyman,
    // Fam data:
    predecessors: [],
    dad: PF.Dawud,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: [PF.Zakariya, PF.Isa],
    successor: PF.Ilyas,
    // Required prophet data:
    tvSentTo: a('a.Al-Quds'),
    quranMentionCount: 17,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [
      [
        AQ(2, 102, tkNoteBefore: 'Appraisals for Suleyman'),
        AQ(6, 84),
        AQ(21, 81, end: 82),
        AQ(27, 15, end: 16),
        AQ(27, 18, end: 23),
        AQ(27, 36, end: 39),
        AQ(27, 44),
        AQ(34, 12, end: 13),
        AQ(38, 30, end: 31),
        AQ(38, 35, end: 40),
      ],
      [
        AQ(4, 163, tkNoteBefore: "Suleyman's preaching"),
        AQ(27, 25),
        AQ(27, 31),
        AQ(27, 44),
      ],
      [
        AQ(21, 78, end: 79, tkNoteBefore: 'Suleyman judged'),
      ],
      [
        AQ(38, 32, end: 34, tkNoteBefore: 'Fitnah to Suleyman'),
      ],
      [
        AQ(27, 28, end: 31, tkNoteBefore: 'Suleyman and the Queen of Sheba'),
        AQ(27, 34, end: 44),
      ],
      [
        AQ(27, 23, tkNoteBefore: 'The Kingdom of Sheba'),
        AQ(34, 15),
        AQ(34, 18),
      ],
      [
        AQ(34, 14, tkNoteBefore: "Suleyman's death"),
      ],
    ],
    tvLocationBirth: 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    tvLocationDeath:
        a('a.United') + _ + 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    tvTomb: 'p.Al-Ḥaram ash-Sharīf, Jerusalem'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Ilyas,
    // Fam data:
    predecessors: [
      PF.Harun,
      PF.Izar,
      PF.Fahnaz,
    ],
    dad: PF.Yasin,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: null,
    successor: PF.Alyasa,
    // Required prophet data:
    tvSentTo: a('a.Samaria') + //  TODO
        ',_'.tr +
        'The people of_'.tr +
        a('a.Ilyas') +
        _ +
        cns('(37:124)'),
    quranMentionCount: 2,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: AQ(37, 123),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Possibly in Baalbek, Lebanon'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: 'Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Alyasa,
    // Fam data:
    predecessors: [
      PF.Yusuf,
      PF.Efraim,
      PF.Shultem,
    ],
    dad: PF.Adi,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: null,
    successor: PF.Yunus,
    // Required prophet data:
    tvSentTo: a('a.Samaria') + //  TODO
        ',_'.tr +
        a('a.East') +
        _ +
        a('a.Al-Arabiyyah') +
        '_and_' +
        a('a.Fars'), //Fars? Persia
    quranMentionCount: 2,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [
      [AQ(6, 86), AQ(38, 48)],
    ],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Eğil district of Diyarbakir Province'.tr +
        ',_'.tr +
        a('a.Turkiye'), //' or Al-Awjam, Saudi Arabia.'
  ),
  Prophet(
    // Event data:
    tvEra: 'Unknown'.tr,
    startMs:
        -800, // uncertain (8th century BCE or post-exilic period) in Wikipedia
    endMs: -800,
    // Relic data:
    e: PF.Yunus,
    // Fam data:
    predecessors: [
      PF.Bunyamin,
      PF.Gap,
    ],
    dad: PF.Matta,
    mom: null,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: null,
    successors: null,
    successor: PF.Zakariya,
    // Required prophet data:
    tvSentTo: a('a.Nineveh') + // TODO Ninevah? arabee?
        ',_'.tr +
        'The people of_'.tr +
        a('a.Yunus') +
        cns('(10:98)'),
    quranMentionCount: 4,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: AQ(37, 139),
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb:
        "p.Possibly at the Mosque of Yunus, Mosul, Iraq, Mashhad Village Gath-hepher, Israel; Halhul, Palestinian West Bank; Sarafand, Lebanon; Giv'at Yonah (Jonah's Hill) in Ashdod, Israel, near Fatih Pasha Mosque in Diyarbakir"
                .tr +
            ',_'.tr +
            a('a.Turkiye'),
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Masih'),
    startMs: 0,
    endMs: 0,
    // Relic data:
    e: PF.Zakariya,
    // Fam data:
    predecessors: [
//    PF.Yaqub,
//    PF.Yahudzha,
//    PF.Gap,
      PF.Suleyman,
      PF.Gap,
    ],
    dad: null,
    mom: null,
    spouses: [PF.Ishba],
    daughters: null,
    sons: [PF.Yahya],
    relatives: null, // TODO relation to Isa?
    successors: [PF.Yahya],
    successor: PF.Yahya,
    // Required prophet data:
    tvSentTo: a('a.Al-Quds'),
    quranMentionCount: 7,
    aqNabi: AQ(6, 89),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: null,
    tvTomb: 'p.Great Mosque of Aleppo, Syria'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Masih'),
    startMs: -100,
    endMs: 28, // AD 28–36
    // Relic data:
    e: PF.Yahya,
    // Fam data:
    predecessors: [],
    dad: PF.Zakariya,
    mom: PF.Ishba,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Isa],
    relativesTypes: [RELATIVE.DistantCousin],
    successors: null,
    successor: PF.Isa,
    // Required prophet data:
    tvSentTo:
        at('p.{0} of {1} in {2}', ['a.Children', 'a.Israel', 'a.Al-Quds']),
    quranMentionCount: 5,
    aqNabi: AQ(3, 39),
    // Optional prophet data:
    aqRasul: null,
    tvKitab: null,
    aqUluAlAzmList: null,
    aqInDescriptionLists: [[]],
    tvLocationBirth: null,
    tvLocationDeath: 'p.Decapitated by the ruler Herod Antipas'.tr,
    tvTomb: 'p.His head is possibly at the Umayyad Mosque in Damascus'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Masih'),
    startMs: -4,
    endMs: 30,
    // Relic data:
    e: PF.Isa,
    // Fam data:
    predecessors: [
      PF.Suleyman,
      PF.Gap,
      PF.ImranAbuMaryam,
    ],
    dad: null,
    mom: PF.Maryam,
    spouses: null,
    daughters: null,
    sons: null,
    relatives: [PF.Zakariya, PF.Yahya],
    relativesTypes: [RELATIVE.DistantCousin, RELATIVE.DistantCousin],
    successors: null,
    successor: PF.Muhammad,
    // Required prophet data:
    tvSentTo:
        at('p.{0} of {1} in {2}', ['a.Children', 'a.Israel', 'a.Al-Quds']) +
            'p._as written in the_' +
            a('a.Quran') +
            _ +
            cns('61:6') +
            "p._which references the Bible's Matthew_".tr +
            cns('15:24'),
    quranMentionCount: 25,
    aqNabi: AQ(19, 30),
    // Optional prophet data:
    aqRasul: AQ(4, 171),
    tvKitab: a('a.Injil') + // Gospel
        _ +
        cns('(57:27)'),
    aqUluAlAzmList: [AQ(42, 13)],
    aqInDescriptionLists: [[]],
    tvLocationBirth: 'p.Judea, Roman Empire'.tr,
    tvLocationDeath:
        'p.Still alive, was raised to Heaven from_'.tr + a('a.Falastin'),
    tvTomb: 'p.None yet'.tr,
  ),
  Prophet(
    // Event data:
    tvEra: a('a.Muhammad'), // Muhammad
    startMs: 570,
    endMs: 632,
    // Relic data:
    e: PF.Muhammad,
    // Fam data:
    predecessors: [
      PF.Ismail,
      PF.Gap, // TODO iktilaf here, find best one
      PF.Adnan,
      PF.Ma__add,
      PF.Nizar,
      PF.Mudar,
      PF.Ilyas_,
      PF.Mudrikah,
      PF.Khuzaimah,
      PF.Kinanah,
      PF.An__Nadr,
      PF.Malik,
      PF.Fihr,
      PF.Ghalib,
      PF.Lu__ayy,
      PF.Ka__b,
      PF.Murrah,
      PF.Kilab,
      PF.Qusayy,
      PF.Abd_Manaf,
      PF.Hashim,
      PF.Abdull_Muttalib,
    ],
    successors: [PF.Mahdi, PF.Isa],
    mom: PF.Amina_Bint_Wahb,
    dad: PF.Abdullah_,
    spouses: [
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
    daughters: null,
    // tvDaughters: [ // TODO Disable for now since UI gets too big
    //   PF.Zainab, //       cns('599–629 ') + a('a.Zainab'),
    //   PF.Ruqayyah, //     cns('601–624 ') + a('a.Ruqayyah'),
    //   PF.Umm_Kulthum, //  cns('603–630 ') + a('a.Umm Kulthum'),
    //   PF.Fatimah, //      cns('605–632 ') + a('a.Fatimah'),
    // ],
    sons: null,
    // tvSons: [
    //   // https://en.wikipedia.org/wiki/Muhammad%27s_children
    //   PF.Zayd_Ibn_Harithah, //    cns('581-629 ') + a('a.Zayd ibn Harithah'),
    //   PF.Qasim, //                cns('598–601 ') + a('a.Al-Qasim'),
    //   PF.Abdullah_Ibn_Muhmmad, // cns('611–613 ') + a('a.Abdullah'),
    //   PF.Ibrahim_Ibn_Muhmmad, //  cns('630–632 ') + a('a.Ibrahim'),
    // ],
    relatives: null,
    // Required prophet data:
    tvSentTo: 'p.All the worlds'.tr +
        ',_'.tr +
        a('a.Nas') + // mankind
        '_and_'.tr +
        a('a.Jinn') +
        _ +
        cns('(21:107)'),
    quranMentionCount: 4,
    aqNabi: AQ(33, 40),
    // Optional prophet data:
    aqRasul: AQ(33, 40),
    tvKitab: a('a.Quran') +
        _ +
        cns('(42:7)') +
        '_and_'.tr +
        a('a.Sunnah') +
        _ +
        cns('(3:31, 3:164, 4:59, 4:115, 59:7)'),
    aqUluAlAzmList: [AQ(2, 124)],
    aqInDescriptionLists: [[]],
    tvLocationBirth: a(DAY_OF_WEEK.Monday.tk) +
        ',_'.tr +
        cni(12) +
        _ +
        a("a.Rabi' Al-Thani") +
        _ +
        cni(53) +
        'BH'.tr +
        '/' +
        cni(570) +
        'AD'.tr +
        ',_'.tr +
        a('a.Aliathnayn') +
        ',_'.tr +
        a('a.Al-Madinah') + // Al Madinah Al Munawwarah المدينة المنورة,
        ',_'.tr +
        a('a.Al-Hejaz') +
        ',_'.tr +
        a('a.Al-Arabiyyah'),
    tvLocationDeath: a(DAY_OF_WEEK.Monday.tk) +
        ',_'.tr +
        cni(12) +
        _ +
        a("a.Rabi' Al-Thani") +
        _ +
        cni(11) +
        'AH'.tr +
        '/' +
        cni(632) +
        'AD'.tr +
        ',_'.tr +
        a('a.Aliathnayn') + // Monday
        ',_'.tr +
        a('a.Al-Madinah') +
        ',_'.tr +
        a('a.Al-Hejaz') + // ٱلْحِجَاز al-Ḥijaz
        ',_'.tr +
        a('a.Al-Arabiyyah'), // Arabia - الْعَرَبِيَّة
    tvTomb: at('p.Green Dome in {0}, {1}',
        ['a.Al-Masjid an-Nabawi', 'a.Al-Madinah']), //المسجد النبوي
  ),
];

final List<RelicSetFilter> relicSetFiltersProphet = [
  RelicSetFilter(
    type: FILTER_TYPE.Default,
    tvLabel: a('a.Nabi'),
  ),
  RelicSetFilter(
    type: FILTER_TYPE.IdxList,
    tvLabel: a('a.Rasul'),
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
    tvLabel: a('a.Ulu Al-Azm'),
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
    tvLabel: 'Quran Name Mentions'.tr,
    field: FILTER_FIELD.QuranMentionCount,
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
    tvLabel: 'Family Tree'.tr,
    treeGraph1: getGraphAllFamily(RELIC_TYPE.Anbiya, PF.Gap.index),
    treeGraph2: getGraphOnlyRelics(RELIC_TYPE.Anbiya, PF.Gap.index),
  ),
];

/// PROPHET FAMILY (TODO Turkish Words: Hızır, Lukman, Yuşa, Kâlib b. Yüfena, Hızkıl, Şemûyel, Şâ'yâ
enum PF {
  /* TODO rename to AS (Aleyhi Salam) */
  Adam(Isim(
    tvHebrew: 'אדם (Adam)',
    tkHebrewMeaning: 'p.man',
    tvGreek: 'Αδάμ (Adam)',
    tvLatin: 'Adam',
  )),
  Idris(Isim(
    tvHebrew: 'חֲנוֹך (Hanokh)',
    tkHebrewMeaning: 'p.dedicated',
    tvGreek: 'Ἐνώχ (Enoch)',
    tvLatin: 'Enoch',
  )),
  Nuh(Isim(
    tvHebrew: 'נֹחַ (Noach)',
    tkHebrewMeaning: 'p.rest, repose',
    tvGreek: 'Νῶε (Noe)',
    tvLatin: null,
  )),
  Hud(Isim(
    tvHebrew: 'עבר (Eber)',
    tkHebrewMeaning: 'p.region beyond',
    tvGreek: null,
    tvLatin: null,
    tkNote: 'p.Possibly Eber or his son',
  )),
  Salih(Isim(
    tvHebrew: null, // TODO
    tvGreek: null,
    tvLatin: null,
    tkNote: 'p.Often attributed to biblical prophets',
  )),
  Ibrahim(Isim(
    tkLaqab: [
      'a.Khalilullah', // Friend of Allah
      'p.Father of Abrahimic faiths', // TODO
    ],
    tvHebrew: 'אַבְרָהָם (Abraham)',
    tkHebrewMeaning: 'p.many, multitude',
    tvGreek: 'Ἀβραάμ (Abraam)',
    tvLatin: 'Abraham',
  )), // İbrahim
  Lut(Isim(
    tvHebrew: 'לוֹט (Lot)',
    tkHebrewMeaning: 'p.covering, veil',
    tvGreek: null,
    tvLatin: null,
  )), // İsmail
  Ismail(Isim(
    tkLaqab: ['p.Father of the Arabs'], // TODO
    tvHebrew: 'יִשְׁמָעֵאל (Yishmael)',
    tkHebrewMeaning: 'p.God will hear',
    tvGreek: 'Ἰσμαήλ (Ismael)',
    tvLatin: 'Ismahel',
  )), // İshak
  Ishaq(Isim(
    tkLaqab: ['p.Father of the Hebrews/Jews'], // TODO
    tvHebrew: 'יִצְחָק (Yitzhaq)',
    tkHebrewMeaning: 'p.he will laugh, he will rejoice',
    tvGreek: 'Ισαάκ ()',
    tvLatin: 'Isaac',
  )),
  Yaqub(Isim(
    tkLaqab: [
      'a.Israel', //  إِسْرَآءِيل
      'p.Father of the 12 tribes of Israel',
    ],
    tvHebrew: 'יַעֲקֹב (Yaaqov)',
    tkHebrewMeaning:
        'p.Possibly "holder of the heel" or derived from "may God protect"',
    tvGreek: 'Ἰακώβ (Iakob)',
    tvLatin: 'Iacob',
  )), //  Yakub
  Yusuf(Isim(
    tvHebrew: 'יוֹסֵף (Yosef)',
    tkHebrewMeaning: 'p.he will add',
    tvGreek: 'Ἰωσήφ (Ioseph)',
    tvLatin: 'Ioseph',
  )),
  Ayyub(Isim(
    tvHebrew: 'אִיּוֹב (Iyyov)',
    tkHebrewMeaning: 'p.persecuted, hated',
    tvGreek: 'Ἰώβ (Iob)',
    tvLatin: 'Iob',
  )), // Eyyub
  DhulKifl(Isim(
//  tkAr: 'حزقيال', //?
    tvHebrew: 'יְחֶזְקֵאל (Yechezkel)',
    tkHebrewMeaning: 'p.God will strengthen',
    tvGreek: 'Ἰεζεκιήλ (Iezekiel)',
    tvLatin: 'Ezechiel, Hiezecihel',
    tkNote: 'p.Possibly Ezekiel, Buddha, Joshua, Obadiah or Isaiah',
  )), // Zülkifl
  Shuayb(Isim(
    tvHebrew: 'יִתְרוֹ (Yitro)',
    tkHebrewMeaning: 'p.abundance',
    tvGreek: null,
    tvLatin: 'Jethro',
    tkNote: 'p.Often thought to be Jethro, but this is highly disputed.',
  )), //  Şuayb
  Harun(Isim(
    tvHebrew: 'אַהֲרֹן (Aharon)',
    tkHebrewMeaning:
        'p.Possibly of Egyptian origin or from hebrew "high mountain" or "exalted"',
    tvGreek: 'Ἀαρών (Aaron)',
    tvLatin: 'Aaron',
  )),
  Musa(Isim(
    tvHebrew: 'מֹשֶׁה (Moshe)',
    tkHebrewMeaning: 'p.Possibly from Egyptian "son" or Hebrew "deliver"',
    tvGreek: 'Μωϋσῆς (Mouses)',
    tvLatin: 'Moyses',
  )),
  Dawud(Isim(
    tvHebrew: 'דָּוִד (Dawid)',
    tkHebrewMeaning: 'p.beloved',
    tvGreek: 'Δαυίδ (Dauid)',
    tvLatin: 'David',
  )), // Davud
  Suleyman(Isim(
    tvHebrew: 'שְׁלֹמֹה (Shelomoh)',
    tkHebrewMeaning: 'p.Derived from "peace" (שָׁלוֹם shalom)',
    tvGreek: 'Σαλωμών (Salomon)',
    tvLatin: 'Solomon',
  )), // Süleyman
  Ilyas(Isim(
    tvHebrew: 'אֱלִיָּהוּ (Eliyyahu), אֵלִיָה (Eliya)',
    tkHebrewMeaning: 'p.my God is Yahweh',
    tvGreek: 'Ηλίας (Ilias)',
    tvLatin: 'Elias',
  )), // İlyas
  Alyasa(Isim(
    tvHebrew: 'אֱלִישַׁע (Alysha\'e/Elisha)',
    tkHebrewMeaning: 'p.my God is salvation',
    tvGreek: 'Ἐλισαιέ (Elisaie)',
    tvLatin: 'Eliseus',
  )), // Elyesa
  Yunus(Isim(
    tkLaqab: ['a.Dhul-Nun'], // ذُو ٱلنُّوْن - The One of the Fish
    tvHebrew: 'יוֹנָה (Yonah)',
    tkHebrewMeaning: 'p.dove',
    tvGreek: 'Ἰωνᾶς (Ionas)',
    tvLatin: 'Ionas',
  )),
  Zakariya(Isim(
    tvHebrew: 'זְכַרְיָה (Zekharyah)',
    tkHebrewMeaning: 'p.God remembers',
    tvGreek: 'Ζαχαρίας (Zacharias)',
    tvLatin: 'Zaccharias',
  )),
  Yahya(Isim(
    tkLaqab: ['p.Christians call him "John the Babtist"'],
    tvHebrew: 'יוֹחָנָן (Yochanan)',
    tkHebrewMeaning: 'p.God is gracious',
    tvGreek: 'Ἰωάννης (Ioannes)',
    tvLatin: 'Iohannes',
  )),
  Isa(Isim(
    tkLaqab: ['a.Masih'], // Messiah
    tvAramaic: 'יֵשׁוּעַ (Ishoʿ)',
    tvGreek: 'Ιησους (Iesous)',
    tvLatin: 'Iesus',
  )),
  Muhammad(Isim(
    tkLaqab: [
      'a.Khātam al-Nabiyyīn',
      'a.Abu al-Qasim',
      'a.Ahmad',
      'a.Al-Mahi',
      'a.al-Hashir',
      'a.Al-Aqib',
      'a.al-Nabī',
      'a.Rasūl’Allāh',
      'a.al-Ḥabīb',
      'a.Ḥabīb Allāh',
      "a.al-Raḥmah lil-'Ālamīn",
      'a.An-Nabiyyu l-Ummiyy',
      'a.Mustafa',
    ],
  )),

  // special case area
  Gap(Isim()), // needed

  // TODO Good resource for Arabic/Hebrew/Greek names: https://en.wikipedia.org/wiki/Family_tree_of_Muhammad
//   Adam
  /* TODO has ~40-120 more kids! */
  /* */ Habel(Isim()), //       Cain-Habil
  /* */ Qabel(Isim()), //       Abel-Kabil
  /* */ Anaq(Isim()), //        ?
  /* */ Sheth(Isim()), //       Seth? Shayth? Seth-Şit
  /*    */ Anwas(Isim()), //    Anūsh أَنُوش or: Yānish يَانِش Enosh-Enuş
  /*    */ Qinan(
      Isim()), //    Kenan-Kinan (Hebrew: קֵינָן‎‎, Modern: Qēnan, Tiberian: Qēnān; Arabic: قَيْنَان, romanized: Qaynān; Biblical Greek: Καϊνάμ, romanized: Kaïnám)
  /*    */ Mahlail(Isim()), //  Mahlabeel? Mahalel
  /*    */ Yarid(
      Isim()), //    Yard? Jared-Yarid Jared or Jered (Hebrew: יֶרֶד‎ Yereḏ, in pausa יָרֶד‎ Yāreḏ, "to descend"; Greek: Ἰάρετ Iáret; Arabic: أليارد al-Yārid)
//         Idris AKA Ahnuh/Uhnuh Enoch (Arabic: أَخْنُوخ, romanized: ʼAkhnūkh)
  /*    */ Matulshalkh(
      Isim()), // Mitoshilkh?  Methusaleh-Mettu Şelah (Hebrew: מְתוּשֶׁלַח Məṯūšélaḥ, in pausa מְתוּשָׁלַח‎ Məṯūšālaḥ, "His death shall send" or "Man of the javelin" or "Death of Sword";[1] Greek: Μαθουσάλας Mathousalas) Mattūshalakh= Ibn Ishaq and Ibn Hisham geneology of Muhammad
  /*    */ Lamik(Isim()), //       Lamech-Lamek/Lemek/Lemk
//         Nuh
  /*       */ Ham(Isim()), //      Ham
  /*       */ Yam(Isim()), //      Yam (Killed in flood)
  /*       */ Yafith(Isim()), //   Japeth
  /*       */ Sam(Isim()), //      Shem
  /*          */ Irem(Isim()),
  /*             */ Aush(Isim()), //        ?-Avs
  /*                */ Ad(Isim()), //       ?
  /*                */ Khalud(Isim()), //   ?-Halud
  /*                */ Raya(Isim()), //     ?-Rebah
  /*                */ Abdullah(Isim()), // ?
//                     Hud
  /*             */ Ars(Isim()), //       Abir?
  /*                */ Samud(Isim()), //  -Semud
  /*                */ Hadzir(Isim()), // -Hadir
  /*                */ Ubayd(Isim()), //  -Ubeyd
  /*                */ Masih(Isim()), //  Kemaşic?
  /*                */ Auf(Isim()), //    -Esif/Asit
  /*                */ Abir_Ubayd(Isim()), //   Ubayd?
//                     Salih
  /*          */ Arfakhshad(Isim()), // -Erfahşed
  /*          */ Shalikh(Isim()), // -Şalıh
  /*          */ Abir(Isim()), // NOTE: NOT HUD
  /*          */ Falikh(Isim()), // -Falığ
  /*          */ Rau_Ergu(Isim()), // AKA Ergu
  /*          */ Sarukh(Isim()), // AKA Sharug -Şarug
  /*          */ Nahur(Isim()), // -Nahor
  /*          */ Azar_Taruh(
      Isim()), // AKA Taruh -Tarah // TODO Mentioned in Quran
  /*             */ Haran(Isim()), // AKA Taruh -Tarah, brother of Ibrahim
//                     Lut - Nephew of Abraham
//                  Ibrahim
  /*                */ Madyan(Isim()), // Midian-Medyen
  /*                   */ Yashjar(Isim()), // Mubshakar? Issachar-Yeşcur
  /*                   */ Mikeel(Isim()), //  Mankeel? Safyon? -Mikail
//                        Shuayb
//                     Ismail
//                        ... Muhammad's Family Tree is below
//                        Muhammad
//                     Ishaq
  /*                   */ Isu(
      Isim()), //   AlEls? Els? Ish? Isu? Easu-Ays Brother of Jacob
  /*                      */ Rimil(Isim()), // Razih? Tarekh? Rimil-Razıh
  /*                      */ Amose(Isim()), // Mose-Mus
//                           Ayyub
//                           Dhul-Kifl
//                        Yaqub  TODO And all 12 tribe founders
  /*                      */ Bunyamin(
      Isim()), // (son of Rahil) Benjamin-Bünyamin
  //                             Abumatta?
  /*                          */ Matta(Isim()), // متى - Amittai latin, Matthew
//                               Yunus
//                           Yusuf  (son of Rahil)
  /*                         */ Efraim(
      Isim()), //  Ephraim-Efrâîm // TODO branch out to Yusa here: Yuşa: b. Nûn b. Ephraim-Efrâim b. Yûsuf
  /*                         */ Shultem(Isim()), // Shultam-Şütlem
  /*                         */ Adi(Isim()), //     -Adiy
//                              Alyasa TODO It is also said that Alyasa is the son of Ilyas's uncle Ukhtub-Ahtub (Through Harun, Not Yusuf like here).
  /*                      */ Lawi(Isim()),
  /*                         */ Kehath_Yashur(
      Isim()), //       Kohath-Kahis_Yashür
  /*                         */ Imran(Isim()), // عمران   -Lavi
//                                 Musa
//                                 Harun
  /*                               */ Izar(Isim()), // -Ayzar,
  /*                               */ Fahnaz(Isim()), // -Finhas,
  /*                               */ Yasin(Isim()),
//                                    Ilyas
  /*                      */ Yahudzha(Isim()),
  //                         UNKNOWN GAP?
//                           Dawud,
//                           Suleyman,
//                           UNKNOWN GAP? TODO Danyal, Uzeyir AND Bridge Isa + Zakariya/Yahya
//                              Zakariya
//                                 Yahya
  /*                         */ ImranAbuMaryam(Isim()),
//                                 Maryam
//                                    Isa

// Muhammad's SAW Lineage:
  //Ismail
  //Gap, // TODO iktilaf here, find best one
  Adnan(Isim()),
  Ma__add(Isim()),
  Nizar(Isim()),
  Mudar(Isim()),
  Ilyas_(Isim()),
  Mudrikah(Isim()),
  Khuzaimah(Isim()),
  Kinanah(Isim()),
  An__Nadr(Isim(tkLaqab: ['Quraysh'])),
  Malik(Isim()),
  Fihr(Isim()),
  Ghalib(Isim()),
  Lu__ayy(Isim()),
  Ka__b(Isim()),
  Murrah(Isim()),
  Kilab(Isim()),
  Qusayy(Isim()),
  Abd_Manaf(Isim()),
  Hashim(Isim()),
  Abdull_Muttalib(Isim(
    tkLaqab: ['Shaybah'],
  )), // Abd al-Muttalib? Grandfather
  Abdullah_(Isim()), //       Father عَبْد ٱللَّٰه ٱبْن عَبْد ٱلْمُطَّلِب
//Muhammad
// Sons:
  Zayd_Ibn_Harithah(Isim()), // زَيْد ٱبْن حَارِثَة  (foster son)
  Qasim(Isim()),
  Abdullah_Ibn_Muhmmad(Isim()),
  Ibrahim_Ibn_Muhmmad(Isim()),
//Mother
  Amina_Bint_Wahb(Isim(fem: true)), // Mother // آمِنَة ٱبْنَت وَهْب
// Wives:
  Khadijah(Isim(fem: true)), //     Muhammad 1
  Sawdah(Isim(fem: true)), //       Muhammad 2
  Aisha(Isim(fem: true)), //        Muhammad 3
  Hafsah(Isim(fem: true)), //       Muhammad 4
  UmmAlMasakin(Isim(fem: true)), // Muhammad 5
  UmmSalamah(Isim(fem: true)), //   Muhammad 6
  Zaynab(Isim(fem: true)), //       Muhammad 7
  Juwayriyah(Isim(fem: true)), //   Muhammad 8
  UmmHabibah(Isim(fem: true)), //   Muhammad 9
  Safiyyah(Isim(fem: true)), //     Muhammad 10
  Maymunah(Isim(fem: true)), //     Muhammad 11
  Rayhana(Isim(fem: true)), //      Muhammad 12
  Maria(Isim(fem: true)), //        Muhammad 13
// Daughters:
  Zainab(Isim(fem: true)),
  Ruqayyah(Isim(fem: true)),
  Umm_Kulthum(Isim(fem: true)),
  Fatimah(Isim(fem: true)),
//FUTURE
  Mahdi(Isim()),
// End of Muhammad's SAW Lineage:

// Father of:
  Faqud(
      Isim()), // Ishba (Wife of Zakaryia), Hanna (Wife of ImranAbuMaryam, grandmother of Isa)

// Wife of:
  Hawwa(Isim(fem: true)), //        Adam-Havva
  Naamah(Isim(fem: true)), //       Nuh // TODO find arabic name
  Sarah(Isim(fem: true)), //        Ibrahim 1-Sare
  Hajar(Isim(fem: true)), //        Ibrahim 2-Hacer
  Rafeqa(Isim(fem: true)), //       Ishaq, mother of Ishaq Rebekah-Refaka
  Rahil_Bint_Leban(Isim(fem: true)), //        Yaqub Rachel
  Lia(Isim(fem: true)), //          Yaqub Leah
  Saffurah(Isim(fem: true)), //     Musa  صفورة
  Hanna(Isim(fem: true)), //        ImranAbuMaryam
  Ishba(
    Isim(fem: true),
  ), //        Zakariya, Mother / of Yahya/Elizabeth', // TODO Barren all her life until miracle birth of Yahya in her old age
  Maryam(Isim(fem: true)), // EDGE CASE: prophethood through mom

// Mother of:
  Mahalath(Isim(fem: true)), // Ibrahim
  DaughterOfLut(Isim(fem: true)), // Ayyub and Shuayb's Mother
  Yukabid(Isim(
      fem:
          true)), // Musa and Harun يوكابد  Latin: Jochebed // Other possible names are Ayaarkha or Ayaathakht (Ibn Katheer), Lawha (Al-Qurtubi) and Yoohaana (Ibn 'Atiyyah)
  Asiya(Isim(fem: true)), // Musa foster mother, wife of Firaun

// Sister of:
  Miriam(Isim(
      fem:
          true)), // Musa and Harun // TODO Sister that followed Musa down river (Same name as Maryam?)
  ;

  const PF(this.isim);
  final Isim isim;
}

// TODO: https://www.quora.com/Is-it-true-that-all-the-Christian-prophets-are-well-quoted-in-The-Holy-Quran
// Idris: Idris has been identified by most Islamic scholars as the same person as Enoch in Genesis. This is mostly because the Qur’an identifies him as truthful: “And mention in the Book, Idrees. Indeed, he was a man of truth and a prophet.” (19:56) and patient: “And [mention] Ishmael and Idrees and Dhul-Kifl; all were of the patient.” (21:85) Although, some people debate that Idris was actually the same person as Hermes Trismegtus.
//
// Hud: Hud has sometimes been identified with Eber in Genesis (even though Eber is usually known as Abir in the family tree of prophets), but there is little evidence supporting this. The story of Hud is not equated with any story in the Bible.
//
// Saleh: Similar to Hud, Saleh’s story is not equated with any story in the Bible, but he is sometimes associated with Salah in Genesis, even though in Genesis, Salah is the father of Eber, who is associated with Hud, who came before Saleh, and in the family tree of prophets, the father of Abir is Shalikh, who is a different person from Saleh, and Hud and Saleh are actually fifth cousins, twice removed, not father and son, and that they are descended from Aram, not Arfachshad, and that there is little evidence supporting this.
//
// Shuayb: Shuayb is sometimes identified with the Biblical Jethro, the father-in-law of Musa. This is because of a single verse in the Qur’an which states: “[Shuayb] said [to Musa]: “Indeed, I wish to wed you to one of these, my two daughters, on the condition that you serve me for eight years; but if you complete ten, it will be [as a favor] from you. And I do not wish to put you in difficulty. You will find me, if Allah wills, from the righteous.”” (28:27). For this reason, it is believed that Shuayb was the father-in-law of Musa, and thus, the same person as Jethro.
//
// Dhul-Kifl: Not much is known about Dhul-Kifl, and for this reason, it is impossible to identify a story in the Bible with him. However, the name “Dhu al-Kifl”, for various reasons, has sometimes been identified with “Ezekiel”, and therefore, some scholars believe that Dhul-Kifl and Ezekiel were the same person.

// TODO: https://sorularlaislamiyet.com/peygamberlerin-soy-agaci-ve-gelis-sirasi-hakkinda-bilgi-verir-misiniz-0
// 19. Yuşa: b. Nûn b. Ephraim-Efrâim b. Yûsuf
// 18. Hizir: Rivayete göre: Hizir ın soyu: Belya (or İlya) b. Milkân b. Falığ b. Âbir b. Salih b. Erfahşed b. Sâm b.Nuh olup babası, büyük bir kraldı. Kendisinin; Âdem ın oğlu or Ays b. Ishaq ın oğullarından olduğu or Ibrahim a iman ve Babil'den, Onunla birlikte hicret edenlerden birisinin ya da Farslı bir babanın oğlu olduğu, kral Efridun ve Ibrahim devrinde yaşadığı, büyük Zülkarneyn'e Kılavuzluk ettiği, İsrailoğulları krallarından İbn. Emus'un zamanında İsrailoğullarına peygamber olarak gönderildiği, halen, sağ olup her yıl, Hacc Mevsiminde Ilyas la buluştukları da rivayet edilir.
// 18. Khidr: According to the rumor: Khidr 's lineage: Belya (or İlya) b. Milkan b. Falığ b. Âbir b. Salih b. Erfahşed b. Sam b. Nuh and his father was a great king. himself; Son of Adem or Ays b. He was one of the sons of Ishaq, or Abraham was from faith and Babylon, one of those who migrated with him, or he was the son of a Persian father, lived during the reign of King Efridun and Ibrahim, and guided the great Dhul-Qarnayn, one of the kings of the Israelites, Ibn. It is also rumored that Emus was sent as a prophet to the Children of Israel in his time, and that he is still alive and meets with Ilyas every year during the Hajj Season.
// 20. Kalib b. Yufena: Kalib b. Yufena b. Bariz (Fariz) b. Yehuza b. Yaqub b. Ishaq b. Ibrahim Kalib b. Yüfenna was the husband of Mary, the sister of Musa, or the son-in-law of Musa.
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
