import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
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

  KARAHAT_ADHKAR_ZAWAL,

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

  NONE // used as terminator and no operation, but also stores bit length
}

extension EnumUtil on QUEST {
  /// Returns first part enum (must be uppercase), so: FAJR_FARD -> returns FAJR
  String salahRow() => name.split('_').first;

  bool isFard() => name.endsWith('FARD');
  bool isMuak() => name.contains('MUAK');
  bool isNafl() => name.contains('NAFL');

  bool isMuakBef() => name.endsWith('MUAKB');
  bool isMuakAft() => name.endsWith('MUAKA');
  bool isNaflBef() => name.endsWith('NAFLB');
  bool isNaflAft() => name.endsWith('NAFLA');

  bool isThikr() => name.endsWith('THIKR');
  bool isDua() => name.endsWith('DUA');

  bool isQuestCellTimeBound() {
    switch (this) {
      case (QUEST.KARAHAT_ADHKAR_SUNRISE):
      case (QUEST.DUHA_ISHRAQ):
      case (QUEST.DUHA_DUHA):
      case (QUEST.KARAHAT_ADHKAR_ZAWAL):
      case (QUEST.KARAHAT_ADHKAR_SUNSET):
        return true;
      default:
        return false;
    }
  }

  Z getStartZaman() {
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
      case (QUEST.KARAHAT_ADHKAR_ZAWAL):
        return Z.Karahat_Zawal;
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

  Z getEndZaman() {
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
        return Z.Karahat_Zawal;
      case (QUEST.KARAHAT_ADHKAR_ZAWAL):
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
    int guestsAll = questsAll();
    if (guestsAll == 0) return 0; // "0" also length 1
    return guestsAll.toRadixString(2).length;
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
