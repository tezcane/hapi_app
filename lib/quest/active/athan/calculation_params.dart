import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';

/// Holds all low level parameters needed to calculate salah and Zaman times. It
/// is passed into the Athan class which then uses these fields to calculate
/// the different Z times for the given time and location inputs.
class CalculationParams {
  CalculationParams(
    this.method,
    this.karahatSunRisingSecs,
    this.karahatSunIstiwaSecs,
    this.karahatSunSettingSecs,
    this.highLatitudeRule,
  );

  final CalcMethodParams method;
  final int karahatSunRisingSecs;
  // ensure karahatSunIstiwaSecs always end in an even number (we divide by 2)
  final int karahatSunIstiwaSecs;
  final int karahatSunSettingSecs;
  final HighLatitudeRule highLatitudeRule;

  Map<Salah, double> nightPortions() {
    switch (highLatitudeRule) {
      case HighLatitudeRule.MiddleOfTheNight:
        return {
          Salah.fajr: 1 / 2,
          Salah.isha: 1 / 2,
        };
      case HighLatitudeRule.SeventhOfTheNight:
        return {
          Salah.fajr: 1 / 7,
          Salah.isha: 1 / 7,
        };
      case HighLatitudeRule.TwilightAngle:
        return {
          Salah.fajr: method.fajrAngle / 60, // default 0:, 0/60 = 1
          Salah.isha: method.ishaAngle / 60, // default 0:, 0/60 = 1
        };
      default:
        l.e('Invalid high latitude rule found: $highLatitudeRule, defaulting to ${HighLatitudeRule.MiddleOfTheNight.name}');
        return {
          Salah.fajr: 1 / 2,
          Salah.isha: 1 / 2,
        };
    }
  }
}

/// Used as key in salah adjust secs, night fraction calculations, etc.
enum Salah {
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
