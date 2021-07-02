import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';

final AjrController cAjr = Get.find();

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FAJR_MUAK_2,
  FAJR_FARD_2,
  FAJR_DHIKR,
  FAJR_DUA,

  DUHA_ADHKAR,
  DUHA_ISHRAQ_2,
  DUHA_DUHA,
  DUHA_ZAWAL,

  DHUHR_MUAK_4,
  DHUHR_FARD_4,
  DHUHR_MUAK_2,
  DHUHR_NAFL_2,
  DHUHR_DHIKR,
  DHUHR_DUA,

  ASR_NAFL_4,
  ASR_FARD_4,
  ASR_DHIKR,
  ASR_DUA,
  ASR_ADHKAR,

  MAGHRIB_FARD_3,
  MAGHRIB_MUAK_2,
  MAGHRIB_NAFL_2,
  MAGHRIB_DHIKR,
  MAGHRIB_DUA,

  ISHA_NAFL_4,
  ISHA_FARD_4,
  ISHA_MUAK_2,
  ISHA_NAFL_2,
  ISHA_DHIKR,
  ISHA_DUA,

  LAYL_QIYAM,
  LAYL_DHIKR,
  LAYL_DUA,
  LAYL_SLEEP,
  LAYL_TAHAJJUD,
  LAYL_WITR,
}

class AjrController extends GetxController {
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

    //_isIshaIbadahComplete.value = false;

    super.onInit();
  }

  bool isQuestActive(QUEST quest) {
    int questMask = 1 >> quest.index;
    int bitMask = ~questMask;
    return getQuestsAll() & bitMask == bitMask;
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
