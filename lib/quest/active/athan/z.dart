import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';

/// Z = Zaman/Time Of Day, enum that goes with each important islamic day point.
/// Used with Athan class to match up those calculated times to this enum.
enum Z {
  Fajr, // usually, when sun is 18 degrees below horizon before sunrise
  Shuruq, // Sunrise Karahat 1 - as soon as sun peaks over horizon
  Ishraq, // When sun rises 5 degrees over horizon (spear length)
  Duha, // Time after Ishraq to before Istiwa
  Istiwa, // Noon Karahat 2 - (sun at zenith/peak->istiwa
  Dhuhr, // Zawal - when sun passes zenith and shadow begin to grow
  Asr, // Sun casts a shadow of objects length (also has option for length x2)
  Ghurub, // Sunset Karahat 3 - 5 degrees over horizon (spear length)
  Maghrib, // As soon as sun is fully set
  Isha, // usually, when sun is 18 degrees below horizon after sunset
  Middle_of_Night, // (Maghrib to Fajr_Tomorrow)/2 - Isha before, Qiyam after
  Last_3rd_of_Night, // (Maghrib to Fajr_Tomorrow)/3 - Tahajjud after this
  Fajr_Tomorrow, // Start of the next "prayer" day where hapi points reset
}

extension EnumUtil on Z {
  /// Returns a trKey which can then be translated by calling Get's ".tr" on it.
  String get trKey {
    String transliteration = name;
    if (this == Z.Dhuhr && TimeController.to.isFriday()) {
      transliteration = 'Jumah';
    } else if (this == Z.Middle_of_Night) {
      transliteration = 'Muntasaf Allayl';
    } else if (this == Z.Last_3rd_of_Night) {
      transliteration = 'Althuluth Al\'Akhir Min Allayl';
    } else if (this == Z.Fajr_Tomorrow) {
      return 'i.Fajr tomorrow';
    }

    return 'a.$transliteration';
  }

  QUEST getFirstQuest() {
    switch (this) {
      case (Z.Fajr):
        return QUEST.FAJR_MUAKB;
      case (Z.Shuruq):
        return QUEST.KARAHAT_SUNRISE;
      case (Z.Ishraq):
        return QUEST.DUHA_ISHRAQ;
      case (Z.Duha):
        return QUEST.DUHA_DUHA;
      case (Z.Istiwa):
        return QUEST.KARAHAT_ISTIWA;
      case (Z.Dhuhr):
        return QUEST.DHUHR_MUAKB;
      case (Z.Asr):
        return QUEST.ASR_NAFLB;
      case (Z.Ghurub):
        return QUEST.KARAHAT_SUNSET;
      case (Z.Maghrib):
        return QUEST.MAGHRIB_FARD;
      case (Z.Isha):
        return QUEST.ISHA_NAFLB;
      case (Z.Middle_of_Night):
        return QUEST.LAYL_QIYAM;
      case (Z.Last_3rd_of_Night):
        return QUEST.LAYL_SLEEP; // other logic protects this at init
      case (Z.Fajr_Tomorrow): // still needed so we can set full misses
        return QUEST.LAYL_SLEEP; // TODO works?
      default:
        return l.E('Z:getFirstQuest: Invalid Z "$this" given');
    }
  }

  bool isAboveHorizon() {
    switch (this) {
      case (Z.Shuruq):
      case (Z.Ishraq):
      case (Z.Duha):
      case (Z.Istiwa):
      case (Z.Dhuhr):
      case (Z.Asr):
      case (Z.Ghurub):
        return true;
      case (Z.Maghrib):
      case (Z.Isha):
      case (Z.Middle_of_Night):
      case (Z.Last_3rd_of_Night):
      case (Z.Fajr):
      case (Z.Fajr_Tomorrow):
        return false;
      default:
        return l.E('Z:isSunAboveHorizon: Invalid Z "$this" given');
    }
  }
}

/// Zaman Row, used for Salah Row operations.
final List<Z> zRows = [
  Z.Fajr,
  Z.Duha,
  Z.Dhuhr,
  Z.Asr,
  Z.Maghrib,
  Z.Isha,
  Z.Middle_of_Night,
  Z.Last_3rd_of_Night,
];
