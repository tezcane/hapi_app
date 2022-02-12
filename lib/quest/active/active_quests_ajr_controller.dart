import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/Zaman.dart';

// cAjrA = controller ajr active (quests):
final ActiveQuestsAjrController cAjrA = Get.find();

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAKB, // Muakaddah Before
  FAJR_FARD,
  FAJR_THIKR,
  FAJR_DUA,

  DUHA_ADHKAR,
  DUHA_ISHRAQ,
  DUHA_DUHA,
  DUHA_ZAWAL,

  DHUHR_MUAKB4,
  DHUHR_FARD,
  DHUHR_MUAKA, // Muakaddah After
  DHUHR_NAFLA, // Nafl After
  DHUHR_THIKR,
  DHUHR_DUA,

  ASR_NAFLB, // Nafl Before
  ASR_FARD,
  ASR_THIKR,
  ASR_DUA,
  ASR_ADHKAR,

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

extension enumUtil on QUEST {
  /// Returns first part enum (must be uppercase), so: FAJR_FARD -> returns FAJR
  String salahRow() {
    return this.toString().split('.').last.split('_').first;
  }

  bool isFard() => this.toString().split('.').last.endsWith('FARD');
  bool isMuak() => this.toString().split('.').last.contains('MUAK');
  bool isNafl() => this.toString().split('.').last.contains('NAFL');

  bool isMuakBef() => this.toString().split('.').last.endsWith('MUAKB');
  bool isMuakAft() => this.toString().split('.').last.endsWith('MUAKA');
  bool isNaflBef() => this.toString().split('.').last.endsWith('NAFLB');
  bool isNaflAft() => this.toString().split('.').last.endsWith('NAFLA');

  bool isThikr() => this.toString().split('.').last.endsWith('THIKR');
  bool isDua() => this.toString().split('.').last.endsWith('DUA');
}

class ActiveQuestsAjrController extends GetxController {
//RxInt _questsAll = 0.obs;
  RxInt _questsDone = 0.obs;
  RxInt _questsSkip = 0.obs;
  RxInt _questsMiss = 0.obs;

  RxBool _isIshaIbadahComplete = false.obs;

  bool get isIshaIbadahComplete => _isIshaIbadahComplete.value;
  set isIshaIbadahComplete(bool value) {
    _isIshaIbadahComplete.value = value;
    //s.write('showSunnahKeys', value);
    update();
  }

  @override
  void onInit() {
    _questsDone.value = s.read('questsDone') ?? 0;
    _questsSkip.value = s.read('questsSkip') ?? 0;
    _questsMiss.value = s.read('questsMiss') ?? 0;

    initCurrQuest();

    //_isIshaIbadahComplete.value = false;

    super.onInit();
  }

  void printBinary(int input) {
    print(input.toRadixString(2));
  }

  printBinaryAll() {
    print(
        'questsDone=${_questsDone.value}, questsSkip=${_questsSkip.value}, questsMiss=${_questsMiss.value}, questsAll=${questsAll()}:');
    printBinary(_questsDone.value);
    printBinary(_questsSkip.value);
    printBinary(_questsMiss.value);
    printBinary(questsAll());
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
        print('Stopping init: $quest = ${_questsMiss.value}');
        break;
      }

      int curBitMask = 0x1 << quest.index;
      if (curBitMask & _questsDone.value != 0) continue;
      if (curBitMask & _questsSkip.value != 0) continue;
      if (curBitMask & _questsMiss.value != 0) continue;

      // user never inputted this value, we assume it is missed:
      setMiss(quest);
    }
  }

  int getCurrIdx() => questsAll().toRadixString(2).length;
  QUEST getCurrQuest() => QUEST.values[getCurrIdx()];
  QUEST getPrevQuest() =>
      QUEST.values[getCurrIdx() - 1 < 0 ? 0 : getCurrIdx() - 1];
  QUEST getNextQuest() => QUEST.values[getCurrIdx() + 1 >= QUEST.NONE.index
      ? QUEST.NONE.index - 1
      : getCurrIdx() + 1];

  bool isQuestActive(QUEST q) => getCurrIdx() == q.index;

  int questsAll() => _questsDone.value | _questsSkip.value | _questsMiss.value;

  void setDone(QUEST quest) {
    print('');
    print('');
    print('setDone: $quest (index=${quest.index}) = ${_questsMiss.value}');
    printBinaryAll();
    _questsDone.value |= 1 << quest.index;
    cQstA.update(); // refresh UI
    printBinaryAll();
  }

  void setSkip(QUEST quest) {
    print('');
    print('');
    print('setSkip: $quest (index=${quest.index}) = ${_questsMiss.value}');
    printBinaryAll();
    _questsSkip.value |= 1 << quest.index;
    cQstA.update(); // refresh UI
    printBinaryAll();
  }

  void setMiss(QUEST quest) {
    print('');
    print('');
    print('setMiss: $quest (index=${quest.index}) = ${_questsMiss.value}');
    printBinaryAll();
    _questsMiss.value |= 1 << quest.index;
    cQstA.update(); // refresh UI
    printBinaryAll();
  }

  void clearQuest(QUEST quest) {
    print('');
    print('');
    print('clearQuest: $quest (index=${quest.index}) = ${_questsMiss.value}');
    printBinaryAll();
    _questsDone.value &= ~(1 << quest.index);
    _questsSkip.value &= ~(1 << quest.index);
    _questsMiss.value &= ~(1 << quest.index);
    cQstA.update(); // refresh UI
    printBinaryAll();
  }

  /// Call at start of next day
  void clearAllQuests() {
    _questsDone.value = 0;
    _questsSkip.value = 0;
    _questsMiss.value = 0;
  }

  bool isDone(QUEST q) => (_questsDone.value >> q.index) & 1 == 1;
  bool isSkip(QUEST q) => (_questsSkip.value >> q.index) & 1 == 1;
  bool isMiss(QUEST q) => (_questsMiss.value >> q.index) & 1 == 1;
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
