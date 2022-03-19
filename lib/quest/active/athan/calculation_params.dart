import 'package:hapi/quest/active/athan/calculation_method.dart';

/// Holds all low level parameters needed to calculate salah and TOD times. It
/// is passed into the TimeOfDay class which then uses these fields to calculate
/// the different TOD times for the given time and location inputs.
class CalculationParams {
  CalculationParams(
    this.method,
    this.madhab,
    this.kerahatSunRisingMins,
    this.kerahatSunZawalMins,
    this.kerahatSunSettingMins,
    this.highLatitudeRule,
    this.adjustments,
  );

  final CalcMethodParams method;
  final Madhab madhab;
  final int kerahatSunRisingMins;
  final int kerahatSunZawalMins;
  final int kerahatSunSettingMins;
  final HighLatitudeRule highLatitudeRule;

  /// Must have all these values:
  ///     'fajr': 0
  ///     'sunrise': 0
  ///     'dhuhr': 0
  ///     'asr': 0
  ///     'maghrib': 0
  ///     'isha': 0
  final Map<SalahAdjust, int> adjustments;

  Map<SalahAdjust, double> nightPortions() {
    switch (highLatitudeRule) {
      case HighLatitudeRule.MiddleOfTheNight:
        return {
          SalahAdjust.fajr: 1 / 2,
          SalahAdjust.isha: 1 / 2,
        };
      case HighLatitudeRule.SeventhOfTheNight:
        return {
          SalahAdjust.fajr: 1 / 7,
          SalahAdjust.isha: 1 / 7,
        };
      case HighLatitudeRule.TwilightAngle:
        return {
          SalahAdjust.fajr: method.fajrAngle / 60, // default 0:, 0/60 = 1
          SalahAdjust.isha: method.ishaAngle / 60, // default 0:, 0/60 = 1
        };
      default:
        throw 'Invalid high latitude rule found when attempting to compute night portions: $highLatitudeRule';
    }
  }
}

enum Madhab {
  Hanafi,
  Hanbali,
  Jafari,
  Maliki,
  Shafi,
}

extension EnumUtil on Madhab {
  int get shadowLength => this == Madhab.Hanafi ? 2 : 1;
}

enum SalahAdjust {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

enum HighLatitudeRule {
  MiddleOfTheNight,
  SeventhOfTheNight,
  TwilightAngle,
}
