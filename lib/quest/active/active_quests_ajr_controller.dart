import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/Zaman.dart';

// cAjrA = controller ajr active (quests):
final ActiveQuestsAjrController cAjrA = Get.find();

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAK_2,
  FAJR_FARD,
  FAJR_THIKR,
  FAJR_DUA,

  DUHA_ADHKAR,
  DUHA_ISHRAQ,
  DUHA_DUHA,
  DUHA_ZAWAL,

  DHUHR_MUAK_4,
  DHUHR_FARD,
  DHUHR_MUAK_2,
  DHUHR_NAFL_2,
  DHUHR_THIKR,
  DHUHR_DUA,

  ASR_NAFL_4,
  ASR_FARD,
  ASR_THIKR,
  ASR_DUA,
  ASR_ADHKAR,

  MAGHRIB_FARD,
  MAGHRIB_MUAK_2,
  MAGHRIB_NAFL_2,
  MAGHRIB_THIKR,
  MAGHRIB_DUA,

  ISHA_NAFL_4,
  ISHA_FARD,
  ISHA_MUAK_2,
  ISHA_NAFL_2,
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

extension enumUtil on QUEST {
  String salahRow() {
    return this.toString().split('.').last.split('_').first;
  }
}

class ActiveQuestsAjrController extends GetxController {
//RxInt _questsAll = 0.obs;
  RxInt _questsCompleted = 0.obs;
  RxInt _questsSkipped = 0.obs;
  RxInt _questsMissed = 0.obs;

  RxBool _isIshaIbadahComplete = false.obs;

  bool get isIshaIbadahComplete => _isIshaIbadahComplete.value;
  set isIshaIbadahComplete(bool value) {
    _isIshaIbadahComplete.value = value;
    //s.write('showSunnahKeys', value);
    update();
  }

  @override
  void onInit() {
    _questsCompleted.value = s.read('questsCompleted') ?? 0;
    _questsSkipped.value = s.read('questsSkipped') ?? 0;
    _questsMissed.value = s.read('questsMissed') ?? 0;

    initCurrQuest();

    //_isIshaIbadahComplete.value = false;

    super.onInit();
  }

  void printBinary(int input) {
    print(input.toRadixString(2));
  }

  void initCurrQuest() async {
    int sleepBackoffSecs = 1;

    // No internet needed to init, but we put a back off just in case:
    while (cQstA.prayerTimes == null) {
      print(
          'ActiveQuestsAjrController.initCurrQuest: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) {
        sleepBackoffSecs++;
      }
    }

    Zaman currZaman = cQstA.prayerTimes!.currZaman;
    String currSalahRow = currZaman.salahRow();

    for (QUEST quest in QUEST.values) {
      if (currSalahRow == quest.salahRow()) {
        print('Stopping init: $quest = ${_questsMissed.value}');
        break;
      }

      int curBitMask = 0x1 << quest.index;
      if (curBitMask & _questsCompleted.value != 0) continue;
      if (curBitMask & _questsSkipped.value != 0) continue;
      if (curBitMask & _questsMissed.value != 0) continue;

      // user never inputted this value, we assume it is missed:
      _questsMissed.value = _questsMissed.value | curBitMask;
      print(
          'Skipped: $quest (index=${quest.index}) = ${_questsMissed.value} ($curBitMask)');
      printBinary(_questsMissed.value);
    }
  }

  bool isQuestActive(QUEST quest) {
    return getQuestsAll().toRadixString(2).length == quest.index;

    //TODO bitwise operations:

    // int questMask = (1 << quest.index);
    // if (((questsAll & 0xFFFFFFFFFF) >> quest.index) & 1 == 1) {
    //   return false;
    // }

    return false;
//   11111111111111 <- getQuestsAll()
//  100000000000000 <- questMask
//  011111111111111 <- bitMask (~questMask)
//                0 <- questMask & getQuestsAll()
    // print('\n\n');
    // print('\n\n');
    // print('quest=$quest');
    // int questMask = (1 << quest.index);
    // print('questMask=$questMask:');
    // printBinary(questMask);
    //
    // print('\n\n');
    // int bitMask = (~questMask);
    // print('bitMask=$bitMask:');
    // printBinary(bitMask);
    //
    // print('\n\n');
    // print('getQuestsAll=${getQuestsAll()}:');
    // printBinary(getQuestsAll());
    //
    // print('\n\n');
    // int anded = getQuestsAll() & bitMask;
    // print('anded=$anded:');
    // printBinary(anded);
    //
    // bool isQuestActive = anded & bitMask == anded;
    // print('isQuestActive=$isQuestActive');
    // return isQuestActive;
  }

  int getQuestsAll() {
    return _questsCompleted.value | _questsSkipped.value | _questsMissed.value;
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
