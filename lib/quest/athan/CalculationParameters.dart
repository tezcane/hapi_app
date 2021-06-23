import 'package:hapi/quest/athan/CalculationMethod.dart';
import 'package:hapi/quest/athan/HighLatitudeRule.dart';
import 'package:hapi/quest/athan/Madhab.dart';

class CalculationParameters {
  final SalahMethod salahMethod;
  final double fajrAngle;
  final double ishaAngle;
  final Map methodAdjustments; // Different calculation methods adjust times.
  Madhab madhab;
  int kerahatSunRisingMins;
  int kerahatSunZenithMins;
  int kerahatSunSettingMins;
  int ishaInterval;
  HighLatitudeRule highLatitudeRule;
  double? maghribAngle;

  // TODO user to customize +/- minutes to salah times
  Map adjustments = {
    'fajr': 0,
    'sunrise': 0,
    'dhuhr': 0,
    'asr': 0,
    'maghrib': 0,
    'isha': 0
  };

  CalculationParameters(
    this.salahMethod,
    this.fajrAngle,
    this.ishaAngle,
    this.methodAdjustments, {
    this.madhab = Madhab.Hanafi,
    this.kerahatSunRisingMins = 40,
    this.kerahatSunZenithMins = 30,
    this.kerahatSunSettingMins = 40,
    this.ishaInterval = 0,
    this.highLatitudeRule = HighLatitudeRule.MiddleOfTheNight,
    this.maghribAngle, // expected to be null when not in use
  });

  nightPortions() {
    switch (this.highLatitudeRule) {
      case HighLatitudeRule.MiddleOfTheNight:
        return {'fajr': 1 / 2, 'isha': 1 / 2};
      case HighLatitudeRule.SeventhOfTheNight:
        return {'fajr': 1 / 7, 'isha': 1 / 7};
      case HighLatitudeRule.TwilightAngle:
        return {'fajr': this.fajrAngle / 60, 'isha': this.ishaAngle / 60};
      default:
        throw ('Invalid high latitude rule found when attempting to compute night portions: ${this.highLatitudeRule}');
    }
  }
}
