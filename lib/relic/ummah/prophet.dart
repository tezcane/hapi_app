import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
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
    required int ajrLevel,
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
    this.tomb,
    this.predecessorAr,
    this.successorAr,
    this.motherAr,
    this.fatherAr,
    this.spousesAr,
    this.childrenAr,
    this.relativesAr,
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
          ajrLevel: ajrLevel,
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
  final String? tomb;
  final String? predecessorAr;
  final String? successorAr;
  final String? motherAr;
  final String? fatherAr;
  final List<String>? spousesAr;
  final List<String>? childrenAr;
  final List<String>? relativesAr;

  bool isRasul() => qvRasul != null;
  bool isUluAlAzm() => qvsUluAlAzm != null && qvsUluAlAzm!.isNotEmpty;
}

List<Prophet> prophets = [];
initProphets(Map<int, int> ajrLevels) async {
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Birth of Humans'.tr,
      trKeyEndTagLabel: 'Adam',
      startMs: -3400000,
      endMs: -3399050,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Adam.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Adam,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Adam.index]!,
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
      tomb: null,
      predecessorAr: null,
      successorAr: null,
      motherAr: 'p.Created by Allah without a mother',
      fatherAr: 'p.Created by Allah without a father',
      spousesAr: ['a.Hawwa'],
      childrenAr: ['a.Habel', 'a.Qabel', 'a.Sheth', 'a.Anaq'],
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Birth of Humans'.tr,
      trKeyEndTagLabel: 'Idris',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Idris.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Idris,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Idris.index]!,
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
      tomb: null,
      predecessorAr: 'p.Sheth',
      successorAr: 'p.Nuh',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Great Flood'.tr,
      trKeyEndTagLabel: 'Nuh',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Nuh.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Nuh,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Nuh.index]!,
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
      tomb: null,
      predecessorAr: 'a.Idris',
      successorAr: 'a.Hud',
      motherAr: null,
      fatherAr: null,
      spousesAr: ['p.Naamah'], // TODO find arabic name
      childrenAr: ['a.Shem', 'a.Ham', 'a.Yam', 'a.Japheth'],
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Unknown'.tr,
      trKeyEndTagLabel: 'Hud',
      startMs: -2400,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Hud.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Hud,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Hud.index]!,
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
      tomb:
          'p.Several sites are revered as the tomb of Hud: Qabr Nabi Hud in Hadhramaut, Yemen; Near the Zamzam Well in Saudi Arabia; south wall of the Umayyad Mosque in Damascus, Syria.',
      predecessorAr: 'a.Nuh',
      successorAr: 'a.Salih',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Unknown'.tr,
      trKeyEndTagLabel: 'Salih',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Salih.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Salih,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Salih.index]!,
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
      tomb:
          "p.Possibly located in Mada'in Salih, Mecca. Also, another possible tomb is in Hasik, Oman.",
      predecessorAr: 'a.Hud',
      successorAr: 'a.Ibrahim',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: ['p.Possibly related to Eber (Heber)']));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Ibrahim'),
      trKeyEndTagLabel: 'Ibrahim',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Ibrahim.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Ibrahim,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Ibrahim.index]!,
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
      tomb: 'p.Ibrahimi Mosque, Hebron',
      predecessorAr: null,
      successorAr: at('p.His sons {0} and {1}', ['a.Ishaq', 'a.Ismail']),
      motherAr: 'a.Mahalath',
      fatherAr: 'a.Aazar',
      spousesAr: ['a.Hajar', 'a.Sarah'],
      childrenAr: ['a.Ishaq', 'a.Ismail'],
      relativesAr: [
        at('p.{0} (Nephew)', ['a.Lut'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Ibrahim'),
      trKeyEndTagLabel: 'Lut',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Lut.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Lut,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Lut.index]!,
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
      tomb: null,
      predecessorAr: null,
      successorAr: null,
      motherAr: null,
      fatherAr: 'p.Haran',
      spousesAr: null,
      childrenAr: [
        'p.Possibly had two daughters, but the daughters referenced in the Quran could also mean the women of his nation.'
            .tr
      ],
      relativesAr: [
        'p.Ibrahim (Uncle)'
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Ibrahim'),
      trKeyEndTagLabel: 'Ismail',
      startMs: -1800,
      endMs: -1664,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Ismail.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Ismail,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Ismail.index]!,
      // Required prophet data:
      trValBiblicalNames: 'Yishmael, Ismael, Ismahel, Ishmael',
      trValSentTo: 'p.Pre-Islamic_' +
          a('a.Arabia') +
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
      tomb: null,
      predecessorAr: 'a.Ibrahim',
      successorAr: null,
      motherAr: 'a.Hajar',
      fatherAr: 'a.Ibrahim',
      spousesAr: null,
      childrenAr: [
        'p.Father of the Arab people'
      ],
      relativesAr: [
        at('at.{0} (Half-Brother)', ['p.Ishaq'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Ibrahim'),
      trKeyEndTagLabel: 'Ishaq',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Ishaq.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Ishaq,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Ishaq.index]!,
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
      tomb: 'p.Cave of the Patriarchs, Hebron',
      predecessorAr: 'a.Ibrahim',
      successorAr: null,
      motherAr: 'a.Sarah',
      fatherAr: 'a.Ibrahim',
      spousesAr: [
        'a.Rebekah?' // TODO find arabic word
      ],
      childrenAr: [
        'a.Yaqub',
        'a.Al-Els', //  Esau (in Hebrew)
        'p.Forefather of the 12 tribes of Israel'
      ],
      relativesAr: [
        at('{0} (Half-Brother)', ['a.Ismail'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Old Egyptian Kingdom'.tr,
      trKeyEndTagLabel: 'Yaqub',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Yaqub.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Yaqub,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Yaqub.index]!,
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
      tomb: 'p.Cave of the Patriarchs, Hebron',
      predecessorAr: null,
      successorAr: 'a.Yusuf',
      motherAr: 'a.Rafeqa',
      fatherAr: 'a.Ishaq',
      spousesAr: ['a.Rahil?', 'a.Lea?'], // TODO find Arabic
      childrenAr: [
        'a.Yusuf',
        'a.Bunyamin',
        'p.And ten others, Father of the 12 tribes of Israel',
      ],
      relativesAr: null));
  prophets.add(Prophet(
    // TimelineEntry data:
    trValEra: 'i.Old Egyptian Kingdoms'.tr,
    trKeyEndTagLabel: 'Yusuf',
    startMs: 0,
    endMs: 0,
    asset: await TarikhController.tih.loadImageAsset(
        '${RELIC_ID.Prophet_Yusuf.name.split('_')[1]}.png', 528, 528, -40),
    // Relic data:
    relicId: RELIC_ID.Prophet_Yusuf,
    ajrLevel: ajrLevels[RELIC_ID.Prophet_Yusuf.index]!,
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
    tomb: null,
    predecessorAr: 'a.Yaqub',
    successorAr: null,
    motherAr: 'a.Rahil?', // Biblical Latin: Rahel, Rachel
    fatherAr: 'a.Yaqub',
    spousesAr: null,
    childrenAr: null,
    relativesAr: [
      at('p.{0} (Father)', ['a.Yaqub']),
      at('p.{0} (Brother)', ['a.Bunyamin']),
      'p.And ten other brothers from the 12 tribes of Israel',
    ],
  ));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Unknown'.tr,
      trKeyEndTagLabel: 'Ayyub',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Ayyub.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Ayyub,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Ayyub.index]!,
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
      tomb: 'p.Possibly in Al-Qarah Mountains in southern Oman',
      predecessorAr: null,
      successorAr: null,
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: ['Probably a descendant of Al-Els, son of Ishaq.']));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Unknown'.tr,
      trKeyEndTagLabel: 'Shuayb',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Shuayb.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Shuayb,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Shuayb.index]!,
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
      tomb:
          'Possibly in Wadi Shuʿayb, Jordan, Guriyeh, Shushtar, Iran or Hittin in the Galilee.',
      predecessorAr: 'a.Ayyub',
      successorAr: 'a.Musa',
      motherAr: null,
      fatherAr: 'a.Mikil?', // TODO find arabic
      spousesAr: null,
      childrenAr: null,
      relativesAr: ['p.Descendant of Ibrahim']));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
      trKeyEndTagLabel: 'Musa',
      startMs: -1300,
      endMs: -1200,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Musa.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Musa,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Musa.index]!,
      // Required prophet data:
      trValBiblicalNames: 'Moshe, Mouses, Moyses, Moses',
      trValSentTo: a('a.Firaun') + // Pharaoh فرعون
          'p._and his establishment_' +
          cns('(43:46)'),
      quranMentionCount: 136,
      qvNabi: QV(20, 47),
      // Optional prophet data:
      qvRasul: QV(20, 47),
      trValKitab:
          'p.Ten Commandments, Tawrah (Torah); Scrolls of Moses (53:36)',
      qvsUluAlAzm: [QV(46, 35), QV(33, 7)],
      trValLaqab: null,
      trValLocationBirth: null,
      trValLocationDeath: null,
      tomb: 'p.An-Nabi Musa, Jericho', // ٱلنَّبِي مُوْسَى
      predecessorAr: 'a.Shuayb',
      successorAr: 'a.Harun',
      motherAr: a('a.Yukabid') + //يوكابد Latin: Jochebed
          "p.. Other possible names are Ayaarkha or Ayaathakht (Ibn Katheer), Lawha (Al-Qurtubi) and Yoohaana (Ibn 'Atiyyah)."
              .tr +
          'p.. His foster mother was ' +
          a('a.Asiya'), //يوكابد
      fatherAr: 'a.Imran', // عمران
      spousesAr: ['a.Saffurah'], // صفورة
      childrenAr: null,
      relativesAr: [
        at('p.{0} (Brother)', ['a.Harun']),
        at('p.{0} (Sister that followed Musa down river)', ['a.Miriam']),
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Firaun') + 'i._New_Kingdoms of_'.tr + a('a.Misr'), // Egypt
      trKeyEndTagLabel: 'Harun',
      startMs: -1303,
      endMs: -1200,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Harun.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Harun,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Harun.index]!,
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
      tomb: 'Possibly in Jabal Harun, Jordan or in Sinai.',
      predecessorAr: 'p.Musa',
      successorAr: null, // TODO 'p.Possibly '.tr + a('a.Dawud'),?
      motherAr: a('a.Yukabid') + //يوكابد
          "p.. Other possible names are Ayaarkha or Ayaathakht (Ibn Katheer), Lawha (Al-Qurtubi) and Yoohaana (Ibn 'Atiyyah)."
              .tr,
      fatherAr: 'a.Imran', // عمران
      spousesAr: null,
      childrenAr: null,
      relativesAr: [
        at('p.{0} (Brother)', ['a.Musa'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Start of Buddhism'.tr,
      trKeyEndTagLabel: 'Dhul-Kifl',
      startMs: -600, // TODO Buddha: 6th or 5th century BCE
      endMs: -500,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_DhulKifl.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_DhulKifl,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_DhulKifl.index]!,
      // Required prophet data:
      trValBiblicalNames:
          'p.Possibly Buddha, Ezekiel, Joshua, Obadiah or Isaiah'.tr,
      trValSentTo: 'p.Possibly India subcontinent or_'.tr +
          a('a.Babylon'), // TODO Kifl or Kapilavastu in the northern Indian subcontinent
      quranMentionCount: 2,
      qvNabi: QV(21, 85, ayaEnd: 86),
      // Optional prophet data:
      qvRasul: null,
      trValKitab: null,
      qvsUluAlAzm: null,
      trValLaqab: null,
      trValLocationBirth: null,
      trValLocationDeath: null,
      tomb: 'p.Makam Dağı in Ergani province of Diyarbakir,_' + a('a.Turkiye'),
      predecessorAr: null,
      successorAr: null,
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Kings of_'.tr + a('a.Israel'),
      trKeyEndTagLabel: 'Dawud',
      startMs: -1000,
      endMs: -971,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Dawud.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Dawud,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Dawud.index]!,
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
      tomb: 'Tomb of Aaron',
      predecessorAr:
          'p.In kingship: Talut? (Saul?), in prophethood: Samuil? (Samuel?)',
      successorAr: 'a.Suleyman',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: ['a.Suleyman'],
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Kings of_'.tr + a('a.Israel'),
      trKeyEndTagLabel: 'Suleyman',
      startMs: -971,
      endMs: -931,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Suleyman.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Suleyman,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Suleyman.index]!,
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
      tomb: 'Al-Ḥaram ash-Sharīf, Jerusalem',
      predecessorAr: null,
      successorAr: null,
      motherAr: null,
      fatherAr: 'a.Dawud',
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
      trKeyEndTagLabel: 'Ilyas',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Ilyas.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Ilyas,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Ilyas.index]!,
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
      tomb: 'Possibly in Baalbek, Lebanon',
      predecessorAr: 'a.Suleyman',
      successorAr: 'a.Alyasa',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Kings of_'.tr + a('a.Israel'), // TODO unsure
      trKeyEndTagLabel: 'Alyasa',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Alyasa.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Alyasa,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Alyasa.index]!,
      // Required prophet data:
      trValBiblicalNames: 'Elishua, Elisaie, Eliseus, Elisha',
      trValSentTo: a('a.Samaria') + //  TODO
          'i.,_'.tr +
          a('a.East') +
          _ +
          a('a.Arabia') +
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
      tomb: 'p.Eğil district of Diyarbakir Province'.tr +
          'i.,_'.tr +
          a('a.Turkiye'), //' or Al-Awjam, Saudi Arabia.'
      predecessorAr: 'a.Ilyas',
      successorAr: 'a.Yunus',
      motherAr: null,
      fatherAr: null,
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: 'i.Unknown'.tr,
      trKeyEndTagLabel: 'Yunus',
      startMs:
          -800, // uncertain (8th century BCE or post-exilic period) in Wikipedia
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Yunus.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Yunus,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Yunus.index]!,
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
      tomb:
          "p.Possibly at the Mosque of Yunus, Mosul, Iraq, Mashhad Village Gath-hepher, Israel; Halhul, Palestinian West Bank; Sarafand, Lebanon; Giv'at Yonah (Jonah's Hill) in Ashdod, Israel, near Fatih Pasha Mosque in Diyarbakir,_" +
              a('a.Turkiye'),
      predecessorAr: 'p.Alyasa',
      successorAr: 'a.Zakariya',
      motherAr: null,
      fatherAr: 'a.Matta', // متى - Amittai latin
      spousesAr: null,
      childrenAr: null,
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Masih'),
      trKeyEndTagLabel: 'Zakariya',
      startMs: 0,
      endMs: 0,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Zakariya.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Zakariya,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Zakariya.index]!,
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
      tomb: 'Great Mosque of Aleppo, Syria',
      predecessorAr: 'a.Yunus',
      successorAr: 'a.Yahya',
      motherAr: null,
      fatherAr: null,
      spousesAr: [
        a('a.Ishba') + //Elizabeth', // TODO find arabic
            at('p. (Barren all her life until miracle birth of {0} in her old age.',
                ['a.Yahya']),
      ],
      childrenAr: ['a.Yahya'],
      relativesAr: null));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Masih'),
      trKeyEndTagLabel: 'Yahya',
      startMs: -100,
      endMs: 28, // AD 28–36
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Yahya.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Yahya,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Yahya.index]!,
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
      tomb: 'His head is possibly at the Umayyad Mosque in Damascus',
      predecessorAr: 'a.Zakariya',
      successorAr: 'a.Isa',
      motherAr: a('a.Ishba') + //Elizabeth', // TODO find arabic
          at('p. (Barren all her life until miracle birth of {0} in her old age.',
              ['a.Yahya']),
      fatherAr: 'a.Zakariya',
      spousesAr: null,
      childrenAr: null,
      relativesAr: [
        at('p.{0} (Cousin)', ['a.Isa'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Masih'),
      trKeyEndTagLabel: 'Isa',
      startMs: -4,
      endMs: 30,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Isa.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Isa,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Isa.index]!,
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
      tomb: 'p.None yet',
      predecessorAr: 'a.Yahya',
      successorAr: 'a.Muhammad',
      motherAr: 'a.Maryam',
      fatherAr: 'p.Created by Allah without a father',
      spousesAr: ['p.None yet'],
      childrenAr: ['p.None yet'],
      relativesAr: [
        at('p.{0} (Uncle)', ['a.Zakariya']),
        at('p.{0} (Cousin)', ['a.Yahya'])
      ]));
  prophets.add(Prophet(
      // TimelineEntry data:
      trValEra: a('a.Muhammad'), // Muhammad
      trKeyEndTagLabel: 'Muhammad',
      startMs: 570,
      endMs: 632,
      asset: await TarikhController.tih.loadImageAsset(
          '${RELIC_ID.Prophet_Muhammad.name.split('_')[1]}.png', 528, 528, -40),
      // Relic data:
      relicId: RELIC_ID.Prophet_Muhammad,
      ajrLevel: ajrLevels[RELIC_ID.Prophet_Muhammad.index]!,
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
          a('a.Medina') +
          'i.,_'.tr +
          a('a.Hejaz') +
          'i.,_'.tr +
          a('a.Arabia'),
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
          a('a.Aliathnayn') +
          'i.,_'.tr +
          a('a.Medina') +
          'i.,_'.tr +
          a('a.Hejaz') +
          'i.,_'.tr +
          a('a.Arabia'),
      tomb: at('p.Green Dome in {0}, {1}, Saudi Arabia',
          ['a.Al-Masjid an-Nabawi', 'a.Medina']), //المسجد النبوي
      predecessorAr: 'a.Isa',
      successorAr: at(
          'p.No more prophets, however, {0} and {1} will follow Islam',
          ['a.Mahdi', 'a.Isa']),
      motherAr: 'a.Amina bint Wahb', // آمِنَة ٱبْنَت وَهْب
      fatherAr:
          'a.Abdullah ibn Abd al-Muttalib', // عَبْد ٱللَّٰه ٱبْن عَبْد ٱلْمُطَّلِب
      spousesAr: [
        //https://en.wikipedia.org/wiki/Muhammad%27s_wives
        //https://www.quora.com/After-the-death-of-Prophet-Muhammad-which-of-his-wives-died-first
        '(595–619) Khadijah',
        '(619–632) Sawdah',
        '(623–632) Aisha', //- Only virgin',
        '(625–632) Hafsah',
        '(625–626) Umm al-Masakin',
        '(625–632) Umm Salamah',
        '(627–632) Zaynab',
        '(628–632) Juwayriyah',
        '(628–632) Umm Habibah',
        '(629–632) Safiyyah',
        '(629–632) Maymunah',
        '(627–631) Rayhana', // concubine later married?
        '(628–632) Maria', // concubine later married?
      ],
      childrenAr: [
        // https://en.wikipedia.org/wiki/Muhammad%27s_children
        '(581-629) Zayd ibn Harithah - Foster child mentioned in the Quran', //زَيْد ٱبْن حَارِثَة
        '(598–601) Al-Qasim - Son of Khadija',
        '(599–629) Zainab - Daughter of Khadija',
        '(601–624) Ruqayyah - Daughter of Khadija',
        '(603–630) Umm Kulthum - Daughter of Khadija',
        '(605–632) Fatimah - Daughter of Khadija',
        '(611–613) Abdullah - Son of Khadija',
        '(630–632) Ibrahim - Son of Maria al-Qibtiyya.',
      ],
      relativesAr: null)); // TODO Link to RELIC_TYPE.Bayt
}
