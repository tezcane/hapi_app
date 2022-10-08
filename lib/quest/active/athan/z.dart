import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quest/active/active_quests_ajr_c.dart';
import 'package:hapi/quest/active/active_quests_c.dart';

/// Z = Zaman/Time Of Day, enum that goes with each important islamic day point.
/// Used with Athan class to match up those calculated times to this enum.
enum Z {
  Fajr, // usually, when sun is 18 degrees below horizon before sunrise
  Shuruq, // Sunrise Karahat 1 - as soon as sun peaks over horizon
  Ishraq, // When sun rises 5 degrees over horizon (spear length)
  Dhuha, // Time after Ishraq to before Istiwa
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
  /// Returns a tk which can then be translated by calling Get's ".tr" on it.
  String get tk {
    String transliteration = name;
    if (this == Z.Dhuhr) {
      if (TimeC.to.isFriday() && ActiveQuestsC.to.showJumahOnFriday) {
        return 'a.Jumah';
      } // else returns a.Dhuhr
    } else if (this == Z.Middle_of_Night) {
      if (ActiveQuestsC.to.showLayl2) {
        return a('a.Layl') + '/' + cni(2); // UGLY but works, returns a tv
      } else {
        return 'a.Muntasaf Allayl';
      }
    } else if (this == Z.Last_3rd_of_Night) {
      if (ActiveQuestsC.to.showLayl3) {
        return a('a.Layl') + '/' + cni(3); // UGLY but works, returns a tv
      } else {
        return 'a.Althuluth Al\'Akhir Min Allayl';
      }
    } else if (this == Z.Fajr_Tomorrow) {
      return 'a.{0} Tomorrow'; // NOTE: caller must insert Fajr for this! Sorry.
    }

    return 'a.$transliteration';
  }

  /// Used to set misses at new Z time init
  QUEST? firstQuestToNotSetMiss() {
    switch (this) {
      case Z.Fajr:
      case Z.Dhuhr:
      case Z.Asr:
      case Z.Maghrib:
      case Z.Isha:
      case Z.Middle_of_Night:
        return getZRowQuests().first;
      case Z.Shuruq:
      case Z.Ishraq:
        return QUEST.KARAHAT_SUNRISE;
      case Z.Dhuha:
        return QUEST.DHUHA_DHUHA;
      case Z.Istiwa:
        return QUEST.KARAHAT_ISTIWA;
      case Z.Ghurub:
        return QUEST.ASR_FARD; // only disallow ASR salah's, adhkar/thikr/dua ok
      case Z.Last_3rd_of_Night:
        return QUEST.LAYL_QIYAM; // isha must be prayed before Middle of Night
      case Z.Fajr_Tomorrow: // needed to set full misses at end of day detect
        return null; // sets Witr miss last, if needed
    }
  }

  bool isAboveHorizon() {
    switch (this) {
      case Z.Shuruq:
      case Z.Ishraq:
      case Z.Dhuha:
      case Z.Istiwa:
      case Z.Dhuhr:
      case Z.Asr:
      case Z.Ghurub:
        return true;
      case Z.Maghrib:
      case Z.Isha:
      case Z.Middle_of_Night:
      case Z.Last_3rd_of_Night:
      case Z.Fajr:
      case Z.Fajr_Tomorrow:
        return false;
    }
  }

  List<QUEST> getZRowQuests() {
    switch (this) {
      case Z.Fajr:
        return [
          QUEST.FAJR_MUAKB,
          QUEST.FAJR_FARD,
          QUEST.MORNING_ADHKAR,
          QUEST.FAJR_THIKR,
          QUEST.FAJR_DUA,
        ];
      case Z.Dhuha:
        return [
          QUEST.KARAHAT_SUNRISE,
          QUEST.DHUHA_ISHRAQ,
          QUEST.DHUHA_DHUHA,
          QUEST.KARAHAT_ISTIWA,
        ];
      case Z.Dhuhr:
        return [
          QUEST.DHUHR_MUAKB,
          QUEST.DHUHR_FARD,
          QUEST.DHUHR_MUAKA,
          QUEST.DHUHR_NAFLA,
          QUEST.DHUHR_THIKR,
          QUEST.DHUHR_DUA,
        ];
      case Z.Asr:
        return [
          QUEST.ASR_NAFLB,
          QUEST.ASR_FARD,
          QUEST.EVENING_ADHKAR,
          QUEST.ASR_THIKR,
          QUEST.ASR_DUA,
        ];
      case Z.Maghrib:
        return [
          QUEST.KARAHAT_SUNSET,
          QUEST.MAGHRIB_FARD,
          QUEST.MAGHRIB_MUAKA,
          QUEST.MAGHRIB_NAFLA,
          QUEST.MAGHRIB_THIKR,
          QUEST.MAGHRIB_DUA,
        ];
      case Z.Isha:
        return [
          QUEST.ISHA_NAFLB,
          QUEST.ISHA_FARD,
          QUEST.ISHA_MUAKA,
          QUEST.ISHA_NAFLA,
          QUEST.ISHA_THIKR,
          QUEST.ISHA_DUA,
        ];
      case Z.Middle_of_Night:
        return [
          QUEST.LAYL_QIYAM,
          QUEST.LAYL_THIKR,
          QUEST.LAYL_DUA,
        ];
      case Z.Last_3rd_of_Night:
        return [
          QUEST.LAYL_SLEEP,
          QUEST.LAYL_TAHAJJUD,
          QUEST.LAYL_WITR,
        ];
      default:
        return l.E('Z:getZRowQuests: Invalid Z "$this" given');
    }
  }
}

/// Zaman Row, used for Salah Row operations.
final List<Z> zRows = [
  Z.Fajr,
  Z.Dhuha,
  Z.Dhuhr,
  Z.Asr,
  Z.Maghrib,
  Z.Isha,
  Z.Middle_of_Night,
  Z.Last_3rd_of_Night,
];
