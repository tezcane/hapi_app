import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/services/db.dart';

const int ajr0Missed = 0; // shows that they missed all quests
const int ajr1Common = 1;
const int ajr2Uncommon = 2;
const int ajr3Rare = 3;
const int ajr4Epic = 4;
const int ajr5Legendary = 5;
const int ajr6TimeNotInYet = 6; // so can show blank around ring

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAKB, // Muakaddah Before
  FAJR_FARD,
  MORNING_ADHKAR,
  FAJR_THIKR,
  FAJR_DUA,

  KARAHAT_SUNRISE,
  DUHA_ISHRAQ,
  DUHA_DUHA,
  KARAHAT_ISTIWA,

  DHUHR_MUAKB,
  DHUHR_FARD,
  DHUHR_MUAKA, // Muakaddah After
  DHUHR_NAFLA, // Nafl After
  DHUHR_THIKR,
  DHUHR_DUA,

  ASR_NAFLB, // Nafl Before
  ASR_FARD,
  EVENING_ADHKAR,
  ASR_THIKR,
  ASR_DUA,

  KARAHAT_SUNSET,
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

  bool get isMuak => isMuakB || isMuakA;
  bool get isMuakB => name.endsWith('MUAKB');
  bool get isMuakA => name.endsWith('MUAKA');

  bool get isNafl => isNaflB || isNaflA;
  bool get isNaflB => name.endsWith('NAFLB');
  bool get isNaflA => name.endsWith('NAFLA');

  bool get isThikr => name.endsWith('THIKR');
  bool get isDua => name.endsWith('DUA');

  bool get isQuestCellTimeBound {
    switch (this) {
      case (QUEST.DUHA_ISHRAQ):
      case (QUEST.DUHA_DUHA):
      case (QUEST.MAGHRIB_FARD): // TODO test
        return true;
      default:
        return false;
    }
  }
}

/// Bit Completion Type
enum BitType {
  DONE,
  SKIP,
  MISS,
}

/// Controls Active Quests Ajr/Points via storing QUEST results in 3 ints to
/// know if the QUEST is done (completed by user), skipped (by user), or missed
/// (the user didn't complete the quest and time ran out on them). The ints
/// store a QUEST's result by using the Enum index and using it as a bit/binary
/// offset.
class ActiveQuestsAjrController extends GetxHapi {
  static ActiveQuestsAjrController get to => Get.find();

  int _questsDone = 0;
  int _questsSkip = 0;
  int _questsMiss = 0;

  initCurrQuest(Z currZ, bool readOrInit) async {
    if (readOrInit) {
      ActiveQuestModel? m = await Db.getActiveQuest(TimeController.to.currDay);
      if (m != null) {
        _questsDone = m.done;
        _questsSkip = m.skip;
        _questsMiss = m.miss;
      } else {
        // not found in db so make first entry
        await Db.setActiveQuest(
          ActiveQuestModel(
            day: TimeController.to.currDay,
            done: 0,
            skip: 0,
            miss: 0,
          ),
        );
        _questsDone = 0;
        _questsSkip = 0;
        _questsMiss = 0;
      }
    }

    int questsMissCopy = _questsMiss;

    QUEST lastQuest = QUEST.values[0];
    for (QUEST quest in QUEST.values) {
      lastQuest = quest;
      if (quest == currZ.getFirstQuest()) {
        l.i('Stopping init: $quest, _questsMiss=$_questsMiss');
        break;
      }
      if (isComplete(quest)) continue; // task was completed already

      if (currZ == Z.Ghurub) {
        // We are in Ghurub/Sunsetting time but we need to allow user to still
        // do their adhkar until sunset.  Therefore, we don't force miss the
        // below quests when Ghurub time comes in:
        if (quest == QUEST.EVENING_ADHKAR ||
            quest == QUEST.ASR_THIKR ||
            quest == QUEST.ASR_DUA) {
          continue;
        }
      } else if (currZ == Z.Last_3rd_of_Night) {
        // We are in Last 3rd of Night time but we need to allow user to still
        // do their Middle of Night ibadah. Therefore, we don't force miss the
        // below quests when Last_3rd_of_Night of night time comes in:
        if (quest == QUEST.LAYL_QIYAM ||
            quest == QUEST.LAYL_THIKR ||
            quest == QUEST.LAYL_DUA) {
          continue;
        }
      }

      // user never inputted this value, we set it as missed
      _setMiss(quest); // Does don't write to DB
    }

    // only update db if new misses were found
    if (questsMissCopy != _questsMiss) {
      updateDB(lastQuest, BitType.MISS);
      ActiveQuestsController.to.update(); // refresh UI, prob not needed but OK
    }
  }

  bool isQuestActive(QUEST q) => getCurrIdx == q.index;

  get getCurrIdx {
    int allQuests = _questsDone | _questsSkip | _questsMiss;
    if (allQuests == 0) return 0; // avoid "0"/"1" binary case from below:
    return allQuests.toRadixString(2).length;
  }

  QUEST getCurrQuest() => QUEST.values[getCurrIdx];
  QUEST getPrevQuest() => QUEST.values[getCurrIdx - 1 < 0 ? 0 : getCurrIdx - 1];
  QUEST getNextQuest() => QUEST.values[getCurrIdx + 1 >= QUEST.NONE.index
      ? QUEST.NONE.index - 1
      : getCurrIdx + 1];

  bool isDone(QUEST q) => (_questsDone >> q.index) & 1 == 1;
  bool isSkip(QUEST q) => (_questsSkip >> q.index) & 1 == 1;
  bool isMiss(QUEST q) => (_questsMiss >> q.index) & 1 == 1;
  bool isSkipOrMiss(QUEST q) => isSkip(q) || isMiss(q);
  bool isComplete(QUEST q) => isDone(q) || isSkip(q) || isMiss(q);
  bool isNotComplete(QUEST q) => !isComplete(q);

  bool get isAsrComplete =>
      isComplete(QUEST.ASR_NAFLB) &&
      isComplete(QUEST.ASR_FARD) &&
      isComplete(QUEST.ASR_THIKR) &&
      isComplete(QUEST.ASR_DUA) &&
      isComplete(QUEST.EVENING_ADHKAR);

  bool get isIshaComplete =>
      isComplete(QUEST.ISHA_NAFLB) &&
      isComplete(QUEST.ISHA_FARD) &&
      isComplete(QUEST.ISHA_MUAKA) &&
      isComplete(QUEST.ISHA_NAFLA) &&
      isComplete(QUEST.ISHA_THIKR) &&
      isComplete(QUEST.ISHA_DUA);

  bool get isMiddleOfNightComplete =>
      isComplete(QUEST.LAYL_QIYAM) &&
      isComplete(QUEST.LAYL_THIKR) &&
      isComplete(QUEST.LAYL_DUA);

  setDone(QUEST quest) => _setBit(quest, BitType.DONE, true);
  setSkip(QUEST quest) => _setBit(quest, BitType.SKIP, true);
  _setMiss(QUEST quest) => _setBit(quest, BitType.MISS, false);
  _setBit(QUEST quest, BitType bitType, bool updateDb) {
    switch (bitType) {
      case (BitType.DONE):
        _questsDone |= 1 << quest.index;
        break;
      case (BitType.SKIP):
        _questsSkip |= 1 << quest.index;
        break;
      case (BitType.MISS):
        _questsMiss |= 1 << quest.index;
        break;
    }

    if (updateDb) {
      // don't do work of big binary output, unless verbose mode is on
      if (l.isVerboseMode) {
        switch (bitType) {
          case (BitType.DONE):
            l.v(_questsDone.toRadixString(2));
            break;
          case (BitType.SKIP):
            l.v(_questsSkip.toRadixString(2));
            break;
          case (BitType.MISS):
            l.v(_questsMiss.toRadixString(2));
            break;
        }
      }

      // only needed on data changes, see handleTooltipUpdate()
      if (quest.index > QUEST.ISHA_DUA.index) {
        ZamanController.to.handleTooltipUpdate(null);
      }

      ActiveQuestsController.to.update(); // refresh UI (don't wait for below)

      updateDB(quest, bitType); // TODO catch e to undo/not flush bit?
    }
  }

  void setClearQuest(QUEST quest) {
    l.v('clearQuest: $quest (index=${quest.index}) = $_questsMiss');
    _questsDone &= ~(1 << quest.index);
    _questsSkip &= ~(1 << quest.index);
    _questsMiss &= ~(1 << quest.index);

    // Prob not needed here, but ok:
    if (quest.index > QUEST.ISHA_DUA.index) {
      ZamanController.to.handleTooltipUpdate(null);
    }

    // NOTE: Caller sets new bits after clearing, so don't need below:
//  updateDB();
//  ActiveQuestsController.to.update();
  }

  updateDB(QUEST quest, BitType bitType) async {
    l.d('ActiveQuestAjrController:updateDB(${quest.name}): ${bitType.name} bit(s) changed, writing DONE=$_questsDone, SKIP=$_questsSkip, MISS=$_questsMiss');

    await Db.setActiveQuest(
      ActiveQuestModel(
        day: TimeController.to.currDay,
        done: _questsDone, // TODO can optimize to write only new mask data.
        skip: _questsSkip,
        miss: _questsMiss,
      ),
    );
  }

  /// Return map of z to int, where the int value 1-5 holds a color value to
  /// be converted later into colors, i.e. ajr1Common, ajr2Uncommon, etc.
  Map<Z, int> get questRingColors {
    Map<Z, int> questRingColors = {};

    getZamanRingColor(questRingColors, Z.Fajr, [
      QUEST.FAJR_MUAKB,
      QUEST.FAJR_FARD,
      QUEST.MORNING_ADHKAR,
      QUEST.FAJR_THIKR,
      QUEST.FAJR_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Duha, [
      QUEST.KARAHAT_SUNRISE,
      QUEST.DUHA_ISHRAQ,
      QUEST.DUHA_DUHA,
      QUEST.KARAHAT_ISTIWA,
    ]);
    getZamanRingColor(questRingColors, Z.Dhuhr, [
      QUEST.DHUHR_MUAKB,
      QUEST.DHUHR_FARD,
      QUEST.DHUHR_MUAKA,
      QUEST.DHUHR_NAFLA,
      QUEST.DHUHR_THIKR,
      QUEST.DHUHR_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Asr, [
      QUEST.ASR_NAFLB,
      QUEST.ASR_FARD,
      QUEST.EVENING_ADHKAR,
      QUEST.ASR_THIKR,
      QUEST.ASR_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Maghrib, [
      QUEST.KARAHAT_SUNSET,
      QUEST.MAGHRIB_FARD,
      QUEST.MAGHRIB_MUAKA,
      QUEST.MAGHRIB_NAFLA,
      QUEST.MAGHRIB_THIKR,
      QUEST.MAGHRIB_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Isha, [
      QUEST.ISHA_NAFLB,
      QUEST.ISHA_FARD,
      QUEST.ISHA_MUAKA,
      QUEST.ISHA_NAFLA,
      QUEST.ISHA_THIKR,
      QUEST.ISHA_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Middle_of_Night, [
      QUEST.LAYL_QIYAM,
      QUEST.LAYL_THIKR,
      QUEST.LAYL_DUA,
    ]);
    getZamanRingColor(questRingColors, Z.Last_3rd_of_Night, [
      QUEST.LAYL_SLEEP,
      QUEST.LAYL_TAHAJJUD,
      QUEST.LAYL_WITR,
    ]);

    return questRingColors;
  }

  void getZamanRingColor(Map<Z, int> questRingColors, Z z, List<QUEST> quests) {
    int ajrCount = 0;
    for (QUEST quest in quests) {
      if (isDone(quest)) ajrCount++;
    }

    if (ajrCount == 0) {
      int missCount = 0;
      for (QUEST quest in quests) {
        if (isMiss(quest)) missCount++;
      }
      ajrCount = missCount == quests.length ? ajr0Missed : ajr6TimeNotInYet;
    } else {
      if (quests.length == 6) {
        if (ajrCount == 6) {
          ajrCount = ajr5Legendary; // 6 = legendary
        } else if (ajrCount == 5) {
          ajrCount = ajr4Epic; // 5 = epic
        }
      } else if (quests.length == 5) {
        // no special logic needed, 5 = legendary
      } else if (quests.length == 4) {
        if (ajrCount == ajr4Epic) ajrCount = ajr5Legendary; // 4 = legendary
      } else if (quests.length == 3) {
        if (ajrCount == 3) {
          ajrCount = ajr5Legendary; // 3 = legendary
        } else if (ajrCount == 2) {
          ajrCount = ajr4Epic; // 2 = epic
        } else if (ajrCount == 1) {
          ajrCount = ajr3Rare; // 1 = rare
        }
      }
    }

    questRingColors[z] = ajrCount;
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
