import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/services/db.dart';

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

  int _questsDone = 0;
  int _questsSkip = 0;
  int _questsMiss = 0;

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

  initCurrQuest(Z currZ, bool initUpdate) async {
    if (initUpdate) {
      ActiveQuestModel? m = await Db.getActiveQuest(TimeController.to.currDay);
      if (m != null) {
        _questsDone = m.done;
        _questsSkip = m.skip;
        _questsMiss = m.miss;
      }
    }

    int questsDone = _questsDone;
    int questsSkip = _questsSkip;
    int questsMiss = _questsMiss;

    for (QUEST quest in QUEST.values) {
      if (quest.index == currZ.getFirstQuest().index) {
        l.i('Stopping init: $quest, _questsMiss=$_questsMiss');
        break;
      }

      int curBitMask = 0x1 << quest.index;
      if (curBitMask & _questsDone != 0) continue;
      if (curBitMask & _questsSkip != 0) continue;
      if (curBitMask & _questsMiss != 0) continue;

      // user never inputted this value, we assume it is missed:
      setMiss(quest);
    }

    if (questsDone != _questsDone ||
        questsSkip != _questsSkip ||
        questsMiss != _questsMiss) {
      updateDB();
    }
  }

  void updateDB() {
    Db.setActiveQuest(
      ActiveQuestModel(
        day: TimeController.to.currDay,
        done: _questsDone,
        skip: _questsSkip,
        miss: _questsMiss,
      ),
    );
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
    updateDB();
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void setSkip(QUEST quest) {
    l.v('setSkip: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsSkip |= 1 << quest.index;
    updateDB();
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void setMiss(QUEST quest) {
    l.v('setMiss: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsMiss |= 1 << quest.index;
    // updateDB(); never updated db, only done in initCurrQuest()
    ActiveQuestsController.to.update(); // refresh UI
    printBinaryAll();
  }

  void clearQuest(QUEST quest) {
    l.v('clearQuest: $quest (index=${quest.index}) = $_questsMiss');
    printBinaryAll();
    _questsDone &= ~(1 << quest.index);
    _questsSkip &= ~(1 << quest.index);
    _questsMiss &= ~(1 << quest.index);
    //updateDB(); it is cleared, then written to so no need to write to db.
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
//  const int common1 = 1;
//  const int uncommon2 = 2;
//  const int rare2 = 3;
    const int epic4 = 4;
    const int legendary5 = 5;
    const int notExpired6 = 6; // time not expired yet

    int ajrCount = 0;
    int missCount = 0;
    if (isDone(QUEST.FAJR_MUAKB)) ajrCount++;
    if (isDone(QUEST.FAJR_FARD)) ajrCount++;
    if (isDone(QUEST.FAJR_THIKR)) ajrCount++;
    if (isDone(QUEST.FAJR_DUA)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.FAJR_MUAKB) || isSkip(QUEST.FAJR_MUAKB)) missCount++;
      if (isMiss(QUEST.FAJR_FARD) || isSkip(QUEST.FAJR_FARD)) missCount++;
      if (isMiss(QUEST.FAJR_THIKR) || isSkip(QUEST.FAJR_THIKR)) missCount++;
      if (isMiss(QUEST.FAJR_DUA) || isSkip(QUEST.FAJR_DUA)) missCount++;
      if (missCount == 4) {
        ajrCount = missed0; // red ring if all quests expired
      } else {
        ajrCount = notExpired6; // otherwise time not expired yet->transparent
      }
    } else if (ajrCount == epic4) {
      ajrCount = legendary5; // 4 done = 5/Legendary
    }
    questRingColors[ZRow.Fajr] = ajrCount;

    ajrCount = 0;
    missCount = 0;
    if (isDone(QUEST.KARAHAT_ADHKAR_SUNRISE)) ajrCount++;
    if (isDone(QUEST.DUHA_ISHRAQ)) ajrCount++;
    if (isDone(QUEST.DUHA_DUHA)) ajrCount++;
    if (isDone(QUEST.KARAHAT_ADHKAR_ISTIWA)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.KARAHAT_ADHKAR_SUNRISE) ||
          isSkip(QUEST.KARAHAT_ADHKAR_SUNRISE)) missCount++;
      if (isMiss(QUEST.DUHA_ISHRAQ) || isSkip(QUEST.DUHA_ISHRAQ)) missCount++;
      if (isMiss(QUEST.DUHA_DUHA) || isSkip(QUEST.DUHA_DUHA)) missCount++;
      if (isMiss(QUEST.KARAHAT_ADHKAR_ISTIWA) ||
          isSkip(QUEST.KARAHAT_ADHKAR_ISTIWA)) missCount++;
      if (missCount == 4) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    } else if (ajrCount == epic4) {
      ajrCount = legendary5; // 4 done = 5/Legendary
    }
    questRingColors[ZRow.Duha] = ajrCount;

    ajrCount = 0;
    missCount = 0;
    if (isDone(QUEST.DHUHR_MUAKB)) ajrCount++;
    if (isDone(QUEST.DHUHR_FARD)) ajrCount++;
    if (isDone(QUEST.DHUHR_MUAKA)) ajrCount++;
    if (isDone(QUEST.DHUHR_NAFLA)) ajrCount++;
    if (isDone(QUEST.DHUHR_THIKR)) ajrCount++;
    if (isDone(QUEST.DHUHR_DUA)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.DHUHR_MUAKB) || isSkip(QUEST.DHUHR_MUAKB)) missCount++;
      if (isMiss(QUEST.DHUHR_FARD) || isSkip(QUEST.DHUHR_FARD)) missCount++;
      if (isMiss(QUEST.DHUHR_MUAKA) || isSkip(QUEST.DHUHR_MUAKA)) missCount++;
      if (isMiss(QUEST.DHUHR_NAFLA) || isSkip(QUEST.DHUHR_NAFLA)) missCount++;
      if (isMiss(QUEST.DHUHR_THIKR) || isSkip(QUEST.DHUHR_THIKR)) missCount++;
      if (isMiss(QUEST.DHUHR_DUA) || isSkip(QUEST.DHUHR_DUA)) missCount++;
      if (missCount == 6) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    } else if (ajrCount == legendary5) {
      ajrCount = epic4; // 5 of 6 makes, epic
    } else if (ajrCount == 6) {
      ajrCount = legendary5; // all 6 required for legendary
    }
    questRingColors[ZRow.Dhuhr] = ajrCount;

    ajrCount = 0;
    missCount = 0;
    if (isDone(QUEST.ASR_NAFLB)) ajrCount++;
    if (isDone(QUEST.ASR_FARD)) ajrCount++;
    if (isDone(QUEST.ASR_THIKR)) ajrCount++;
    if (isDone(QUEST.ASR_DUA)) ajrCount++;
    if (isDone(QUEST.KARAHAT_ADHKAR_SUNSET)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.ASR_NAFLB) || isSkip(QUEST.ASR_NAFLB)) missCount++;
      if (isMiss(QUEST.ASR_FARD) || isSkip(QUEST.ASR_FARD)) missCount++;
      if (isMiss(QUEST.ASR_THIKR) || isSkip(QUEST.ASR_THIKR)) missCount++;
      if (isMiss(QUEST.ASR_DUA) || isSkip(QUEST.ASR_DUA)) missCount++;
      if (isMiss(QUEST.KARAHAT_ADHKAR_SUNSET) ||
          isSkip(QUEST.KARAHAT_ADHKAR_SUNSET)) missCount++;
      if (missCount == 5) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    }
    questRingColors[ZRow.Asr] = ajrCount;

    ajrCount = 0;
    missCount = 0;
    if (isDone(QUEST.MAGHRIB_FARD)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_MUAKA)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_NAFLA)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_THIKR)) ajrCount++;
    if (isDone(QUEST.MAGHRIB_DUA)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.MAGHRIB_FARD) || isSkip(QUEST.MAGHRIB_FARD)) missCount++;
      if (isMiss(QUEST.MAGHRIB_MUAKA) || isSkip(QUEST.MAGHRIB_MUAKA)) {
        missCount++;
      }
      if (isMiss(QUEST.MAGHRIB_NAFLA) || isSkip(QUEST.MAGHRIB_NAFLA)) {
        missCount++;
      }
      if (isMiss(QUEST.MAGHRIB_THIKR) || isSkip(QUEST.MAGHRIB_THIKR)) {
        missCount++;
      }
      if (isMiss(QUEST.MAGHRIB_DUA) || isSkip(QUEST.MAGHRIB_DUA)) missCount++;
      if (missCount == 5) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    }
    questRingColors[ZRow.Maghrib] = ajrCount;

    ajrCount = 0;
    missCount = 0;
    if (isDone(QUEST.ISHA_NAFLB)) ajrCount++;
    if (isDone(QUEST.ISHA_FARD)) ajrCount++;
    if (isDone(QUEST.ISHA_MUAKA)) ajrCount++;
    if (isDone(QUEST.ISHA_NAFLA)) ajrCount++;
    if (isDone(QUEST.ISHA_THIKR)) ajrCount++;
    if (isDone(QUEST.ISHA_DUA)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.ISHA_NAFLB) || isSkip(QUEST.ISHA_NAFLB)) missCount++;
      if (isMiss(QUEST.ISHA_FARD) || isSkip(QUEST.ISHA_FARD)) missCount++;
      if (isMiss(QUEST.ISHA_MUAKA) || isSkip(QUEST.ISHA_MUAKA)) missCount++;
      if (isMiss(QUEST.ISHA_NAFLA) || isSkip(QUEST.ISHA_NAFLA)) missCount++;
      if (isMiss(QUEST.ISHA_THIKR) || isSkip(QUEST.ISHA_THIKR)) missCount++;
      if (isMiss(QUEST.ISHA_DUA) || isSkip(QUEST.ISHA_DUA)) missCount++;
      if (missCount == 6) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    } else if (ajrCount == 5) {
      ajrCount = epic4;
    } else if (ajrCount == 6) {
      ajrCount = legendary5;
    }
    questRingColors[ZRow.Isha] = ajrCount;

    ajrCount = missed0;
    missCount = 0;
    if (isDone(QUEST.LAYL_QIYAM)) ajrCount++;
    if (isDone(QUEST.LAYL_THIKR)) ajrCount++;
    if (isDone(QUEST.LAYL_DUA)) ajrCount++;
    if (isDone(QUEST.LAYL_SLEEP)) ajrCount++;
    if (isDone(QUEST.LAYL_TAHAJJUD)) ajrCount++;
    if (isDone(QUEST.LAYL_WITR)) ajrCount++;
    if (ajrCount == 0) {
      if (isMiss(QUEST.LAYL_QIYAM) || isSkip(QUEST.LAYL_QIYAM)) missCount++;
      if (isMiss(QUEST.LAYL_THIKR) || isSkip(QUEST.LAYL_THIKR)) missCount++;
      if (isMiss(QUEST.LAYL_DUA) || isSkip(QUEST.LAYL_DUA)) missCount++;
      if (isMiss(QUEST.LAYL_SLEEP) || isSkip(QUEST.LAYL_SLEEP)) missCount++;
      if (isMiss(QUEST.LAYL_TAHAJJUD) || isSkip(QUEST.LAYL_TAHAJJUD)) {
        missCount++;
      }
      if (isMiss(QUEST.LAYL_WITR) || isSkip(QUEST.LAYL_WITR)) missCount++;
      if (missCount == 6) {
        ajrCount = missed0;
      } else {
        ajrCount = notExpired6;
      }
    } else if (ajrCount == 5) {
      ajrCount = epic4;
    } else if (ajrCount == 6) {
      ajrCount = legendary5;
    }
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
