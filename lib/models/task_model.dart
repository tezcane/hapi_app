import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType {
  IMSAK,
  PRAYER_FAJR_SUNA_2, // SUNA = SUNNAH
  PRAYER_FAJR_FARD_2,
  SUNRISE,
  SUN_APEX,
  PRAYER_DHUHR_SUNA_4,
  PRAYER_DHUHR_FARD_4,
  PRAYER_DHUHR_SUNA_2,
  PRAYER_ASR_SUNA_4,
  PRAYER_ASR_FARD_4,
  SUNSET,
  PRAYER_MAGHRIB_FARD_3,
  PRAYER_MAGHRIB_SUNA_2,
  PRAYER_ISHA_FARD_4,
  PRAYER_ISHA_SUNA_2,
  PRAYER_SUNA_WITR_3,
  USER_QURAN,
  USER_HADITH,
  USER_WORK_TIME,
  USER_FAMILY_TIME,
  USER_PERSONAL_TIME,
  USER_CALENDAR_EVENT, //TODO import from user calendar
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
