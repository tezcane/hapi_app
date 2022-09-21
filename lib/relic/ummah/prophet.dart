import 'package:get/utils.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/family_tree/family_tree.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/event/event_asset.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

const String _ = ' '; // space/gap

/// Peace be upon all (SAW) the Prophets mentioned in the code.
class Prophet extends FamilyTree {
  Prophet({
    // Event data:
    required String trValEra,
    required double startMs,
    required double endMs,
    required EventAsset asset,

    // Relic data not needed to pass in, it is auto-generated in super() call

    // Required Fam data:
    required PF pf,
    required List<PF> predecessors,
    // Optional Fam data:
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
          // Event data:
          trValEra: trValEra,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          // Relic data:
          relicType: RELIC_TYPE.Quran_AlAnbiya,
          trKeySummary: 'ps.${pf.name}', // ps=Prophet Summary
          trKeySummary2: 'pq.${pf.name}', // pq=Prophet Quran
          // Required Fam data:
          e: pf,
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
  String get trValRelicSetTitle => a('a.Anbiya');
  @override
  List<RelicSetFilter> get relicSetFilters {
    if (relicSetFiltersInit.isNotEmpty) return relicSetFiltersInit;

    // Add special cases here, if needed
    // Graph graph = getGraphAllFamily(RELIC_TYPE.Quran_AlAnbiya, PF.Gap.index);
    // TODO add Isa<->Yahya connection/Lot Daugthers/etc. special logic here

    relicSetFiltersInit.addAll([
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
        treeGraph1: getGraphAllFamily(RELIC_TYPE.Quran_AlAnbiya, PF.Gap.index),
        treeGraph2: getGraphOnlyRelics(RELIC_TYPE.Quran_AlAnbiya, PF.Gap.index),
      ),
    ]);

    return relicSetFiltersInit;
  }
}

Future<List<Prophet>> initProphets() async {
  List<Prophet> rv = [];

  rv.add(Prophet(
    // Event data:
    trValEra: 'i.Birth of Humans'.tr,
    startMs: -340000,
    endMs: -339050,
    asset: await _getImageEventAsset(PF.Adam),
    // Fam data:
    pf: PF.Adam,
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
    // Event data:
    trValEra: 'i.Birth of Humans'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Idris),
    // Fam data:
    pf: PF.Idris,
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
    // Event data:
    trValEra: 'i.Great Flood'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Nuh),
    // Fam data:
    pf: PF.Nuh,
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
    // Event data:
    trValEra: 'i.Unknown'.tr,
    startMs: -2400,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Hud),
    // Fam data:
    pf: PF.Hud,
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
    // Event data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Salih),
    // Fam data:
    pf: PF.Salih,
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
    // Event data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Ibrahim),
    // Fam data:
    pf: PF.Ibrahim,
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
    // Event data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Lut),
    // Fam data:
    pf: PF.Lut,
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
    // Event data:
    trValEra: a('a.Ibrahim'),
    startMs: -1800,
    endMs: -1664,
    asset: await _getImageEventAsset(PF.Ismail),
    // Fam data:
    pf: PF.Ismail,
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
    // Event data:
    trValEra: a('a.Ibrahim'),
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Ishaq),
    // Fam data:
    pf: PF.Ishaq,
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
    // Event data:
    trValEra: 'i.Old Egyptian Kingdom'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Yaqub),
    // Fam data:
    pf: PF.Yaqub,
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
    // Event data:
    trValEra: 'i.Old Egyptian Kingdoms'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Yusuf),
    // Fam data:
    pf: PF.Yusuf,
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
    // Event data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Ayyub),
    // Fam data:
    pf: PF.Ayyub,
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
    // Event data:
    trValEra: 'i.Unknown'.tr, // TODO
    startMs: 0, // TODO Buddha: 6th or 5th century BCE
    endMs: 0,
    asset: await _getImageEventAsset(PF.DhulKifl),
    // Fam data:
    pf: PF.DhulKifl,
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
    // Event data:
    trValEra: 'i.Unknown'.tr,
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Shuayb),
    // Fam data:
    pf: PF.Shuayb,
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
    // Event data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    startMs: -1300,
    endMs: -1200,
    asset: await _getImageEventAsset(PF.Musa),
    // Fam data:
    pf: PF.Musa,
    predecessors: [
//    PF.Yaqub,
      PF.Lawi,
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
    // Event data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    startMs: -1303,
    endMs: -1200,
    asset: await _getImageEventAsset(PF.Harun),
    // Fam data:
    pf: PF.Harun,
    predecessors: [
//    PF.Yaqub,
//    PF.Lawi,
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
    // Event data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    startMs: -1000,
    endMs: -971,
    asset: await _getImageEventAsset(PF.Dawud),
    // Fam data:
    pf: PF.Dawud,
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
    // Event data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    startMs: -971,
    endMs: -931,
    asset: await _getImageEventAsset(PF.Suleyman),
    // Fam data:
    pf: PF.Suleyman,
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
    // Event data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Ilyas),
    // Fam data:
    pf: PF.Ilyas,
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
    // Event data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Alyasa),
    // Fam data:
    pf: PF.Alyasa,
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
    // Event data:
    trValEra: 'i.Unknown'.tr,
    startMs:
        -800, // uncertain (8th century BCE or post-exilic period) in Wikipedia
    endMs: 0,
    asset: await _getImageEventAsset(PF.Yunus),
    // Fam data:
    pf: PF.Yunus,
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
    // Event data:
    trValEra: a('a.Masih'),
    startMs: 0,
    endMs: 0,
    asset: await _getImageEventAsset(PF.Zakariya),
    // Fam data:
    pf: PF.Zakariya,
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
    // Event data:
    trValEra: a('a.Masih'),
    startMs: -100,
    endMs: 28, // AD 28–36
    asset: await _getImageEventAsset(PF.Yahya),
    // Fam data:
    pf: PF.Yahya,
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
    // Event data:
    trValEra: a('a.Masih'),
    startMs: -4,
    endMs: 30,
    asset: await _getImageEventAsset(PF.Isa),
    // Fam data:
    pf: PF.Isa,
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
    // Event data:
    trValEra: a('a.Muhammad'), // Muhammad
    startMs: 570,
    endMs: 632,
    asset: await _getImageEventAsset(PF.Muhammad),
    // Fam data:
    pf: PF.Muhammad,
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
    // trValDaughters: [ // TODO Disable for now since UI gets too big
    //   PF.Zainab, //       cns('599–629 ') + a('a.Zainab'),
    //   PF.Ruqayyah, //     cns('601–624 ') + a('a.Ruqayyah'),
    //   PF.Umm_Kulthum, //  cns('603–630 ') + a('a.Umm Kulthum'),
    //   PF.Fatimah, //      cns('605–632 ') + a('a.Fatimah'),
    // ],
    sons: null,
    // trValSons: [
    //   // https://en.wikipedia.org/wiki/Muhammad%27s_children
    //   PF.Zayd_Ibn_Harithah, //    cns('581-629 ') + a('a.Zayd ibn Harithah'),
    //   PF.Qasim, //                cns('598–601 ') + a('a.Al-Qasim'),
    //   PF.Abdullah_Ibn_Muhmmad, // cns('611–613 ') + a('a.Abdullah'),
    //   PF.Ibrahim_Ibn_Muhmmad, //  cns('630–632 ') + a('a.Ibrahim'),
    // ],
    relatives: null,
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

Future<EventAsset> _getImageEventAsset(
  PF prophet, {
  double width = 200,
  double height = 200,
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
  /* TODO rename to AS (Aleyhi Salam) */
  Adam(Isim(
    trValHebrew: 'אדם (Adam)',
    trKeyHebrewMeaning: 'p.man',
    trValGreek: 'Αδάμ (Adam)',
    trValLatin: 'Adam',
  )),
  Idris(Isim(
    trValHebrew: 'חֲנוֹך (Hanokh)',
    trKeyHebrewMeaning: 'p.dedicated',
    trValGreek: 'Ἐνώχ (Enoch)',
    trValLatin: 'Enoch',
  )),
  Nuh(Isim(
    trValHebrew: 'נֹחַ (Noach)',
    trKeyHebrewMeaning: 'p.rest, repose',
    trValGreek: 'Νῶε (Noe)',
    trValLatin: null,
  )),
  Hud(Isim(
    trValHebrew: 'עבר (Eber)',
    trKeyHebrewMeaning: 'p.region beyond',
    trValGreek: null,
    trValLatin: null,
    trKeyNote: 'p.Possibly Eber or his son',
  )),
  Salih(Isim(
    trValHebrew: null, // TODO
    trValGreek: null,
    trValLatin: null,
    trKeyNote: 'p.Often attributed to biblical prophets',
  )),
  Ibrahim(Isim(
    trKeyLaqab: [
      'a.Khalilullah', // Friend of Allah
      'p.Father of Abrahimic faiths', // TODO
    ],
    trValHebrew: 'אַבְרָהָם (Abraham)',
    trKeyHebrewMeaning: 'p.many, multitude',
    trValGreek: 'Ἀβραάμ (Abraam)',
    trValLatin: 'Abraham',
  )), // İbrahim
  Lut(Isim(
    trValHebrew: 'לוֹט (Lot)',
    trKeyHebrewMeaning: 'p.covering, veil',
    trValGreek: null,
    trValLatin: null,
  )), // İsmail
  Ismail(Isim(
    trKeyLaqab: ['p.Father of the Arabs'], // TODO
    trValHebrew: 'יִשְׁמָעֵאל (Yishmael)',
    trKeyHebrewMeaning: 'p.God will hear',
    trValGreek: 'Ἰσμαήλ (Ismael)',
    trValLatin: 'Ismahel',
  )), // İshak
  Ishaq(Isim(
    trKeyLaqab: ['p.Father of the Hebrews/Jews'], // TODO
    trValHebrew: 'יִצְחָק (Yitzhaq)',
    trKeyHebrewMeaning: 'p.he will laugh, he will rejoice',
    trValGreek: 'Ισαάκ ()',
    trValLatin: 'Isaac',
  )),
  Yaqub(Isim(
    trKeyLaqab: [
      'a.Israel', //  إِسْرَآءِيل
      'p.Father of the 12 tribes of Israel',
    ],
    trValHebrew: 'יַעֲקֹב (Yaaqov)',
    trKeyHebrewMeaning:
        'p.Possibly "holder of the heel" or derived from "may God protect"',
    trValGreek: 'Ἰακώβ (Iakob)',
    trValLatin: 'Iacob',
  )), //  Yakub
  Yusuf(Isim(
    trValHebrew: 'יוֹסֵף (Yosef)',
    trKeyHebrewMeaning: 'p.he will add',
    trValGreek: 'Ἰωσήφ (Ioseph)',
    trValLatin: 'Ioseph',
  )),
  Ayyub(Isim(
    trValHebrew: 'אִיּוֹב (Iyyov)',
    trKeyHebrewMeaning: 'p.persecuted, hated',
    trValGreek: 'Ἰώβ (Iob)',
    trValLatin: 'Iob',
  )), // Eyyub
  DhulKifl(Isim(
//  trKeyAr: 'حزقيال', //?
    trValHebrew: 'יְחֶזְקֵאל (Yechezkel)',
    trKeyHebrewMeaning: 'p.God will strengthen',
    trValGreek: 'Ἰεζεκιήλ (Iezekiel)',
    trValLatin: 'Ezechiel, Hiezecihel',
    trKeyNote: 'p.Possibly Ezekiel, Buddha, Joshua, Obadiah or Isaiah',
  )), // Zülkifl
  Shuayb(Isim(
    trValHebrew: 'יִתְרוֹ (Yitro)',
    trKeyHebrewMeaning: 'p.abundance',
    trValGreek: null,
    trValLatin: 'Jethro',
    trKeyNote: 'p.Often thought to be Jethro, but this is highly disputed.',
  )), //  Şuayb
  Musa(Isim(
    trValHebrew: 'מֹשֶׁה (Moshe)',
    trKeyHebrewMeaning: 'p.Possibly from Egyptian "son" or Hebrew "deliver"',
    trValGreek: 'Μωϋσῆς (Mouses)',
    trValLatin: 'Moyses',
  )),
  Harun(Isim(
    trValHebrew: 'אַהֲרֹן (Aharon)',
    trKeyHebrewMeaning:
        'p.Possibly of Egyptian origin or from hebrew "high mountain" or "exalted"',
    trValGreek: 'Ἀαρών (Aaron)',
    trValLatin: 'Aaron',
  )),
  Dawud(Isim(
    trValHebrew: 'דָּוִד (Dawid)',
    trKeyHebrewMeaning: 'p.beloved',
    trValGreek: 'Δαυίδ (Dauid)',
    trValLatin: 'David',
  )), // Davud
  Suleyman(Isim(
    trValHebrew: 'שְׁלֹמֹה (Shelomoh)',
    trKeyHebrewMeaning: 'p.Derived from "peace" (שָׁלוֹם shalom)',
    trValGreek: 'Σαλωμών (Salomon)',
    trValLatin: 'Solomon',
  )), // Süleyman
  Ilyas(Isim(
    trValHebrew: 'אֱלִיָּהוּ (Eliyyahu), אֵלִיָה (Eliya)',
    trKeyHebrewMeaning: 'p.my God is Yahweh',
    trValGreek: 'Ηλίας (Ilias)',
    trValLatin: 'Elias',
  )), // İlyas
  Alyasa(Isim(
    trValHebrew: 'אֱלִישַׁע (Alysha\'e/Elisha)',
    trKeyHebrewMeaning: 'p.my God is salvation',
    trValGreek: 'Ἐλισαιέ (Elisaie)',
    trValLatin: 'Eliseus',
  )), // Elyesa
  Yunus(Isim(
    trKeyLaqab: ['a.Dhul-Nun'], // ذُو ٱلنُّوْن - The One of the Fish
    trValHebrew: 'יוֹנָה (Yonah)',
    trKeyHebrewMeaning: 'p.dove',
    trValGreek: 'Ἰωνᾶς (Ionas)',
    trValLatin: 'Ionas',
  )),
  Zakariya(Isim(
    trValHebrew: 'זְכַרְיָה (Zekharyah)',
    trKeyHebrewMeaning: 'p.God remembers',
    trValGreek: 'Ζαχαρίας (Zacharias)',
    trValLatin: 'Zaccharias',
  )),
  Yahya(Isim(
    trKeyLaqab: ['p.Christians call him "John the Babtist"'],
    trValHebrew: 'יוֹחָנָן (Yochanan)',
    trKeyHebrewMeaning: 'p.God is gracious',
    trValGreek: 'Ἰωάννης (Ioannes)',
    trValLatin: 'Iohannes',
  )),
  Isa(Isim(
    trKeyLaqab: ['a.Masih'], // Messiah
    trValAramaic: 'יֵשׁוּעַ (Ishoʿ)',
    trValGreek: 'Ιησους (Iesous)',
    trValLatin: 'Iesus',
  )),
  Muhammad(Isim(
    trKeyLaqab: [
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
  An__Nadr(Isim(trKeyLaqab: ['Quraysh'])),
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
    trKeyLaqab: ['Shaybah'],
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
