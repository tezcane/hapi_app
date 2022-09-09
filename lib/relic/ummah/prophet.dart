import 'package:get/get.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

const String _ = ' '; // space/gap

class Prophet extends Relic {
  Prophet({
    // TimelineEntry data:
    required trValEra,
    required String trKeyEndTagLabel,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,
    // Relic data:
    required RELIC_ID relicId,
    // Required prophet data:
    required this.trValBiblicalNames,
    required this.trValSentTo,
    required this.quranMentionCount,
    required this.qvNabi,
    // Optional prophet data:
    this.qvRasul,
    this.trValKitab,
    this.qvsUluAlAzm,
    this.trValLaqab, // Laqab - Nicknames
    this.trValLocationBirth,
    this.trValLocationDeath,
    this.trValTomb,
    this.trValPredecessor,
    this.trValSuccessor,
    this.trValMother,
    this.trValFather,
    this.trValSpouses,
    this.trValChildren,
    this.trValRelatives,
  }) : super(
          // TimelineEntry data:
          trValEra: trValEra,
          trKeyEndTagLabel: trKeyEndTagLabel,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          // Relic data:
          relicType: RELIC_TYPE.Prophet,
          relicId: relicId,
          trKeySummary: 'ps.$trKeyEndTagLabel', // ps=Prophet Summary
          trKeySummary2: 'pq.$trKeyEndTagLabel', // pq=Prophet Quran
        );
  // Required prophet data:
  final String trValBiblicalNames;
  final String trValSentTo; // nation the prophet was sent to:
  final int quranMentionCount;
  final QV qvNabi; // Prophet (nabī) نَبِيّ
  // Optional prophet data:
  final QV? qvRasul; //Messenger (rasūl) رَسُول
  final String? trValKitab;
  final List<QV>? qvsUluAlAzm; // Archprophet (ʾUlu Al-'Azm)
  final List<String>? trValLaqab;
  final String? trValLocationBirth;
  final String? trValLocationDeath;
  final String? trValTomb;
  final String? trValPredecessor;
  final String? trValSuccessor;
  final String? trValMother;
  final String? trValFather;
  final List<String>? trValSpouses;
  final List<String>? trValChildren;
  final List<String>? trValRelatives;

  bool isRasul() => qvRasul != null;
  bool isUluAlAzm() => qvsUluAlAzm != null && qvsUluAlAzm!.isNotEmpty;

  @override
  String get trValRelicSetTitle => a('a.Anbiya');
  @override
  List<RelicSetFilter> get relicSetFilters => [
        RelicSetFilter(
          type: FILTER_TYPE.Default,
          trValLabel: at('at.Mentioned in the {0}', [('a.Quran')]),
        ),
      ];
}

Future<List<Prophet>> init() async {
  List<Prophet> rv = [];

  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Birth of Humans'.tr,
    trKeyEndTagLabel: 'Adam',
    startMs: -3400000,
    endMs: -3399050,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Adam.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Adam,
    // Required prophet data:
    trValBiblicalNames: 'Adam',
    trValSentTo:
        a('a.Earth') + 'i._from_'.tr + a('a.Heaven') + _ + cns('(4:1)'),
    quranMentionCount: 25,
    qvNabi: QV(2, 31),
    // Optional prophet data:
    qvRasul: QV(2, 31),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: a('a.Jennah'),
    trValLocationDeath: null,
    trValTomb: null,
    trValPredecessor: null,
    trValSuccessor: null,
    trValMother: 'p.Created by Allah without a mother'.tr,
    trValFather: 'p.Created by Allah without a father'.tr,
    trValSpouses: [a('a.Hawwa')],
    trValChildren: [a('a.Habel'), a('a.Qabel'), a('a.Sheth'), a('a.Anaq')],
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Birth of Humans'.tr,
    trKeyEndTagLabel: 'Idris',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Idris.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Idris,
    // Required prophet data:
    trValBiblicalNames: 'Chanokh, Enoch',
    trValSentTo: a('a.Babylon'),
    quranMentionCount: 2,
    qvNabi: QV(19, 56),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: a('a.Babylon'),
    trValLocationDeath: 'p.Sixth Heaven'.tr,
    trValTomb: null,
    trValPredecessor: a('a.Sheth'),
    trValSuccessor: a('a.Nuh'),
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Great Flood'.tr,
    trKeyEndTagLabel: 'Nuh',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Nuh.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Nuh,
    // Required prophet data:
    trValBiblicalNames: 'Noach, Noe, Noah',
    trValSentTo: 'i.The people of_'.tr + a('a.Noah') + _ + cns('(26:105)'),
    quranMentionCount: 43,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(25, 107),
    trValKitab: null,
    qvsUluAlAzm: [QV(46, 35), QV(33, 7)],
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: null,
    trValPredecessor: a('a.Idris'),
    trValSuccessor: a('a.Hud'),
    trValMother: null,
    trValFather: null,
    trValSpouses: [a('a.Naamah')], // TODO find arabic name
    trValChildren: [a('a.Shem'), a('a.Ham'), a('a.Yam'), a('a.Japheth')],
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    trKeyEndTagLabel: 'Hud',
    startMs: -2400,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Hud.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Hud,
    // Required prophet data:
    trValBiblicalNames: 'p.Possibly Eber (Heber) or his son'.tr,
    trValSentTo: a('a.Ad') + _ + a('a.Tribe') + _ + cns('(7:65)'),
    quranMentionCount: 7,
    qvNabi: QV(26, 125),
    // Optional prophet data:
    qvRasul: QV(26, 125),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        'p.Several sites are revered as the tomb of Hud: Qabr Nabi Hud in Hadhramaut, Yemen; Near the Zamzam Well in Saudi Arabia; south wall of the Umayyad Mosque in Damascus, Syria.'
            .tr,
    trValPredecessor: a('a.Nuh'),
    trValSuccessor: a('a.Salih'),
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    trKeyEndTagLabel: 'Salih',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Salih.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Salih,
    // Required prophet data:
    trValBiblicalNames: 'p.Possibly Shelah, Selah, Sala'.tr,
    trValSentTo: a('a.Thamud') + _ + a('a.Tribe') + _ + cns('(7:73)'),
    quranMentionCount: 9,
    qvNabi: QV(26, 143),
    // Optional prophet data:
    qvRasul: QV(26, 143),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        "p.Possibly located in Mada'in Salih, Mecca. Also, another possible tomb is in Hasik, Oman."
            .tr,
    trValPredecessor: a('a.Hud'),
    trValSuccessor: a('a.Ibrahim'),
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: ['p.Possibly related to Eber (Heber)'.tr],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    trKeyEndTagLabel: 'Ibrahim',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Ibrahim.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Ibrahim,
    // Required prophet data:
    trValBiblicalNames: 'Avraham, Abraam, Abraham',
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
    trValLaqab: [a('a.Khalilullah')], // Friend of Allah
    trValLocationBirth: 'p.Ur al-Chaldees, Bilād ar-Rāfidayn'.tr,
    trValLocationDeath: 'a.Al-Khalil'.tr + // Hebron الخليل
        'i.,_'.tr +
        a('Bilad al-Sham'), // Greater Syria لبِلَاد الشَّام
    trValTomb: 'p.Ibrahimi Mosque, Hebron'.tr,
    trValPredecessor: null,
    trValSuccessor: at('p.His sons {0} and {1}', ['a.Ishaq', 'a.Ismail']),
    trValMother: a('a.Mahalath'),
    trValFather: a('a.Aazar'),
    trValSpouses: [a('a.Hajar'), a('a.Sarah')],
    trValChildren: [a('a.Ishaq'), a('a.Ismail')],
    trValRelatives: [
      at('p.{0} (Nephew)', [a('a.Lut')])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    trKeyEndTagLabel: 'Lut',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Lut.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Lut,
    // Required prophet data:
    trValBiblicalNames: 'Lot',
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
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: a(
        "a.Bani Na'im"), //  بني نعيم  Palestinian town in the southern West Bank located 8 kilometers (5.0 mi) east of Hebron.
    trValTomb: null,
    trValPredecessor: null,
    trValSuccessor: null,
    trValMother: null,
    trValFather: a('a.Haran'),
    trValSpouses: null,
    trValChildren: [
      'p.Possibly had two daughters, but the daughters referenced in the Quran could also mean the women of his nation.'
          .tr
    ],
    trValRelatives: [
      at('{0} (Uncle)', ['a.Ibrahim'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    trKeyEndTagLabel: 'Ismail',
    startMs: -1800,
    endMs: -1664,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Ismail.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Ismail,
    // Required prophet data:
    trValBiblicalNames: 'Yishmael, Ismael, Ismahel, Ishmael',
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
    trValLaqab: null,
    trValLocationBirth: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    trValLocationDeath:
        a('a.Makkah al-Mukarramah'), // Mecca مكة المكرمة 'Makkah the Noble',
    trValTomb: null,
    trValPredecessor: a('a.Ibrahim'),
    trValSuccessor: null,
    trValMother: a('a.Hajar'),
    trValFather: a('a.Ibrahim'),
    trValSpouses: null,
    trValChildren: ['p.Father of the Arab people'.tr],
    trValRelatives: [
      at('at.{0} (Half-Brother)', ['a.Ishaq'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Ibrahim'),
    trKeyEndTagLabel: 'Ishaq',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Ishaq.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Ishaq,
    // Required prophet data:
    trValBiblicalNames: 'Yitzhak, Itzhak, Isaak, Issac, Isaac',
    trValSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    quranMentionCount: 17,
    qvNabi: QV(19, 49),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
    trValPredecessor: a('a.Ibrahim'),
    trValSuccessor: null,
    trValMother: a('a.Sarah'),
    trValFather: a('a.Ibrahim'),
    trValSpouses: [
      a('a.Rebekah') // TODO find arabic word
    ],
    trValChildren: [
      a('a.Yaqub'),
      a('a.Al-Els'), //  Esau (in Hebrew)
      'p.Forefather of the 12 tribes of Israel'.tr
    ],
    trValRelatives: [
      at('{0} (Half-Brother)', ['a.Ismail'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Old Egyptian Kingdom'.tr,
    trKeyEndTagLabel: 'Yaqub',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Yaqub.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Yaqub,
    // Required prophet data:
    trValBiblicalNames: 'Yaakov, Iakob, Iacob, Jacob',
    trValSentTo: a('a.Falastin') + // فلسطين Palestine
        '/' +
        'i.Canaan'.tr,
    quranMentionCount: 16,
    qvNabi: QV(19, 49),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: [a('a.Israel')], //  إِسْرَآءِيل
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Cave of the Patriarchs, Hebron'.tr,
    trValPredecessor: null,
    trValSuccessor: a('a.Yusuf'),
    trValMother: a('a.Rafeqa'),
    trValFather: a('a.Ishaq'),
    trValSpouses: [a('a.Rahil'), a('a.Lea')], // TODO find Arabic
    trValChildren: [
      a('a.Yusuf'),
      a('a.Bunyamin'),
      'p.And ten others, Father of the 12 tribes of Israel'.tr,
    ],
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Old Egyptian Kingdoms'.tr,
    trKeyEndTagLabel: 'Yusuf',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Yusuf.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Yusuf,
    // Required prophet data:
    trValBiblicalNames: 'Yosef, Iosef, Ioseph, Joseph',
    trValSentTo: 'p.Ancient Kingdom of_'.tr + a('a.Misr'), // Egypt
    quranMentionCount: 27,
    qvNabi: QV(4, 89),
    // Optional prophet data:
    qvRasul: QV(40, 34),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: null,
    trValPredecessor: a('a.Yaqub'),
    trValSuccessor: null,
    trValMother: a('a.Rahil'), // TODO Biblical Latin: Rahel, Rachel
    trValFather: a('a.Yaqub'),
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: [
      at('p.{0} (Father)', ['a.Yaqub']),
      at('p.{0} (Brother)', ['a.Bunyamin']),
      'p.And ten other brothers from the 12 tribes of Israel'.tr,
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    trKeyEndTagLabel: 'Ayyub',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Ayyub.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Ayyub,
    // Required prophet data:
    trValBiblicalNames: 'Iyyov, Iyov, Iob, Job',
    trValSentTo: a('a.Edom'), // TODO Arabee version
    quranMentionCount: 4,
    qvNabi: QV(4, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Al-Qarah Mountains in southern Oman'.tr,
    trValPredecessor: null,
    trValSuccessor: null,
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: ['p.Probably a descendant of Al-Els, son of Ishaq'.tr],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    trKeyEndTagLabel: 'Shuayb',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Shuayb.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Shuayb,
    // Required prophet data:
    trValBiblicalNames: 'p.None (Absent from Bible)'.tr,
    trValSentTo: a('a.Madyan') + // Midian
        _ +
        cns('(7:85)'),
    quranMentionCount: 9,
    qvNabi: QV(26, 178),
    // Optional prophet data:
    qvRasul: QV(26, 178),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        'p.Possibly in Wadi Shuʿayb, Jordan, Guriyeh, Shushtar, Iran or Hittin in the Galilee'
            .tr,
    trValPredecessor: a('a.Ayyub'),
    trValSuccessor: a('a.Musa'),
    trValMother: null,
    trValFather: a('a.Mikil'), // TODO find arabic
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: ['p.Descendant of_'.tr + a('a.Ibrahim')],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    trKeyEndTagLabel: 'Musa',
    startMs: -1300,
    endMs: -1200,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Musa.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Musa,
    // Required prophet data:
    trValBiblicalNames: 'Moshe, Mouses, Moyses, Moses',
    trValSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 136,
    qvNabi: QV(20, 47),
    // Optional prophet data:
    qvRasul: QV(20, 47),
    trValKitab: 'p.Ten Commandments, Tawrah (Torah); Scrolls of Moses (53:36)',
    qvsUluAlAzm: [QV(46, 35), QV(33, 7)],
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.An-Nabi Musa, Jericho'.tr, // ٱلنَّبِي مُوْسَى
    trValPredecessor: a('a.Shuayb'),
    trValSuccessor: a('a.Harun'),
    trValMother: a('a.Yukabid') + //يوكابد Latin: Jochebed
        // Other possible names are Ayaarkha or Ayaathakht (Ibn Katheer), Lawha (Al-Qurtubi) and Yoohaana (Ibn 'Atiyyah)
        'p._was his birth mother and his foster mother was_' +
        a('a.Asiya'), //يوكابد
    trValFather: a('a.Imran'), // عمران
    trValSpouses: [a('a.Saffurah')], // صفورة
    trValChildren: null,
    trValRelatives: [
      at('p.{0} (Brother)', ['a.Harun']),
      at('p.{0} (Sister that followed Musa down river)', ['a.Miriam']),
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
    trKeyEndTagLabel: 'Harun',
    startMs: -1303,
    endMs: -1200,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Harun.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Harun,
    // Required prophet data:
    trValBiblicalNames: 'Aharon, Aaron',
    trValSentTo: a('a.Firaun') + // Pharaoh فرعون
        'p._and his establishment_' +
        cns('(43:46)'),
    quranMentionCount: 20,
    qvNabi: QV(19, 53),
    // Optional prophet data:
    qvRasul: QV(20, 47),
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Jabal Harun, Jordan or in Sinai'.tr,
    trValPredecessor: a('p.Musa'),
    trValSuccessor: 'p.Possibly_'.tr + a('a.Dawud'),
    trValMother: a('a.Yukabid'),
    trValFather: a('a.Imran'), // عمران
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: [
      at('p.{0} (Brother)', ['a.Musa'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Start of Buddhism'.tr,
    trKeyEndTagLabel: 'Dhul-Kifl',
    startMs: -600, // TODO Buddha: 6th or 5th century BCE
    endMs: -500,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_DhulKifl.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_DhulKifl,
    // Required prophet data:
    trValBiblicalNames:
        'p.Possibly Buddha, Ezekiel, Joshua, Obadiah or Isaiah'.tr,
    // TODO Kifl or Kapilavastu in the northern Indian subcontinent:
    trValSentTo: 'p.Possibly India subcontinent or_'.tr + a('a.Babylon'),
    quranMentionCount: 2,
    qvNabi: QV(21, 85, ayaEnd: 86),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Makam Dağı in Ergani province of Diyarbakir'.tr +
        'i.,_'.tr +
        a('a.Turkiye'),
    trValPredecessor: null,
    trValSuccessor: null,
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    trKeyEndTagLabel: 'Dawud',
    startMs: -1000,
    endMs: -971,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Dawud.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Dawud,
    // Required prophet data:
    trValBiblicalNames: 'Dawid, Dauid, David',
    trValSentTo: a('a.Al-Quds'), // Jerusalem - القدس
    quranMentionCount: 16,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: QV(6, 89),
    trValKitab: a('a.Zabur') + // Psalms
        _ +
        cns('(17:55, 4:163, 17:55, 21:105)'),
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: a('a.Al-Quds'),
    trValLocationDeath: a('a.Al-Quds'),
    trValTomb: 'p.Tomb of Harun, Jabal HarUn in Petra, Jordan'.tr,
    trValPredecessor:
        'p.In kingship: Possibly Talut (Saul), in prophethood: Samuil (Samuel)'
            .tr,
    trValSuccessor: 'a.Suleyman',
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: [a('a.Suleyman')],
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'),
    trKeyEndTagLabel: 'Suleyman',
    startMs: -971,
    endMs: -931,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Suleyman.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Suleyman,
    // Required prophet data:
    trValBiblicalNames: 'Shelomoh, Salomon, Solomon',
    trValSentTo: a('a.Al-Quds'),
    quranMentionCount: 17,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    trValLocationDeath:
        a('a.United') + _ + 'p.Kingdom of Israel in_'.tr + a('a.Al-Quds'),
    trValTomb: 'p.Al-Ḥaram ash-Sharīf, Jerusalem'.tr,
    trValPredecessor: null,
    trValSuccessor: null,
    trValMother: null,
    trValFather: a('a.Dawud'),
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    trKeyEndTagLabel: 'Ilyas',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Ilyas.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Ilyas,
    // Required prophet data:
    trValBiblicalNames: 'Eliya, Eliou, Elias, Ilias, Elijah',
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
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Possibly in Baalbek, Lebanon'.tr,
    trValPredecessor: a('a.Suleyman'),
    trValSuccessor: a('a.Alyasa'),
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
    trKeyEndTagLabel: 'Alyasa',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Alyasa.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Alyasa,
    // Required prophet data:
    trValBiblicalNames: 'Elishua, Elisaie, Eliseus, Elisha',
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
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Eğil district of Diyarbakir Province'.tr +
        'i.,_'.tr +
        a('a.Turkiye'), //' or Al-Awjam, Saudi Arabia.'
    trValPredecessor: a('a.Ilyas'),
    trValSuccessor: a('a.Yunus'),
    trValMother: null,
    trValFather: null,
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Unknown'.tr,
    trKeyEndTagLabel: 'Yunus',
    startMs:
        -800, // uncertain (8th century BCE or post-exilic period) in Wikipedia
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Yunus.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Yunus,
    // Required prophet data:
    trValBiblicalNames: 'Yonah, Yona, Iona, Ionas, Jonas, Jonah',
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
    trValLaqab: [a('a.Dhul-Nun')], // ذُو ٱلنُّوْن - The One of the Fish
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb:
        "p.Possibly at the Mosque of Yunus, Mosul, Iraq, Mashhad Village Gath-hepher, Israel; Halhul, Palestinian West Bank; Sarafand, Lebanon; Giv'at Yonah (Jonah's Hill) in Ashdod, Israel, near Fatih Pasha Mosque in Diyarbakir"
                .tr +
            'i.,_'.tr +
            a('a.Turkiye'),
    trValPredecessor: a('a.Alyasa'),
    trValSuccessor: a('a.Zakariya'),
    trValMother: null,
    trValFather: a('a.Matta'), // متى - Amittai latin
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    trKeyEndTagLabel: 'Zakariya',
    startMs: 0,
    endMs: 0,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Zakariya.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Zakariya,
    // Required prophet data:
    trValBiblicalNames:
        'Zekharyah, Zacharias, Zaccharias, Zechariah, Zachariah',
    trValSentTo: a('a.Al-Quds'),
    quranMentionCount: 7,
    qvNabi: QV(6, 89),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: null,
    trValTomb: 'p.Great Mosque of Aleppo, Syria'.tr,
    trValPredecessor: a('a.Yunus'),
    trValSuccessor: a('a.Yahya'),
    trValMother: null,
    trValFather: null,
    trValSpouses: [
      a('a.Ishba') + //Elizabeth', // TODO find arabic
          at('p._Barren all her life until miracle birth of {0} in her old age.',
              ['a.Yahya']),
    ],
    trValChildren: ['a.Yahya'],
    trValRelatives: null,
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    trKeyEndTagLabel: 'Yahya',
    startMs: -100,
    endMs: 28, // AD 28–36
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Yahya.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Yahya,
    // Required prophet data:
    trValBiblicalNames: 'Yochanan, Ioannes, Iohannes, John',
    trValSentTo:
        at('p.{0} of {1} in {2}', ['a.Children', 'a.Israel', 'a.Al-Quds']),
    quranMentionCount: 5,
    qvNabi: QV(3, 39),
    // Optional prophet data:
    qvRasul: null,
    trValKitab: null,
    qvsUluAlAzm: null,
    trValLaqab: null,
    trValLocationBirth: null,
    trValLocationDeath: 'p.Decapitated by the ruler Herod Antipas'.tr,
    trValTomb: 'p.His head is possibly at the Umayyad Mosque in Damascus'.tr,
    trValPredecessor: a('a.Zakariya'),
    trValSuccessor: a('a.Isa'),
    trValMother: a('a.Ishba') + //Elizabeth', // TODO find arabic
        at('p. (Barren all her life until miracle birth of {0} in her old age.',
            ['a.Yahya']),
    trValFather: a('a.Zakariya'),
    trValSpouses: null,
    trValChildren: null,
    trValRelatives: [
      at('p.{0} (Cousin)', ['a.Isa'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Masih'),
    trKeyEndTagLabel: 'Isa',
    startMs: -4,
    endMs: 30,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Isa.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Isa,
    // Required prophet data:
    trValBiblicalNames: 'Yeshua, Iesous, Iesus, Iosue, Jesus',
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
    trValLaqab: [a('a.Masih')], // Messiah
    trValLocationBirth: 'p.Judea, Roman Empire'.tr,
    trValLocationDeath:
        'p.Still alive, was raised to Heaven from_'.tr + a('a.Falastin'),
    trValTomb: 'p.None yet'.tr,
    trValPredecessor: a('a.Yahya'),
    trValSuccessor: a('a.Muhammad'),
    trValMother: a('a.Maryam'),
    trValFather: 'p.Created by Allah without a father',
    trValSpouses: ['p.None yet'.tr],
    trValChildren: ['p.None yet'.tr],
    trValRelatives: [
      at('p.{0} (Uncle)', ['a.Zakariya']),
      at('p.{0} (Cousin)', ['a.Yahya'])
    ],
  ));
  rv.add(Prophet(
    // TimelineEntry data:
    trValEra: a('a.Muhammad'), // Muhammad
    trKeyEndTagLabel: 'Muhammad',
    startMs: 570,
    endMs: 632,
    asset: await TarikhC.tih.loadImageAsset(
        'assets/images/anbiya/${RELIC_ID.Prophet_Muhammad.name.split('_')[1]}.png',
        528,
        528,
        -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Muhammad,
    // Required prophet data:
    trValBiblicalNames: 'Muhammad-im (מחמד' + // no tr here
        'p. - Hebrew) as written in Song of Songs 5:16'.tr, // just tr here
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
    trValLocationBirth: a(DAY_OF_WEEK.Monday.trKey) +
        'i.,_'.tr +
        cni(12) +
        _ +
        a("a.Rabi' Al-Thani") +
        _ +
        cni(53) +
        a('i.BH') +
        '/' +
        cni(570) +
        a('i.AD') +
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
        a('i.AH') +
        '/' +
        cni(632) +
        a('i.AD') +
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
    trValPredecessor: a('a.Isa'),
    trValSuccessor: at(
        'p.No more prophets, however, {0} and {1} will follow {3}',
        ['a.Mahdi', 'a.Isa', 'a.Islam']),
    trValMother: a('a.Amina bint Wahb'), // آمِنَة ٱبْنَت وَهْب
    trValFather: a(
        'a.Abdullah ibn Abd al-Muttalib'), // عَبْد ٱللَّٰه ٱبْن عَبْد ٱلْمُطَّلِب
    trValSpouses: [
      // TODO Link to RELIC_TYPE.Bayt:
      //https://en.wikipedia.org/wiki/Muhammad%27s_wives
      //https://www.quora.com/After-the-death-of-Prophet-Muhammad-which-of-his-wives-died-first
      cns('595–619: ') + a('a.Khadijah'),
      cns('619–632: ') + a('a.Sawdah'),
      cns('623–632: ') + a('a.Aisha'), //- Only virgin',
      cns('625–632: ') + a('a.Hafsah'),
      cns('625–626: ') + a('a.Umm al-Masakin'),
      cns('625–632: ') + a('a.Umm Salamah'),
      cns('627–632: ') + a('a.Zaynab'),
      cns('628–632: ') + a('a.Juwayriyah'),
      cns('628–632: ') + a('a.Umm Habibah'),
      cns('629–632: ') + a('a.Safiyyah'),
      cns('629–632: ') + a('a.Maymunah'),
      cns('627–631: ') + a('a.Rayhana'), // concubine later married?
      cns('628–632: ') + a('a.Maria'), // concubine later married?
    ],
    trValChildren: [
      // TODO Link to RELIC_TYPE.Bayt:
      // https://en.wikipedia.org/wiki/Muhammad%27s_children
      cns('581-629 ') + a('a.Zayd ibn Harithah'), // زَيْد ٱبْن حَارِثَة
      cns('598–601 ') + a('a.Al-Qasim'),
      cns('599–629 ') + a('a.Zainab'),
      cns('601–624 ') + a('a.Ruqayyah'),
      cns('603–630 ') + a('a.Umm Kulthum'),
      cns('605–632 ') + a('a.Fatimah'),
      cns('611–613 ') + a('a.Abdullah'),
      cns('630–632 ') + a('a.Ibrahim'),
    ],
    trValRelatives: null,
  ));

  return rv;
}
