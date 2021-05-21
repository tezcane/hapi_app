import 'package:cloud_firestore/cloud_firestore.dart';

enum QUEST_TYPE {
  IBADAH,
  // FARD, // 5 daily prayers, fasting in Ramadan
  // MUAK, // Sunnah Muakkadah 12 Rakat sunnah, witr, fasting monday/thursday.
  // NAFL, // Other Sunnah, miswak, washing hands, etc.
  DAILY, // DAILY, Mumeen chests
  USER, // USER'S PERSONAL HEALTH, PERSONAL/FAMILY TIME, etc. fall in here
  // QUIZ, ask Q's that they can go look up around Relics
  HAPI, // HAPI QUESTS, like collect 10 names of Allah SWT.
}

// Halal- 5 levels - Haram
enum SUNNAH_CLASS {
  FARD,
  MUAK, // MUAKKADAH/
  NAFL,
}

// Location of sun:
// IMSAK,
// SUNRISE,
// SUN_ZENITH,
// SUNSET,

// Halal- 5 levels - Haram
enum Ahkam {
  //https://en.wikipedia.org/wiki/Ahkam
  //https://www.thedeenshow.com/halal-mustahabb-mubah-makrooh-haram/
  FARD, // WAJIB
  MUSTAHABB, // or MANDOOK, SHOULD DO FOR AJR
  MUBAH, // PERMITTED, DON'T DO NO SIN
  MAKRUH, // DON'T DO IS BETTER, DO TOO MUCH IS SIN
  HARAM, // SIN
}

enum IBADAH_TYPE {
  //https://seekersguidance.org/articles/knowledge/ten-types-of-ibadah-worship-imam-al-ghazzali/
  SALAH,
  SAWM,
  CHARITY, // ZAKAT,SADAQAH,
  TRAVEL, // HAJJ, UMRAH, VISIT MASJID HARAM, NABAWAI, AQSA,
  THIKR, //READ, DUA,
  SOCIAL, //DAWAH, WORK, FAMILY Fullfil obligations to others, family/neighbors/friends
  JIHAD,
}

// ONLY NEW VALUES CAN BE ADDED TO PRESERVE ENUM IN DB:
enum QUEST {
  FARD_SALAH_FAJR,
  FARD_SALAH_DHUHR,
  FARD_SALAH_ASR,
  FARD_SALAH_ISHA,
  FARD_SALAH_MAGHRIB,

  FARD_SAWM, // RAMADAN
  FARD_ZAKAT,
  FARD_HAJJ,

  // SUNNAH MUAKADAH **
  MUAK_SALAH_FAJR_2,
  MUAK_SALAH_DHUHR_4,
  MUAK_SALAH_DHUHR_2,
  MUAK_SALAH_MAGHRIB_2,
  MUAK_SALAH_ISHA_2,
  MUAK_SALAH_WITR_3,

  MUAK_SALAH_JUMA,
  MUAK_JUMA_GHUSUL,

  MUAK_QURAN,
  MUAK_SADAQAH,
  MUAK_UMRAH,
  MUAK_SAWM_ARAFAT,

  //** MORE

  // SUNAH NAFL **
  NAFL_SALAH_ASR_4,
  MUAK_SALAH_TAHAJJUD,
  NAFL_SALAH_TARAWEH, // **TAHAJUD in RAMADAN?

  NAFL_SALAH_ISTIKHARA,
  NAFL_SALAH_TAHIYATUL_WUDU,
  NAFL_SALAH_TAHIYATUL_MASJID,
//NAFL_SALAH_ISHRAQ, no such thing //** SAME? AS DUHA? ** = ask scholar
  NAFL_SALAH_DUHA,

//NAFL_HADITH,

  USER_WORK_TIME,
  USER_FAMILY_TIME,
  USER_PERSONAL_TIME,
  USER_CALENDAR_EVENT, //TODO import from user calendar

  USER_CUSTOM,
}

class QuestModel {
  String questId;
  QUEST questType;
  String content;
  Timestamp dateCreated;
  Timestamp? dateStart;
  Timestamp? dateEnd;
  Timestamp? dateDone;
  bool done;

  QuestModel(
      {required this.questId,
      required this.questType,
      required this.content,
      required this.dateCreated,
      required this.dateStart,
      required this.dateEnd,
      required this.dateDone,
      required this.done});

  factory QuestModel.fromMap(String questId, Map data) {
    return QuestModel(
      questId: questId,
      questType: data['quest'] ?? QUEST.USER_CUSTOM,
      content: data['content'],
      dateCreated: data['dateCreated'],
      dateStart: data['dateStart'] ?? null,
      dateEnd: data['dateEnd'] ?? null,
      dateDone: data['dateDone'] ?? null,
      done: data['done'],
    );
  }
}
