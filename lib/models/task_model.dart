import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType {
  IMSAK,
  PRAYER_FAJR_SUNA_MUAKKADAH_2, // SUNA = SUNNAH
  PRAYER_FAJR_FARD_2,
  SUNRISE,
  SUN_APEX,
  PRAYER_DHUHR_SUNA_MUAKKADAH_4,
  PRAYER_DHUHR_FARD_4,
  PRAYER_DHUHR_SUNA_MUAKKADAH_2,
  PRAYER_ASR_SUNA_4,
  PRAYER_ASR_FARD_4,
  SUNSET,
  PRAYER_MAGHRIB_FARD_3,
  PRAYER_MAGHRIB_SUNA_MUAKKADAH_2,
  PRAYER_ISHA_FARD_4,
  PRAYER_ISHA_SUNA_MUAKKADAH_2,
  PRAYER_SUNA_WITR_3,
  PRAYER_SUNA_QIYAM, // TODO tahajud?
  PRAYER_SUNA_TARAWEH,
  PRAYER_SUNA_ISTIKHARA,
  PRAYER_SUNA_OTHER,
  FASTING_SUNA,
  FASTING_SUNA_ARAFAT, // TODO other fasting
  FASTING_FARD, //RAMADAN
  USER_QURAN,
  USER_HADITH,
  USER_WORK_TIME,
  USER_FAMILY_TIME,
  USER_PERSONAL_TIME,
  USER_CALENDAR_EVENT, //TODO import from user calendar
  UMMAH_GUARD, // Jihad
  USER_CUSTOM
}

class TaskModel {
  String taskId;
  TaskType taskType;
  String content;
  Timestamp dateCreated;
  Timestamp? dateStart;
  Timestamp? dateEnd;
  Timestamp? dateDone;
  bool done;

  TaskModel(
      {required this.taskId,
      required this.taskType,
      required this.content,
      required this.dateCreated,
      required this.dateStart,
      required this.dateEnd,
      required this.dateDone,
      required this.done});

  factory TaskModel.fromMap(String taskId, Map data) {
    return TaskModel(
      taskId: taskId,
      taskType: data['taskType'] ?? TaskType.USER_CUSTOM,
      content: data['content'],
      dateCreated: data['dateCreated'],
      dateStart: data['dateStart'] ?? null,
      dateEnd: data['dateEnd'] ?? null,
      dateDone: data['dateDone'] ?? null,
      done: data['done'],
    );
  }
}
