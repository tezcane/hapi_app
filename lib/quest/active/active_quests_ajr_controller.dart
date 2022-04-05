import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAKB, // Muakaddah Before
  FAJR_FARD,
  FAJR_THIKR,
  FAJR_DUA,

  KARAHAT_ADHKAR_SUNRISE,

  DUHA_ISHRAQ,
  DUHA_DUHA,

  KARAHAT_ADHKAR_ISTIWA,

  DHUHR_MUAKB,
  DHUHR_FARD,
  DHUHR_MUAKA, // Muakaddah After
  DHUHR_NAFLA, // Nafl After
  DHUHR_THIKR,
  DHUHR_DUA,

  ASR_NAFLB, // Nafl Before
  ASR_FARD,
  ASR_THIKR,
  ASR_DUA,

  KARAHAT_ADHKAR_SUNSET,

  MAGHRIB_FARD,
  MAGHRIB_MUAKA,
  MAGHRIB_NAFLA,
  MAGHRIB_THIKR,
  MAGHRIB_DUA,

  ISHA_NAFLB,
  ISHA_FARD,
  ISHA_MUAKA,
  ISHA_NAFLA,
  ISHA_THIKR,
  ISHA_DUA,

  LAYL_QIYAM,
  LAYL_THIKR,
  LAYL_DUA,
  LAYL_SLEEP,
  LAYL_TAHAJJUD,
  LAYL_WITR,

  NONE, // used as terminator and no operation, but also stores bit length
}

extension EnumUtil on QUEST {
  /// Returns first part enum (must be uppercase), so: FAJR_FARD -> returns FAJR
  String salahRow() => name.split('_').first;

  bool get isFard => name.endsWith('FARD');

  bool get isMuak => isMuakBef || isMuakAft;
  bool get isMuakBef => name.endsWith('MUAKB');
  bool get isMuakAft => name.endsWith('MUAKA');

  bool get isNafl => isNaflBef || isNaflAft;
  bool get isNaflBef => name.endsWith('NAFLB');
  bool get isNaflAft => name.endsWith('NAFLA');

  bool get isThikr => name.endsWith('THIKR');
  bool get isDua => name.endsWith('DUA');

  bool get isQuestCellTimeBound {
    switch (this) {
      case (QUEST.KARAHAT_ADHKAR_SUNRISE):
      case (QUEST.DUHA_ISHRAQ):
      case (QUEST.DUHA_DUHA):
      case (QUEST.KARAHAT_ADHKAR_ISTIWA):
      case (QUEST.KARAHAT_ADHKAR_SUNSET):
        return true;
      default:
        return false;
    }
  }

  Z get startZaman {
    switch (this) {
      case (QUEST.FAJR_MUAKB):
      case (QUEST.FAJR_FARD):
      case (QUEST.FAJR_THIKR):
      case (QUEST.FAJR_DUA):
        return Z.Fajr;
      case (QUEST.KARAHAT_ADHKAR_SUNRISE):
        return Z.Karahat_Morning_Adhkar;
      case (QUEST.DUHA_ISHRAQ):
        return Z.Ishraq;
      case (QUEST.DUHA_DUHA):
        return Z.Duha;
      case (QUEST.KARAHAT_ADHKAR_ISTIWA):
        return Z.Karahat_Istiwa;
      case (QUEST.DHUHR_MUAKB):
      case (QUEST.DHUHR_FARD):
      case (QUEST.DHUHR_MUAKA):
      case (QUEST.DHUHR_NAFLA):
      case (QUEST.DHUHR_THIKR):
      case (QUEST.DHUHR_DUA):
        return Z.Dhuhr;
      case (QUEST.ASR_NAFLB):
      case (QUEST.ASR_FARD):
      case (QUEST.ASR_THIKR):
      case (QUEST.ASR_DUA):
        return ActiveQuestsController.to.salahAsrSafe
            ? Z.Asr_Later
            : Z.Asr_Earlier;
      case (QUEST.KARAHAT_ADHKAR_SUNSET):
        return Z.Karahat_Evening_Adhkar;
      case (QUEST.MAGHRIB_FARD):
      case (QUEST.MAGHRIB_MUAKA):
      case (QUEST.MAGHRIB_NAFLA):
      case (QUEST.MAGHRIB_THIKR):
      case (QUEST.MAGHRIB_DUA):
        return Z.Maghrib;
      case (QUEST.ISHA_NAFLB):
      case (QUEST.ISHA_FARD):
      case (QUEST.ISHA_MUAKA):
      case (QUEST.ISHA_NAFLA):
      case (QUEST.ISHA_THIKR):
      case (QUEST.ISHA_DUA):
        return Z.Isha;
      case (QUEST.LAYL_QIYAM):
      case (QUEST.LAYL_THIKR):
      case (QUEST.LAYL_DUA):
      case (QUEST.LAYL_SLEEP):
      case (QUEST.LAYL_TAHAJJUD):
      case (QUEST.LAYL_WITR):
        return Z.Isha; // Note qiyam prayer can occur during isha
      default:
        String e =
            'ActiveQuestAjrController:getStartZaman: Invalid Quest "$QUEST" given';
        l.e(e);
        throw e;
    }
  }

  Z get endZaman {
    switch (this) {
      case (QUEST.FAJR_MUAKB):
      case (QUEST.FAJR_FARD):
      case (QUEST.FAJR_THIKR):
      case (QUEST.FAJR_DUA):
        return Z.Karahat_Morning_Adhkar;
      case (QUEST.KARAHAT_ADHKAR_SUNRISE):
        return Z.Ishraq;
      case (QUEST.DUHA_ISHRAQ):
        return Z.Duha;
      case (QUEST.DUHA_DUHA):
        return Z.Karahat_Istiwa;
      case (QUEST.KARAHAT_ADHKAR_ISTIWA):
        return Z.Dhuhr;
      case (QUEST.DHUHR_MUAKB):
      case (QUEST.DHUHR_FARD):
      case (QUEST.DHUHR_MUAKA):
      case (QUEST.DHUHR_NAFLA):
      case (QUEST.DHUHR_THIKR):
      case (QUEST.DHUHR_DUA):
        return ActiveQuestsController.to.salahAsrSafe
            ? Z.Asr_Later
            : Z.Asr_Earlier;
      case (QUEST.ASR_NAFLB):
      case (QUEST.ASR_FARD):
      case (QUEST.ASR_THIKR):
      case (QUEST.ASR_DUA):
        return Z.Karahat_Evening_Adhkar;
      case (QUEST.KARAHAT_ADHKAR_SUNSET):
        return Z.Maghrib;
      case (QUEST.MAGHRIB_FARD):
      case (QUEST.MAGHRIB_MUAKA):
      case (QUEST.MAGHRIB_NAFLA):
      case (QUEST.MAGHRIB_THIKR):
      case (QUEST.MAGHRIB_DUA):
        return Z.Isha;
      case (QUEST.ISHA_NAFLB):
      case (QUEST.ISHA_FARD):
      case (QUEST.ISHA_MUAKA):
      case (QUEST.ISHA_NAFLA):
      case (QUEST.ISHA_THIKR):
      case (QUEST.ISHA_DUA):
      case (QUEST.LAYL_QIYAM): // After Isha salah done, layl can start anytime
      case (QUEST.LAYL_THIKR):
      case (QUEST.LAYL_DUA):
      case (QUEST.LAYL_SLEEP):
      case (QUEST.LAYL_TAHAJJUD):
      case (QUEST.LAYL_WITR):
        return Z.Fajr_Tomorrow;
      default:
        String e =
            'ActiveQuestAjrController:getEndZaman: Invalid Quest "$QUEST" given';
        l.e(e);
        throw e;
    }
  }
}

class ActiveQuestsAjrController extends GetxHapi {
  // cAjrA = controller ajr active (quests):
  static ActiveQuestsAjrController get to => Get.find();

//int _questsAll = 0;
  int _questsDone = 0;
  int _questsSkip = 0;
  int _questsMiss = 0;

  @override
  void onInit() {
    super.onInit();

    _questsDone = s.rd('questsDone') ?? 0;
    _questsSkip = s.rd('questsSkip') ?? 0;
    _questsMiss = s.rd('questsMiss') ?? 0;

    initCurrQuest();

    //_isIshaIbadahComplete = false;
  }

  void printBinary(int input) {
    l.v(input.toRadixString(2));
  }

  printBinaryAll() {
    l.v('questsDone=$_questsDone, questsSkip=$_questsSkip, questsMiss=$_questsMiss, questsAll=${questsAll()}:');
    printBinary(_questsDone);
    printBinary(_questsSkip);
    printBinary(_questsMiss);
    printBinary(questsAll());
  }

  void initCurrQuest() async {
    int sleepBackoffSecs = 1;

    // No internet needed to init, but we put a back off just in case:
    while (ZamanController.to.athan == null) {
      l.w('ActiveQuestsAjrController.initCurrQuest: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) sleepBackoffSecs++;
    }

    for (QUEST quest in QUEST.values) {
      if (quest.index == ZamanController.to.currZ.getFirstQuest().index) {
        l.i('Stopping init: $quest = $_questsMiss');
        break;
      }

      int curBitMask = 0x1 << quest.index;
      if (curBitMask & _questsDone != 0) continue;
      if (curBitMask & _questsSkip != 0) continue;
      if (curBitMask & _questsMiss != 0) continue;

      // user never inputted this value, we assume it is missed:
      setMiss(quest);
    }
  }

  int getCurrIdx() {
    int allQuests = questsAll();
    if (allQuests == 0) return 0; // "0" also length 1
    return allQuests.toRadixString(2).length;
  }

  QUEST getCurrQuest() => QUEST.values[getCurrIdx()];
  QUEST getPrevQuest() =>
      QUEST.values[getCurrIdx() - 1 < 0 ? 0 : getCurrIdx() - 1];
  QUEST getNextQuest() => QUEST.values[getCurrIdx() + 1 >= QUEST.NONE.index
      ? QUEST.NONE.index - 1
      : getCurrIdx() + 1];

  bool isQuestActive(QUEST q) => getCurrIdx() == q.index;

  int questsAll() => _questsDone | _questsSkip | _questsMiss;

  void setDone(QUEST quest) {
    l.v('setDone: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsDone |= 1 << quest.index;
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void setSkip(QUEST quest) {
    l.v('setSkip: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsSkip |= 1 << quest.index;
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void setMiss(QUEST quest) {
    l.v('setMiss: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsMiss |= 1 << quest.index;
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void clearQuest(QUEST quest) {
    l.v('clearQuest: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsDone &= ~(1 << quest.index);
    _questsSkip &= ~(1 << quest.index);
    _questsMiss &= ~(1 << quest.index);
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  /// Call at start of next day
  void clearAllQuests() {
    _questsDone = 0;
    _questsSkip = 0;
    _questsMiss = 0;
  }

  bool isDone(QUEST q) => (_questsDone >> q.index) & 1 == 1;
  bool isSkip(QUEST q) => (_questsSkip >> q.index) & 1 == 1;
  bool isMiss(QUEST q) => (_questsMiss >> q.index) & 1 == 1;

  isQuestComplete(QUEST q) => isDone(q) || isSkip(q) || isMiss(q);

  bool get isIshaIbadahComplete =>
      isQuestComplete(QUEST.ISHA_NAFLB) &&
      isQuestComplete(QUEST.ISHA_FARD) &&
      isQuestComplete(QUEST.ISHA_MUAKA) &&
      isQuestComplete(QUEST.ISHA_NAFLA) &&
      isQuestComplete(QUEST.ISHA_THIKR) &&
      isQuestComplete(QUEST.ISHA_DUA);

  /// Return map of ZRow to int, where the int value 1-5 holds a color value to
  /// be converted later into colors, i.e. ajr1Common, ajr2Uncommon, etc.
  Map<ZRow, int> get questRingColors {
    Map<ZRow, int> questRingColors = {};

    const int missed0 = 0;
    const int common1 = 1;
//  const int uncommon2 = 2;
//  const int rare2 = 3;
    const int epic4 = 4;
    const int legendary5 = 5;

    int ajrCount = common1; // start at 1/common so all 4 done = 5/Legendary
    if (isDone(QUEST.FAJR_MUAKB)) ajrCount++;
    if (isDone(QUEST.FAJR_FARD)) ajrCount++;
    if (isDone(QUEST.FAJR_THIKR)) ajrCount++;
    if (isDone(QUEST.FAJR_DUA)) ajrCount++;
    if (ajrCount == common1) ajrCount = missed0; // red ring if 0 quests done
    questRingColors[ZRow.Fajr] = ajrCount;

    ajrCount = common1;
    if (isDone(QUEST.KARAHAT_ADHKAR_SUNRISE)) ajrCount++;
    if (isDone(QUEST.DUHA_ISHRAQ)) ajrCount++;
    if (isDone(QUEST.DUHA_DUHA)) ajrCount++;
    if (isDone(QUEST.KARAHAT_ADHKAR_ISTIWA)) ajrCount++;
    if (ajrCount == common1) ajrCount = missed0;
    questRingColors[ZRow.Duha] = ajrCount;

    ajrCount = missed0;
    if (isDone(QUEST.DHUHR_MUAKB)) ajrCount++;
    if (isDone(QUEST.DHUHR_FARD)) ajrCount++;
    if (isDone(QUEST.DHUHR_MUAKA)) ajrCount++;
    if (isDone(QUEST.DHUHR_NAFLA)) ajrCount++;
    if (isDone(QUEST.DHUHR_THIKR)) ajrCount++;
    if (isDone(QUEST.DHUHR_DUA)) ajrCount++;
    if (ajrCount == 5) ajrCount = epic4; // 5 of 6 makes, epic
    if (ajrCount == 6) ajrCount = legendary5; // all 6 required for legendary
    questRingColors[ZRow.Dhuhr] = ajrCount;

    ajrCount = missed0;
    if (isDone(QUEST.ASR_NAFLB)) ajrCount++;
    if (isDone(QUEST.ASR_FARD)) ajrCount++;
    if (isDone(QUEST.ASR_THIKR)) ajrCount++;
    if (isDone(QUEST.ASR_DUA)) ajrCount++;
    if (isDone(QUEST.KARAHAT_ADHKAR_SUNSET)) ajrCount++;
    questRingColors[ZRow.Asr] = ajrCount;

    ajrCount = missed0;
    if (isDone(QUEST.MAGHRIB_FARD)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_MUAKA)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_NAFLA)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_THIKR)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_DUA)) ajrCount++;
    questRingColors[ZRow.Maghrib] = ajrCount;

    ajrCount = missed0;
    if (isDone(QUEST.ISHA_NAFLB)) ajrCount++;
    if (isDone(QUEST.ISHA_FARD)) ajrCount++;
    if (isDone(QUEST.ISHA_MUAKA)) ajrCount++;
    if (isDone(QUEST.ISHA_NAFLA)) ajrCount++;
    if (isDone(QUEST.ISHA_THIKR)) ajrCount++;
    if (isDone(QUEST.ISHA_DUA)) ajrCount++;
    if (ajrCount == 5) ajrCount = epic4;
    if (ajrCount == 6) ajrCount = legendary5;
    questRingColors[ZRow.Isha] = ajrCount;

    ajrCount = missed0;
    if (isDone(QUEST.LAYL_QIYAM)) ajrCount++;
    if (isDone(QUEST.LAYL_THIKR)) ajrCount++;
    if (isDone(QUEST.LAYL_DUA)) ajrCount++;
    if (isDone(QUEST.LAYL_SLEEP)) ajrCount++;
    if (isDone(QUEST.LAYL_TAHAJJUD)) ajrCount++;
    if (isDone(QUEST.LAYL_WITR)) ajrCount++;
    if (ajrCount == 5) ajrCount = epic4;
    if (ajrCount == 6) ajrCount = legendary5;
    questRingColors[ZRow.Layl] = ajrCount;

    return questRingColors;
  }
}

// enum QUEST_TYPE {
//   ACTIVE, // FARD, MUAK, NAFL, // Other Sunnah, miswak, washing hands, etc.
//   DAILY, // DAILY, Mumeen chests
//   TIME, // USER'S PERSONAL HEALTH, PERSONAL/FAMILY TIME, etc. fall in here
//   HAPI, // HAPI QUESTS, like collect 10 names of Allah SWT.
// }
//
// // Halal- 5 levels - Haram
// enum SUNNAH_CLASS {
//   FARD,
//   MUAK, // MUAKKADAH/
//   NAFL,
// }
//
// enum IBADAH_TYPE {
//   //https://seekersguidance.org/articles/knowledge/ten-types-of-ibadah-worship-imam-al-ghazzali/
//   SALAH,
//   SAWM,
//   CHARITY, // ZAKAT,SADAQAH,
//   TRAVEL, // HAJJ, UMRAH, VISIT MASJID HARAM, NABAWAI, AQSA,
//   THIKR, //READ, DUA,
//   SOCIAL, //DAWAH, WORK, FAMILY Fullfil obligations to others, family/neighbors/friends
//   JIHAD,
// }

// FARD_SAWM, // RAMADAN
// FARD_ZAKAT,
// FARD_HAJJ,

// MUAK_SALAH_JUMA,
// MUAK_JUMA_GHUSUL,
//
// MUAK_QURAN,
// MUAK_SADAQAH,
// MUAK_UMRAH,
// MUAK_SAWM_ARAFAT,
//
// NAFL_SALAH_TARAWEH, // **TAHAJUD in RAMADAN?
//
// NAFL_SALAH_ISTIKHARA,
// NAFL_SALAH_TAHIYATUL_WUDU,
// NAFL_SALAH_TAHIYATUL_MASJID,
//
// USER_WORK_TIME,
// USER_FAMILY_TIME,
// USER_PERSONAL_TIME,
// USER_CALENDAR_EVENT, //TODO import from user calendar
//
// USER_CUSTOM,
//
// // Halal- 5 levels - Haram
// enum Ahkam {
//   //https://en.wikipedia.org/wiki/Ahkam
//   //https://www.thedeenshow.com/halal-mustahabb-mubah-makrooh-haram/
//   FARD, // WAJIB
//   MUSTAHABB, // or MANDOOK, SHOULD DO FOR AJR
//   MUBAH, // PERMITTED, DON'T DO NO SIN
//   MAKRUH, // DON'T DO IS BETTER, DO TOO MUCH IS SIN
//   HARAM, // SIN
// }
