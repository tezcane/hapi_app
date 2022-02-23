// ignore_for_file: constant_identifier_names

import 'package:hapi/quest/active/active_quests_ajr_controller.dart';

// TOD = Time Of Day
enum TOD {
  Fajr,
  Kerahat_Sunrise, // begin sunrise (kerahat 1), also Morning Adhkar time
  Ishraq,
  Duha,
  Kerahat_Zawal, // begin sun zentih/peaking (kerahat 2)
  Dhuhr,
  Asr,
  Kerahat_Sun_Setting, // begin sunset (kerahat 3), also Evening Adhkar time
  Maghrib,
  Isha,
  Middle_of_Night,
  Last_1__3_of_Night,
  Fajr_Tomorrow,
  Sunrise_Tomorrow,
}

extension EnumUtil on TOD {
  String name() {
    return toString()
        .split('.')
        .last
        .replaceFirst('Kerahat_', '')
        .replaceFirst('__', '/')
        .replaceAll('_', ' ');
  }

  String salahRow() {
    switch (this) {
      case (TOD.Fajr):
        return "FAJR";
      case (TOD.Kerahat_Sunrise):
      case (TOD.Ishraq):
      case (TOD.Duha):
      case (TOD.Kerahat_Zawal):
        return "DUHA";
      case (TOD.Dhuhr):
        return "DHUHR";
      case (TOD.Asr):
      case (TOD.Kerahat_Sun_Setting):
        return "ASR";
      case (TOD.Maghrib):
        return "MAGHRIB";
      case (TOD.Isha):
        return "ISHA";
      case (TOD.Middle_of_Night):
      case (TOD.Last_1__3_of_Night):
      default:
        return "LAYL";
    }
  }

  QUEST getFirstQuest() {
    switch (this) {
      case (TOD.Fajr):
        return QUEST.FAJR_MUAKB;
      case (TOD.Kerahat_Sunrise):
        return QUEST.KERAHAT_ADHKAR_SUNRISE;
      case (TOD.Ishraq):
        return QUEST.DUHA_ISHRAQ;
      case (TOD.Duha):
        return QUEST.DUHA_DUHA;
      case (TOD.Kerahat_Zawal):
        return QUEST.KERAHAT_ADHKAR_ZAWAL;
      case (TOD.Dhuhr):
        return QUEST.DHUHR_MUAKB;
      case (TOD.Asr):
        return QUEST.ASR_NAFLB;
      case (TOD.Kerahat_Sun_Setting):
        return QUEST.KERAHAT_ADHKAR_SUNSET;
      case (TOD.Maghrib):
        return QUEST.MAGHRIB_FARD;
      case (TOD.Isha):
        return QUEST.ISHA_NAFLB;
      case (TOD.Middle_of_Night):
        return QUEST.LAYL_QIYAM;
      case (TOD.Last_1__3_of_Night):
        return QUEST.LAYL_QIYAM;
      default:
        return QUEST.LAYL_QIYAM;
    }
  }

  QUEST getLastQuest() {
    switch (this) {
      case (TOD.Fajr):
        return QUEST.FAJR_DUA;
      case (TOD.Kerahat_Sunrise):
        return QUEST.KERAHAT_ADHKAR_SUNRISE;
      case (TOD.Ishraq):
        return QUEST.DUHA_ISHRAQ;
      case (TOD.Duha):
        return QUEST.DUHA_DUHA;
      case (TOD.Kerahat_Zawal):
        return QUEST.KERAHAT_ADHKAR_ZAWAL;
      case (TOD.Dhuhr):
        return QUEST.DHUHR_DUA;
      case (TOD.Asr):
        return QUEST.ASR_DUA;
      case (TOD.Kerahat_Sun_Setting):
        return QUEST.KERAHAT_ADHKAR_SUNSET;
      case (TOD.Maghrib):
        return QUEST.MAGHRIB_DUA;
      case (TOD.Isha):
        return QUEST.ISHA_DUA;
      case (TOD.Middle_of_Night):
        return QUEST.LAYL_WITR;
      case (TOD.Last_1__3_of_Night):
        return QUEST.LAYL_WITR;
      default:
        return QUEST.LAYL_WITR;
    }
  }
}
