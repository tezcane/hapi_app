import 'package:get/get.dart';
import 'package:hapi/main.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/TOD.dart';

// cAjrA = controller ajr active (quests):
final ActiveQuestsAjrController cAjrA = Get.find();

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAKB, // Muakaddah Before
  FAJR_FARD,
  FAJR_THIKR,
  FAJR_DUA,

  KERAHAT_ADHKAR_SUNRISE,

  DUHA_ISHRAQ,
  DUHA_DUHA,

  KERAHAT_ADHKAR_ZAWAL, // TODO does this have a adkhar too?

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

  KERAHAT_ADHKAR_SUNSET,

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

  bool isQuestCellTimeBound() {
    switch (this) {
      case (QUEST.KERAHAT_ADHKAR_SUNRISE):
      case (QUEST.DUHA_ISHRAQ):
      case (QUEST.DUHA_DUHA):
      case (QUEST.KERAHAT_ADHKAR_ZAWAL):
      case (QUEST.KERAHAT_ADHKAR_SUNSET):
        return true;
      default:
        return false;
    }
  }

  TOD getStartZaman() {
    switch (this) {
      case (QUEST.FAJR_MUAKB):
      case (QUEST.FAJR_FARD):
      case (QUEST.FAJR_THIKR):
      case (QUEST.FAJR_DUA):
        return TOD.Fajr;
      case (QUEST.KERAHAT_ADHKAR_SUNRISE):
        return TOD.Kerahat_Sunrise;
      case (QUEST.DUHA_ISHRAQ):
        return TOD.Ishraq;
      case (QUEST.DUHA_DUHA):
        return TOD.Duha;
      case (QUEST.KERAHAT_ADHKAR_ZAWAL):
        return TOD.Kerahat_Zawal;
      case (QUEST.DHUHR_MUAKB):
      case (QUEST.DHUHR_FARD):
      case (QUEST.DHUHR_MUAKA):
      case (QUEST.DHUHR_NAFLA):
      case (QUEST.DHUHR_THIKR):
      case (QUEST.DHUHR_DUA):
        return TOD.Dhuhr;
      case (QUEST.ASR_NAFLB):
      case (QUEST.ASR_FARD):
      case (QUEST.ASR_THIKR):
      case (QUEST.ASR_DUA):
        return TOD.Asr;
      case (QUEST.KERAHAT_ADHKAR_SUNSET):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.MAGHRIB_FARD):
      case (QUEST.MAGHRIB_MUAKA):
      case (QUEST.MAGHRIB_NAFLA):
      case (QUEST.MAGHRIB_THIKR):
      case (QUEST.MAGHRIB_DUA):
        return TOD.Maghrib;
      case (QUEST.ISHA_NAFLB):
      case (QUEST.ISHA_FARD):
      case (QUEST.ISHA_MUAKA):
      case (QUEST.ISHA_NAFLA):
      case (QUEST.ISHA_THIKR):
      case (QUEST.ISHA_DUA):
        return TOD.Isha;
      case (QUEST.LAYL_QIYAM):
      case (QUEST.LAYL_THIKR):
      case (QUEST.LAYL_DUA):
      case (QUEST.LAYL_SLEEP):
      case (QUEST.LAYL_TAHAJJUD):
      case (QUEST.LAYL_WITR):
        return TOD.Isha; // Note qiyam prayer can occur during isha
      default:
        return TOD.Isha;
    }
  }

  TOD getEndZaman() {
    switch (this) {
      case (QUEST.FAJR_MUAKB):
        return TOD.Kerahat_Sunrise;
      case (QUEST.FAJR_FARD):
        return TOD.Kerahat_Sunrise;
      case (QUEST.FAJR_THIKR):
        return TOD.Kerahat_Sunrise;
      case (QUEST.FAJR_DUA):
        return TOD.Kerahat_Sunrise;
      case (QUEST.KERAHAT_ADHKAR_SUNRISE):
        return TOD.Ishraq;
      case (QUEST.DUHA_ISHRAQ):
        return TOD.Duha;
      case (QUEST.DUHA_DUHA):
        return TOD.Kerahat_Zawal;
      case (QUEST.KERAHAT_ADHKAR_ZAWAL):
        return TOD.Dhuhr;
      case (QUEST.DHUHR_MUAKB):
        return TOD.Asr;
      case (QUEST.DHUHR_FARD):
        return TOD.Asr;
      case (QUEST.DHUHR_MUAKA):
        return TOD.Asr;
      case (QUEST.DHUHR_NAFLA):
        return TOD.Asr;
      case (QUEST.DHUHR_THIKR):
        return TOD.Asr;
      case (QUEST.DHUHR_DUA):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.ASR_NAFLB):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.ASR_FARD):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.ASR_THIKR):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.ASR_DUA):
        return TOD.Kerahat_Sun_Setting;
      case (QUEST.KERAHAT_ADHKAR_SUNSET):
        return TOD.Maghrib;
      case (QUEST.MAGHRIB_FARD):
        return TOD.Isha;
      case (QUEST.MAGHRIB_MUAKA):
        return TOD.Isha;
      case (QUEST.MAGHRIB_NAFLA):
        return TOD.Isha;
      case (QUEST.MAGHRIB_THIKR):
        return TOD.Isha;
      case (QUEST.MAGHRIB_DUA):
        return TOD.Isha;
      case (QUEST.ISHA_NAFLB):
        return TOD.Fajr_Tomorrow;
      case (QUEST.ISHA_FARD):
        return TOD.Fajr_Tomorrow;
      case (QUEST.ISHA_MUAKA):
        return TOD.Fajr_Tomorrow;
      case (QUEST.ISHA_NAFLA):
        return TOD.Fajr_Tomorrow;
      case (QUEST.ISHA_THIKR):
        return TOD.Fajr_Tomorrow;
      case (QUEST.ISHA_DUA):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_QIYAM):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_THIKR):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_DUA):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_SLEEP):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_TAHAJJUD):
        return TOD.Fajr_Tomorrow;
      case (QUEST.LAYL_WITR):
        return TOD.Fajr_Tomorrow;
      default:
        return TOD.Fajr_Tomorrow;
    }
  }
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
    while (cQstA.tod == null) {
      print(
          'ActiveQuestsAjrController.initCurrQuest: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) {
        sleepBackoffSecs++;
      }
    }

    TOD currZaman = cQstA.tod!.currTOD;

    for (QUEST quest in QUEST.values) {
      if (quest.index == currZaman.getFirstQuest().index) {
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
