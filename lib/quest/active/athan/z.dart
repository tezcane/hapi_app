import 'package:hapi/quest/active/active_quests_ajr_controller.dart';

/// Z = Zaman/Time Of Day, enum that goes with each important islamic day point.
/// Used with Athan class to match up those calculated times to this enum.
enum Z {
  Fajr,
  Karahat_Morning_Adhkar, // begin sunrise (kerahat 1), also Morning Adhkar time
  Ishraq,
  Duha,
  Karahat_Zawal, // begin sun zentih/peaking (kerahat 2)
  Dhuhr,
  Asr,
  Karahat_Evening_Adhkar, // begin sunset (kerahat 3), also Evening Adhkar time
  Maghrib,
  Isha,
  Night__2,
  Night__3,
  Fajr_Tomorrow,
}

extension EnumUtil on Z {
  /// Special logic and rules here to rename enum to a nice name:
  ///     Kerahat_ -> '' (blank)
  ///           __ -> /
  ///            _ -> ' ' (space)
  String get niceName => name
      .replaceFirst('Karahat_', '')
      .replaceFirst('__', '/')
      .replaceAll('_', ' ');

  /// Sometimes to make UI look nice we need to make pad the length of this for
  /// main_controller.T() prints.
  String get niceNamePadded {
    String name = niceName;
    while (name.length < 7) {
      name += ' '; // add until we match maghrib and night/X 7 chars long
    }
    return name;
  }

  String salahRow() {
    switch (this) {
      case (Z.Fajr):
        return 'FAJR';
      case (Z.Karahat_Morning_Adhkar):
      case (Z.Ishraq):
      case (Z.Duha):
      case (Z.Karahat_Zawal):
        return 'DUHA';
      case (Z.Dhuhr):
        return 'DHUHR';
      case (Z.Asr):
      case (Z.Karahat_Evening_Adhkar):
        return 'ASR';
      case (Z.Maghrib):
        return 'MAGHRIB';
      case (Z.Isha):
        return 'ISHA';
      case (Z.Night__2):
      case (Z.Night__3):
      default:
        return 'LAYL';
    }
  }

  QUEST getFirstQuest() {
    switch (this) {
      case (Z.Fajr):
        return QUEST.FAJR_MUAKB;
      case (Z.Karahat_Morning_Adhkar):
        return QUEST.KARAHAT_ADHKAR_SUNRISE;
      case (Z.Ishraq):
        return QUEST.DUHA_ISHRAQ;
      case (Z.Duha):
        return QUEST.DUHA_DUHA;
      case (Z.Karahat_Zawal):
        return QUEST.KARAHAT_ADHKAR_ZAWAL;
      case (Z.Dhuhr):
        return QUEST.DHUHR_MUAKB;
      case (Z.Asr):
        return QUEST.ASR_NAFLB;
      case (Z.Karahat_Evening_Adhkar):
        return QUEST.KARAHAT_ADHKAR_SUNSET;
      case (Z.Maghrib):
        return QUEST.MAGHRIB_FARD;
      case (Z.Isha):
        return QUEST.ISHA_NAFLB;
      case (Z.Night__2):
        return QUEST.LAYL_QIYAM;
      case (Z.Night__3):
        return QUEST.LAYL_QIYAM;
      default:
        return QUEST.LAYL_QIYAM;
    }
  }

  QUEST getLastQuest() {
    switch (this) {
      case (Z.Fajr):
        return QUEST.FAJR_DUA;
      case (Z.Karahat_Morning_Adhkar):
        return QUEST.KARAHAT_ADHKAR_SUNRISE;
      case (Z.Ishraq):
        return QUEST.DUHA_ISHRAQ;
      case (Z.Duha):
        return QUEST.DUHA_DUHA;
      case (Z.Karahat_Zawal):
        return QUEST.KARAHAT_ADHKAR_ZAWAL;
      case (Z.Dhuhr):
        return QUEST.DHUHR_DUA;
      case (Z.Asr):
        return QUEST.ASR_DUA;
      case (Z.Karahat_Evening_Adhkar):
        return QUEST.KARAHAT_ADHKAR_SUNSET;
      case (Z.Maghrib):
        return QUEST.MAGHRIB_DUA;
      case (Z.Isha):
        return QUEST.ISHA_DUA;
      case (Z.Night__2):
        return QUEST.LAYL_WITR;
      case (Z.Night__3):
        return QUEST.LAYL_WITR;
      default:
        return QUEST.LAYL_WITR;
    }
  }
}
