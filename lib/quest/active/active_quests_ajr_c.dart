import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/active/active_quests_c.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_c.dart';
import 'package:hapi/service/db.dart';

/// Bit Completion Type
enum BitType {
  DONE,
  SKIP,
  MISS,
}

/// Used to allow user to complete an Active Quest or not.
enum QUEST_STATE {
  DONE,
  SKIP,
  MISS,
  NOT_ACTIVE_YET,
  ACTIVE_CURR_QUEST,
  ACTIVE,
}

/// These are all the active quests shown on the UI.
enum QUEST {
  FAJR_MUAKB, // Muakaddah Before
  FAJR_FARD,
  MORNING_ADHKAR,
  FAJR_THIKR,
  FAJR_DUA,

  KARAHAT_SUNRISE,
  DHUHA_ISHRAQ,
  DHUHA_DHUHA,
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
}

extension EnumUtil on QUEST {
  bool get isFard => name.endsWith('FARD');
  bool get isMuak => isMuakB || isMuakA;
  bool get isMuakB => name.endsWith('MUAKB');
  bool get isMuakA => name.endsWith('MUAKA');
  bool get isNafl => isNaflB || isNaflA;
  bool get isNaflB => name.endsWith('NAFLB');
  bool get isNaflA => name.endsWith('NAFLA');

  bool get isAdhkar => name.endsWith('ADHKAR');
  bool get isFardThikr => name.endsWith('THIKR') && !name.startsWith('LAYL');
  bool get isFardDua => name.endsWith('DUA') && !name.startsWith('LAYL');

  bool get isLayl => name.startsWith('LAYL');

  Z getQuestZRow() {
    switch (this) {
      case QUEST.FAJR_MUAKB:
      case QUEST.FAJR_FARD:
      case QUEST.MORNING_ADHKAR:
      case QUEST.FAJR_THIKR:
      case QUEST.FAJR_DUA:
        return Z.Fajr;
      case QUEST.KARAHAT_SUNRISE:
      case QUEST.DHUHA_ISHRAQ:
      case QUEST.DHUHA_DHUHA:
      case QUEST.KARAHAT_ISTIWA:
        return Z.Dhuha;
      case QUEST.DHUHR_MUAKB:
      case QUEST.DHUHR_FARD:
      case QUEST.DHUHR_MUAKA:
      case QUEST.DHUHR_NAFLA:
      case QUEST.DHUHR_THIKR:
      case QUEST.DHUHR_DUA:
        return Z.Dhuhr;
      case QUEST.ASR_NAFLB:
      case QUEST.ASR_FARD:
      case QUEST.EVENING_ADHKAR:
      case QUEST.ASR_THIKR:
      case QUEST.ASR_DUA:
        return Z.Asr;
      case QUEST.KARAHAT_SUNSET:
      case QUEST.MAGHRIB_FARD:
      case QUEST.MAGHRIB_MUAKA:
      case QUEST.MAGHRIB_NAFLA:
      case QUEST.MAGHRIB_THIKR:
      case QUEST.MAGHRIB_DUA:
        return Z.Maghrib;
      case QUEST.ISHA_NAFLB:
      case QUEST.ISHA_FARD:
      case QUEST.ISHA_MUAKA:
      case QUEST.ISHA_NAFLA:
      case QUEST.ISHA_THIKR:
      case QUEST.ISHA_DUA:
        return Z.Isha;
      case QUEST.LAYL_QIYAM:
      case QUEST.LAYL_THIKR:
      case QUEST.LAYL_DUA:
        return Z.Middle_of_Night;
      case QUEST.LAYL_SLEEP:
      case QUEST.LAYL_TAHAJJUD:
      case QUEST.LAYL_WITR:
        return Z.Last_3rd_of_Night;
    }
  }

  QUEST_STATE getActionState() {
    ActiveQuestsAjrC ajrC = ActiveQuestsAjrC.to;

    // if task is complete, DONE, SKIP or MISS
    if (ajrC.isDone(this)) return QUEST_STATE.DONE;
    if (ajrC.isSkip(this)) return QUEST_STATE.SKIP;
    if (ajrC.isMiss(this)) return QUEST_STATE.MISS;

    // get the ZRow of this quest
    Z zRow = getQuestZRow();

    // if salah row is not pinned, NOT_ACTIVE_YET
    bool isNotInPinnedSalahRow = !ZamanC.to.isZRowPinned(zRow);
    if (isNotInPinnedSalahRow) return QUEST_STATE.NOT_ACTIVE_YET;

    // if we got here we know zRow is pinned

    if (ajrC.isQuestAtCurrIdx(this)) {
      // Special logic used to handle these quests, see below switch statement
      if (this == QUEST.MAGHRIB_FARD ||
          this == QUEST.DHUHA_ISHRAQ ||
          this == QUEST.DHUHA_DHUHA) {
      } else {
        // Normal, if current quest (next in line) and pinned, ACTIVE_CURR_QUEST
        return QUEST_STATE.ACTIVE_CURR_QUEST;
      }
    }

    // For salah rows (Fajr, Dhuhr, Asr, Maghrib, Isha):
    // find out if the salah's      for this pinned row are complete or not
    // find out if adhkar and dhikr for this pinned row are complete or not
    bool isSalahRowCompletedSalah = true;
    bool isSalahRowCompletedAdhkarAndThikr = true;
    List<QUEST> zRowQuests = zRow.getZRowQuests();
    for (QUEST q in zRowQuests) {
      if (q.isFard || q.isMuak || q.isNafl || q.isLayl) {
        if (ajrC.isNotComplete(q)) {
          isSalahRowCompletedSalah = false;
          isSalahRowCompletedAdhkarAndThikr = false; // can't be true too
          break;
        }
      } else if (q.isAdhkar || q.isFardThikr) {
        if (ajrC.isNotComplete(q)) isSalahRowCompletedAdhkarAndThikr = false;
      }
    }

    // if we got here: Quest's zRow is Pinned but it's not the current quest yet
    switch (this) {
      // FARD, MUAK, NAFL, and LAYL quests must be done sequentially
      case QUEST.FAJR_MUAKB:
      case QUEST.FAJR_FARD:
      case QUEST.DHUHR_MUAKB:
      case QUEST.DHUHR_FARD:
      case QUEST.DHUHR_MUAKA:
      case QUEST.DHUHR_NAFLA:
      case QUEST.ASR_NAFLB:
      case QUEST.ASR_FARD:
      case QUEST.MAGHRIB_MUAKA:
      case QUEST.MAGHRIB_NAFLA:
      case QUEST.ISHA_NAFLB:
      case QUEST.ISHA_FARD:
      case QUEST.ISHA_MUAKA:
      case QUEST.ISHA_NAFLA:
      case QUEST.LAYL_QIYAM:
      case QUEST.LAYL_THIKR:
      case QUEST.LAYL_DUA:
      case QUEST.LAYL_SLEEP:
      case QUEST.LAYL_TAHAJJUD:
      case QUEST.LAYL_WITR:
        return QUEST_STATE.NOT_ACTIVE_YET;

      // karahat can complete anytime isSalahRowPinned:
      case QUEST.KARAHAT_SUNRISE:
      case QUEST.KARAHAT_ISTIWA:
      case QUEST.KARAHAT_SUNSET:
        return QUEST_STATE.ACTIVE;

      // adhkar and thikr must wait until isSalahRowCompletedSalah
      case QUEST.MORNING_ADHKAR:
      case QUEST.EVENING_ADHKAR:
      case QUEST.FAJR_THIKR:
      case QUEST.DHUHR_THIKR:
      case QUEST.ASR_THIKR:
      case QUEST.MAGHRIB_THIKR:
      case QUEST.ISHA_THIKR:
        if (isSalahRowCompletedSalah) return QUEST_STATE.ACTIVE;
        return QUEST_STATE.NOT_ACTIVE_YET;

      // Salah duas wait until salah, adhkar, and thikr quests are complete
      case QUEST.FAJR_DUA:
      case QUEST.DHUHR_DUA:
      case QUEST.ASR_DUA:
      case QUEST.MAGHRIB_DUA:
      case QUEST.ISHA_DUA:
        if (isSalahRowCompletedAdhkarAndThikr) return QUEST_STATE.ACTIVE;
        return QUEST_STATE.NOT_ACTIVE_YET;

      // Edge case, can't do Maghrib task until Maghrib time comes in. We need
      // this since Sunsetting time is active/pinned on Maghrib zRow before
      // Maghrib times comes in (Karahat sunset completed before time came in).
      case QUEST.MAGHRIB_FARD:
        if (ZamanC.to.currZ == Z.Maghrib) return QUEST_STATE.ACTIVE;
        return QUEST_STATE.NOT_ACTIVE_YET;

      // Edge case, can't do Ishraq task until Ishraq time comes in. We need
      // this since Ishraq time is active/pinned on Dhuha zRow before
      // Ishraq times comes in (Karahat sunrise completed before time came in).
      case QUEST.DHUHA_ISHRAQ:
        if (ZamanC.to.currZ == Z.Ishraq) return QUEST_STATE.ACTIVE;
        return QUEST_STATE.NOT_ACTIVE_YET;

      // Edge case, can't do Dhuha task until Dhuha time comes in. We need
      // this since Dhuha time is active/pinned on Dhuha zRow before
      // Dhuha times comes in (Ishraq was completed before time came in).
      case QUEST.DHUHA_DHUHA:
        if (ZamanC.to.currZ == Z.Dhuha) return QUEST_STATE.ACTIVE;
        return QUEST_STATE.NOT_ACTIVE_YET;
    }
  }
}

/// Controls Active Quests Ajr/Points via storing QUEST results in 3 ints to
/// know if the QUEST is done (completed by user), skipped (by user), or missed
/// (the user didn't complete the quest so it expired on them). The ints store a
/// QUEST's result by using the Enum index and using it as a bit/binary offset.
class ActiveQuestsAjrC extends GetxHapi {
  static ActiveQuestsAjrC get to => Get.find();

  int _questsDone = 0;
  int _questsSkip = 0;
  int _questsMiss = 0;

  initCurrQuest(Z currZ, bool readOrInit) async {
    if (readOrInit) {
      ActiveQuestModel? m = await Db.getActiveQuest(TimeC.to.currDay);
      if (m != null) {
        _questsDone = m.done;
        _questsSkip = m.skip;
        _questsMiss = m.miss;
      } else {
        // not found in db so make first entry
        await Db.setActiveQuest(
          ActiveQuestModel(
            day: TimeC.to.currDay,
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
    for (QUEST q in QUEST.values) {
      lastQuest = q;
      QUEST? firstQuestToNotSetMiss = currZ.firstQuestToNotSetMiss();
      if (firstQuestToNotSetMiss == null || q == firstQuestToNotSetMiss) {
        l.i('Stopping init: $q, _questsMiss=$_questsMiss');
        break;
      }
      if (isComplete(q)) continue; // task was completed already

      // As long as Duha and Maghrib rows are pinned allow their Karahat Quests
      if (currZ.index <= Z.Istiwa.index) {
        // As long as Duha row is pinned allow karahat Quests (Istiwa too)
        if (q == QUEST.KARAHAT_SUNRISE) continue;
      } else if (currZ.index <= Z.Maghrib.index) {
        // As long as Maghrib row is pinned allow karahat sunset Quest
        if (q == QUEST.KARAHAT_SUNSET) continue;
      } else if (currZ == Z.Ghurub) {
        // We are in Ghurub/Sunsetting time but we need to allow user to still
        // do their adhkar until sunset.  Therefore, we don't force miss the
        // below quests when Ghurub time comes in:
        if (q == QUEST.EVENING_ADHKAR ||
            q == QUEST.ASR_THIKR ||
            q == QUEST.ASR_DUA) {
          continue;
        }
      } else if (currZ == Z.Last_3rd_of_Night) {
        // We are in Last 3rd of Night time but we need to allow user to still
        // do their Middle of Night ibadah. Therefore, we don't force miss the
        // below quests when Last_3rd_of_Night of night time comes in:
        if (q == QUEST.LAYL_QIYAM ||
            q == QUEST.LAYL_THIKR ||
            q == QUEST.LAYL_DUA) {
          continue;
        }
      }

      // user never inputted this value, and its time expired, set it as missed
      _setMiss(q); // Does don't write to DB
    }

    // only update db if new misses were found
    if (questsMissCopy != _questsMiss) {
      updateDB(lastQuest, BitType.MISS);
      ActiveQuestsC.to.update(); // refresh UI, prob not needed but OK
    }
  }

  bool isQuestAtCurrIdx(QUEST q) => getCurrIdx == q.index;

  /// Returns the first incomplete bit index
  get getCurrIdx {
    int allQuests = _questsDone | _questsSkip | _questsMiss;
    if (allQuests == 0) return 0; // avoid "0"/"1" binary case from below:
    return allQuests.toRadixString(2).length;
  }

  QUEST getCurrQuest() => QUEST.values[getCurrIdx];
  QUEST getPrevQuest() => QUEST.values[getCurrIdx - 1 < 0 ? 0 : getCurrIdx - 1];
  QUEST getNextQuest() => QUEST.values[getCurrIdx >= QUEST.LAYL_WITR.index
      ? QUEST.LAYL_WITR.index
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
      isComplete(QUEST.EVENING_ADHKAR) &&
      isComplete(QUEST.ASR_THIKR) &&
      isComplete(QUEST.ASR_DUA);

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

  bool get isMiddleOfNightNotStartedYet =>
      isNotComplete(QUEST.LAYL_QIYAM) &&
      isNotComplete(QUEST.LAYL_THIKR) &&
      isNotComplete(QUEST.LAYL_DUA);

  bool get isLastThirdOfNightNotStartedYet =>
      isNotComplete(QUEST.LAYL_SLEEP) &&
      isNotComplete(QUEST.LAYL_TAHAJJUD) &&
      isNotComplete(QUEST.LAYL_WITR);

  setDone(QUEST q) => _setBit(q, BitType.DONE, true);
  setSkip(QUEST q) => _setBit(q, BitType.SKIP, true);
  _setMiss(QUEST q) => _setBit(q, BitType.MISS, false);
  _setBit(QUEST q, BitType bitType, bool updateDb) {
    switch (bitType) {
      case BitType.DONE:
        _questsDone |= 1 << q.index;
        break;
      case BitType.SKIP:
        _questsSkip |= 1 << q.index;
        break;
      case BitType.MISS:
        _questsMiss |= 1 << q.index;
        break;
    }

    if (updateDb) {
      // don't do work of big binary output, unless verbose mode is on
      if (l.isVerboseMode) {
        switch (bitType) {
          case BitType.DONE:
            l.v(_questsDone.toRadixString(2));
            break;
          case BitType.SKIP:
            l.v(_questsSkip.toRadixString(2));
            break;
          case BitType.MISS:
            l.v(_questsMiss.toRadixString(2));
            break;
        }
      }

      // only needed on data changes, see handleTooltipUpdate()
      if (q.index > QUEST.ISHA_DUA.index) ZamanC.to.handleTooltipUpdate(null);

      // We don't have to do this because if middle of night just starting and
      // still in isha time, we still countdown to middle of night:
      // } else if (q == QUEST.ISHA_DUA && ZamanController.to.currZ == Z.Isha) {
      //   // if final isha task done in isha time, update tooltip now
      //   ZamanController.to.forceSalahRecalculation();
      // }

      ActiveQuestsC.to.update(); // refresh UI (don't wait for below)

      updateDB(q, bitType); // TODO catch e to undo/not flush bit?
    }
  }

//   void setClearQuest(QUEST q) {
//     l.v('clearQuest: $quest (index=${q.index}) = $_questsMiss');
//     _questsDone &= ~(1 << q.index);
//     _questsSkip &= ~(1 << q.index);
//     _questsMiss &= ~(1 << q.index);
//
//     // Prob not needed here, but ok:
//     if (q.index > QUEST.ISHA_DUA.index) {
//       ZamanController.to.handleTooltipUpdate(null);
//     }
//
//     // NOTE: Caller sets new bits after clearing, so don't need below:
// //  updateDB();
// //  ActiveQuestsController.to.update();
//   }

  updateDB(QUEST q, BitType bitType) async {
    l.d(':updateDB(${q.name}): ${bitType.name} bit(s) changed, writing DONE=$_questsDone, SKIP=$_questsSkip, MISS=$_questsMiss');

    await Db.setActiveQuest(
      ActiveQuestModel(
        day: TimeC.to.currDay,
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

    for (Z z in zRows) {
      getZamanRingColor(questRingColors, z);
    }

    return questRingColors;
  }

  void getZamanRingColor(Map<Z, int> questRingColors, Z z) {
    List<QUEST> quests = z.getZRowQuests();

    int ajrCount = 0;
    for (QUEST q in quests) {
      if (isDone(q)) ajrCount++;
    }

    if (ajrCount == 0) {
      int missCount = 0;
      for (QUEST q in quests) {
        if (isMiss(q)) missCount++;
      }
      // 0=ajrXMissed, 7=ajrXTimeNotInYet:
      ajrCount = missCount == quests.length ? 0 : 7;
    } else {
      if (quests.length < 6) {
        int ajrStartingPoint = 6 - quests.length;
        ajrCount += ajrStartingPoint;
      }
    }

    questRingColors[z] = ajrCount;
  }
}
