import 'package:hapi/quest/active/athan/CalculationParameters.dart';

enum SalahMethod {
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

extension EnumUtil on SalahMethod {
  /// Special logic and rules here to rename enum to a nice name:
  ///     ____ -> (
  ///     ___  -> )
  ///     __   -> -
  ///     _    -> ' ' (space)
  String get niceName {
    return name
        .replaceFirst('____', ' (')
        .replaceFirst('___', ')')
        .replaceFirst('__', '-')
        .replaceAll('_', ' ');
  }
}

class CalculationMethod {
  static getMethod(SalahMethod salahMethod) {
    Map methodAdjustments = {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0
    };

    switch (salahMethod) {
      case (SalahMethod.America____ISNA___):
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(salahMethod, 15, 15, methodAdjustments);
        }
      case (SalahMethod.Dubai):
        {
          Map methodAdjustments = {
            'sunrise': -3,
            'dhuhr': 3,
            'asr': 3,
            'maghrib': 3
          };
          return CalculationParameters(
              salahMethod, 18.2, 18.2, methodAdjustments);
        }
      case (SalahMethod.Egypt):
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(
              salahMethod, 19.5, 17.5, methodAdjustments);
        }
      case (SalahMethod.Karachi):
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(salahMethod, 18, 18, methodAdjustments);
        }
      case (SalahMethod.Kuwait):
        {
          return CalculationParameters(
              salahMethod, 18, 17.5, methodAdjustments);
        }
      case (SalahMethod.Moonsight_Committee):
        {
          Map methodAdjustments = {'dhuhr': 5, 'maghrib': 3};
          return CalculationParameters(salahMethod, 18, 18, methodAdjustments);
        }
      case (SalahMethod.Morocco):
        {
          Map methodAdjustments = {'sunrise': -3, 'dhuhr': 5, 'maghrib': 5};
          return CalculationParameters(salahMethod, 19, 17, methodAdjustments);
        }
      case (SalahMethod.Muslim_World_League):
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(salahMethod, 18, 17, methodAdjustments);
        }
      case (SalahMethod.Qatar):
        {
          return CalculationParameters(salahMethod, 18, 0, methodAdjustments,
              ishaInterval: 90);
        }
      case (SalahMethod.Singapore):
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(salahMethod, 20, 18, methodAdjustments);
        }
      case (SalahMethod.Tehran):
        {
          return CalculationParameters(salahMethod, 17.7, 14, methodAdjustments,
              ishaInterval: 0, maghribAngle: 4.5);
        }
      case (SalahMethod.Turkey____Diyanet___):
        {
          Map methodAdjustments = {
            'sunrise': -7,
            'dhuhr': 5,
            'asr': 4,
            'maghrib': 7
          };
          return CalculationParameters(salahMethod, 18, 17, methodAdjustments);
        }
      case (SalahMethod.Umm_Al__Qura):
        {
          return CalculationParameters(salahMethod, 18.5, 0, methodAdjustments,
              ishaInterval: 90);
        }
      // default to America (ISNA)
      default:
        {
          Map methodAdjustments = {'dhuhr': 1};
          return CalculationParameters(
              SalahMethod.America____ISNA___, 15, 15, methodAdjustments);
        }
    }
  }
}
