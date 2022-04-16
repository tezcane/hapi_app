import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';

/// Z = Zaman/Time Of Day, enum that goes with each important islamic day point.
/// Used with Athan class to match up those calculated times to this enum.
enum Z {
  Fajr,
  Karahat_Morning_Adhkar, // begin sunrise (karahat 1), also Morning Adhkar time
  Ishraq,
  Duha,
  Karahat_Istiwa, // begin sun zenith/peaking (karahat 2)
  Dhuhr,
  Asr_Earlier,
  Asr_Later,
  Karahat_Evening_Adhkar, // begin sunset (karahat 3), also Evening Adhkar time
  Maghrib,
  Isha,
  Layl__2, // Middle of night
  Layl__3, // Last 3rd of Night
  Fajr_Tomorrow,
}

extension EnumUtil on Z {
  /// Special logic and rules here to rename enum to a nice name:
  ///     Karahat_ -> '' (blank)
  ///           __ -> /
  ///            _ -> ' ' (space)
  /// Optional withAsr flag set to fal will also remove:
  ///       _Later ->  '' (blank)
  ///     _Earlier ->  '' (blank)
  String niceName({bool shortenAsrName = true}) {
    if (this == Z.Dhuhr &&
        TimeController.to.isFriday() &&
        ActiveQuestsController.to.showJummahOnFriday) {
      return 'Jummah';
    }

    String rv = name;
    if (shortenAsrName) {
      rv = rv.replaceFirst('_Later', '').replaceFirst('_Earlier', '');
    }
    return rv
        .replaceFirst('Karahat_', '')
        .replaceFirst('__', '/')
        .replaceAll('_', ' ');
  }

  // /// Sometimes to make UI look nice we need to make pad the length of this for
  // /// main_controller.T() prints.
  // String get niceNamePadded {
  //   String name = niceName();
  //
  //   while (name.length < 7) {
  //     name += '  '; // add until we match maghrib and night/X 7 chars long
  //   }
  //
  //   // still too small, so add manually:
  //   if (this == Z.Fajr || this == Z.Isha) name += ' ';
  //   if (this == Z.Asr_Earlier || this == Z.Asr_Later) name += '  ';
  //   return name;
  // }

  // String salahRow() {
  //   switch (this) {
  //     case (Z.Fajr):
  //       return 'FAJR';
  //     case (Z.Karahat_Morning_Adhkar):
  //     case (Z.Ishraq):
  //     case (Z.Duha):
  //     case (Z.Karahat_Istiwa):
  //       return 'DUHA';
  //     case (Z.Dhuhr):
  //       return 'DHUHR';
  //     case (Z.Asr_Later):
  //     case (Z.Asr_Earlier):
  //     case (Z.Karahat_Evening_Adhkar):
  //       return 'ASR';
  //     case (Z.Maghrib):
  //       return 'MAGHRIB';
  //     case (Z.Isha):
  //       return 'ISHA';
  //     case (Z.Layl__2):
  //     case (Z.Layl__3):
  //       return 'LAYL';
  //     default:
  //       String e = 'Z:salahRow: Invalid Z "$this" given';
  //       l.e(e);
  //       throw e;
  //   }
  // }

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
      case (Z.Karahat_Istiwa):
        return QUEST.KARAHAT_ADHKAR_ISTIWA;
      case (Z.Dhuhr):
        return QUEST.DHUHR_MUAKB;
      case (Z.Asr_Earlier):
      case (Z.Asr_Later):
        return QUEST.ASR_NAFLB;
      case (Z.Karahat_Evening_Adhkar):
        return QUEST.KARAHAT_ADHKAR_SUNSET;
      case (Z.Maghrib):
        return QUEST.MAGHRIB_FARD;
      case (Z.Isha):
        return QUEST.ISHA_NAFLB;
      case (Z.Layl__2):
      case (Z.Layl__3):
      case (Z.Fajr_Tomorrow): // still needed so we can set misses
        return QUEST.LAYL_QIYAM;
      default:
        String e = 'Z:getFirstQuest: Invalid Z "$this" given';
        l.e(e);
        throw e;
    }
  }

  // QUEST getLastQuest() {
  //   switch (this) {
  //     case (Z.Fajr):
  //       return QUEST.FAJR_DUA;
  //     case (Z.Karahat_Morning_Adhkar):
  //       return QUEST.KARAHAT_ADHKAR_SUNRISE;
  //     case (Z.Ishraq):
  //       return QUEST.DUHA_ISHRAQ;
  //     case (Z.Duha):
  //       return QUEST.DUHA_DUHA;
  //     case (Z.Karahat_Istiwa):
  //       return QUEST.KARAHAT_ADHKAR_ISTIWA;
  //     case (Z.Dhuhr):
  //       return QUEST.DHUHR_DUA;
  //     case (Z.Asr_Earlier):
  //     case (Z.Asr_Later):
  //       return QUEST.ASR_DUA;
  //     case (Z.Karahat_Evening_Adhkar):
  //       return QUEST.KARAHAT_ADHKAR_SUNSET;
  //     case (Z.Maghrib):
  //       return QUEST.MAGHRIB_DUA;
  //     case (Z.Isha):
  //       return QUEST.ISHA_DUA;
  //     case (Z.Layl__2):
  //       return QUEST.LAYL_WITR;
  //     case (Z.Layl__3):
  //       return QUEST.LAYL_WITR;
  //     default:
  //       String e = 'Z:getLastQuest: Invalid Z "$this" given';
  //       l.e(e);
  //       throw e;
  //   }
  // }

  bool isAboveHorizon() {
    switch (this) {
      case (Z.Karahat_Morning_Adhkar):
      case (Z.Ishraq):
      case (Z.Duha):
      case (Z.Karahat_Istiwa):
      case (Z.Dhuhr):
      case (Z.Asr_Earlier):
      case (Z.Asr_Later):
      case (Z.Karahat_Evening_Adhkar):
        return true;
      case (Z.Maghrib):
      case (Z.Isha):
      case (Z.Layl__2):
      case (Z.Layl__3):
      case (Z.Fajr):
      case (Z.Fajr_Tomorrow):
        return false;
      default:
        String e = 'Z:isSunAboveHorizon: Invalid Z "$this" given';
        l.e(e);
        throw e;
    }
  }
}
