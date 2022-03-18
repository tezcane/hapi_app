import 'package:hapi/quest/active/athan/calculation_params.dart';

enum CalcMethod {
  America____ISNA___,
  Dubai,
  Egypt, // Egyptian General Authority of Survey
  Karachi, // University of Islamic Sciences, Karachi
  Kuwait,
  Moonsight_Committee,
  Morocco, // Moroccan ministry of Habous and Islamic Affairs
  Muslim_World_League,
  Qatar,
  Singapore,
  Tehran, // Institute of Geophysics, University of Tehran
  Turkey____Diyanet___,
  Umm_Al__Qura, // Umm al-Qura University, Makkah
}

extension EnumUtil on CalcMethod {
  /// Special logic and rules here to rename enum to a nice name:
  ///     ____ -> (
  ///      ___ -> )
  ///       __ -> -
  ///        _ -> ' ' (space)
  String get niceName {
    return name
        .replaceFirst('____', ' (')
        .replaceFirst('___', ')')
        .replaceFirst('__', '-')
        .replaceAll('_', ' ');
  }

  CalculationMethod get method => CalculationMethod(this);
}

/// CalcMethod helper used to assign each CalcMethod it's custom variables. This
/// class holds all Salah/TOD calculation variables that originate from
/// differences in different CalculationMethods (e.g. ISNA vs Diyanet).
class CalculationMethod {
  CalculationMethod(this.calcMethod) {
    switch (calcMethod) {
      case (CalcMethod.America____ISNA___):
        fajrAngle = 15;
        ishaAngle = 15;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 1;
        break;
      case (CalcMethod.Dubai):
        fajrAngle = 18.2;
        ishaAngle = 18.2;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.sunrise] = -3;
        methodAdjustments[SalahAdjust.dhuhr] = 3;
        methodAdjustments[SalahAdjust.asr] = 3;
        methodAdjustments[SalahAdjust.maghrib] = 3;
        break;
      case (CalcMethod.Egypt):
        fajrAngle = 19.5;
        ishaAngle = 17.5;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 1;
        break;
      case (CalcMethod.Karachi):
        fajrAngle = 18;
        ishaAngle = 18;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 1;
        break;
      case (CalcMethod.Kuwait):
        fajrAngle = 18;
        ishaAngle = 17.5;
        ishaInterval = 0;
        break;
      case (CalcMethod.Moonsight_Committee):
        fajrAngle = 18;
        ishaAngle = 18;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 5;
        methodAdjustments[SalahAdjust.maghrib] = 3;
        break;
      case (CalcMethod.Morocco):
        fajrAngle = 19;
        ishaAngle = 17;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.sunrise] = -3;
        methodAdjustments[SalahAdjust.dhuhr] = 5;
        methodAdjustments[SalahAdjust.maghrib] = 5;
        break;
      case (CalcMethod.Muslim_World_League):
        fajrAngle = 18;
        ishaAngle = 17;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 1;
        break;
      case (CalcMethod.Qatar):
        fajrAngle = 18;
        ishaAngle = 0;
        ishaInterval = 90;
        break;
      case (CalcMethod.Singapore):
        fajrAngle = 20;
        ishaAngle = 18;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.dhuhr] = 1;
        break;
      case (CalcMethod.Tehran):
        fajrAngle = 17.7;
        ishaAngle = 14;
        ishaInterval = 0;
        maghribAngle = 4.5;
        break;
      case (CalcMethod.Turkey____Diyanet___):
        fajrAngle = 18;
        ishaAngle = 17;
        ishaInterval = 0;
        methodAdjustments[SalahAdjust.sunrise] = -7;
        methodAdjustments[SalahAdjust.dhuhr] = 5;
        methodAdjustments[SalahAdjust.asr] = 4;
        methodAdjustments[SalahAdjust.maghrib] = 7;
        break;
      case (CalcMethod.Umm_Al__Qura):
        fajrAngle = 18.5;
        ishaAngle = 0;
        ishaInterval = 90;
        break;
      default:
        throw 'ERROR: CalculationMethod: Invalid calculation method found: $calcMethod';
    }
  }

  /// Salah Calculation Method
  final CalcMethod calcMethod;

  /// Must have all these values:
  ///     'fajr': 0
  ///     'sunrise': 0
  ///     'dhuhr': 0
  ///     'asr': 0
  ///     'maghrib': 0
  ///     'isha': 0
  final Map<SalahAdjust, int> methodAdjustments = {
    SalahAdjust.fajr: 0,
    SalahAdjust.sunrise: 0,
    SalahAdjust.dhuhr: 0,
    SalahAdjust.asr: 0,
    SalahAdjust.maghrib: 0,
    SalahAdjust.isha: 0,
  };

  // Note: make sure to set these 3 fields EXACTLY one time in the constructor:
  late final double fajrAngle;
  late final double ishaAngle;
  late final int ishaInterval;

  /// NOTE: Expected to be null when not in use
  double? maghribAngle;
}
