import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';

enum CalcMethod {
  America____ISNA___,
  Dubai,
  Egypt____GAS___, // Egyptian General Authority of Survey
  Karachi____UIS___, // University of Islamic Sciences, Karachi
  Kuwait,
  Moonsight_Committee,
  Morocco____MHIA___, // Moroccan ministry of Habous and Islamic Affairs
  Muslim_World_League,
  Qatar,
  Singapore,
  Tehran____IGUT___, // Institute of Geophysics, University of Tehran
  Turkey____Diyanet___,
  Umm_Al__Qura____UM___, // Umm al-Qura University, Makkah
  Custom, // When user changes from the default
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

  CalcMethodParams get params {
    final Map<SalahAdjust, int> ma = {
      SalahAdjust.fajr: 0,
      SalahAdjust.sunrise: 0,
      SalahAdjust.dhuhr: 0,
      SalahAdjust.asr: 0,
      SalahAdjust.maghrib: 0,
      SalahAdjust.isha: 0,
    };

    switch (this) {
      case (CalcMethod.Singapore):
        ma[SalahAdjust.dhuhr] = 1;
        return CalcMethodParams(this, 20.0, 18.0, 0, 0.0, ma);
      case (CalcMethod.Egypt____GAS___):
        ma[SalahAdjust.dhuhr] = 1;
        return CalcMethodParams(this, 19.5, 17.5, 0, 0.0, ma);
      case (CalcMethod.Morocco____MHIA___):
        ma[SalahAdjust.sunrise] = -3;
        ma[SalahAdjust.dhuhr] = 5;
        ma[SalahAdjust.maghrib] = 5;
        return CalcMethodParams(this, 19.0, 17.0, 0, 0.0, ma);
      case (CalcMethod.Dubai):
        ma[SalahAdjust.sunrise] = -3;
        ma[SalahAdjust.dhuhr] = 3;
        ma[SalahAdjust.asr] = 3;
        ma[SalahAdjust.maghrib] = 3;
        return CalcMethodParams(this, 18.2, 18.2, 0, 0.0, ma);
      case (CalcMethod.Moonsight_Committee):
        ma[SalahAdjust.dhuhr] = 5;
        ma[SalahAdjust.maghrib] = 3;
        return CalcMethodParams(this, 18.0, 18.0, 0, 0.0, ma);
      case (CalcMethod.Karachi____UIS___):
        ma[SalahAdjust.dhuhr] = 1;
        return CalcMethodParams(this, 18.0, 18.0, 0, 0.0, ma);
      case (CalcMethod.Kuwait):
        return CalcMethodParams(this, 18.0, 17.5, 0, 0.0, ma);
      case (CalcMethod.Turkey____Diyanet___):
        ma[SalahAdjust.sunrise] = -7;
        ma[SalahAdjust.dhuhr] = 5;
        ma[SalahAdjust.asr] = 4;
        ma[SalahAdjust.maghrib] = 7;
        return CalcMethodParams(this, 18.0, 17.0, 0, 0.0, ma);
      case (CalcMethod.Muslim_World_League):
        ma[SalahAdjust.dhuhr] = 1;
        return CalcMethodParams(this, 18.0, 17.0, 0, 0.0, ma);
      case (CalcMethod.Umm_Al__Qura____UM___):
        return CalcMethodParams(this, 18.5, 0.0, 90, 0.0, ma);
      case (CalcMethod.Qatar):
        return CalcMethodParams(this, 18.0, 0.0, 90, 0.0, ma);
      case (CalcMethod.Tehran____IGUT___):
        return CalcMethodParams(this, 17.7, 14.0, 0, 4.5, ma);
      case (CalcMethod.America____ISNA___):
        ma[SalahAdjust.dhuhr] = 1;
        return CalcMethodParams(this, 15.0, 15.0, 0, 0.0, ma);
      case (CalcMethod.Custom):
      default:
        CalcMethod calcMethod = CalcMethod
            .values[s.rd('calcMethod_idx') ?? CalcMethod.Custom.index];
        double fajrAngle = s.rd('calcMethod_fajrAngle') ?? 18.0;
        double ishaAngle = s.rd('calcMethod_ishaAngle') ?? 18.0;
        int ishaInterval = s.rd('calcMethod_ishaInterval') ?? 0;
        double maghribAngle = s.rd('calcMethod_maghribAngle') ?? 0.0;

        final Map<SalahAdjust, int> ma = {
          SalahAdjust.fajr: s.rd('calcMethod_maFajr') ?? 0,
          SalahAdjust.sunrise: s.rd('calcMethod_maSunrise') ?? 0,
          SalahAdjust.dhuhr: s.rd('calcMethod_maDhuhr') ?? 0,
          SalahAdjust.asr: s.rd('calcMethod_maAsr') ?? 0,
          SalahAdjust.maghrib: s.rd('calcMethod_maMaghrib') ?? 0,
          SalahAdjust.isha: s.rd('calcMethod_maIsha') ?? 0,
        };
        return CalcMethodParams(
          calcMethod,
          fajrAngle,
          ishaAngle,
          ishaInterval,
          maghribAngle,
          ma,
        );
    }
  }

  /// Use to check if a two calc methods are equal
  bool equals(CalcMethod calcMethod) {
    if (this == calcMethod && calcMethod != CalcMethod.Custom) {
      return true; // if enum matches, no need to check
    }

    var params1 = params; // regenerate these once
    var params2 = calcMethod.params;

    Map<SalahAdjust, int> ma1 = params1.methodAdjustments; // to fit on line
    Map<SalahAdjust, int> ma2 = params2.methodAdjustments;

    return ma1[SalahAdjust.fajr] == ma2[SalahAdjust.fajr] &&
        ma1[SalahAdjust.sunrise] == ma2[SalahAdjust.sunrise] &&
        ma1[SalahAdjust.dhuhr] == ma2[SalahAdjust.dhuhr] &&
        ma1[SalahAdjust.asr] == ma2[SalahAdjust.asr] &&
        ma1[SalahAdjust.maghrib] == ma2[SalahAdjust.maghrib] &&
        ma1[SalahAdjust.isha] == ma2[SalahAdjust.isha] &&
        params1.fajrAngle == params2.fajrAngle &&
        params1.ishaAngle == params2.ishaAngle &&
        params1.ishaIntervalMins == params2.ishaIntervalMins &&
        params1.maghribAngle == params2.maghribAngle;
  }

  /// Returns itself if no match, otherwise first found CalcMethod it matches.
  /// Note: Should be able to test against multiple Custom values.
  CalcMethod checkIfCustomEnumHasMatch() {
    if (this != CalcMethod.Custom) {
      return this; // a non-custom CalcMethod does not need to call this.
    }

    CalcMethod customCalcMethod = this;
    for (CalcMethod calcMethod in CalcMethod.values) {
      if (customCalcMethod.equals(calcMethod)) {
        return customCalcMethod;
      }
    }

    return this;
  }
}

/// CalcMethod helper used to assign each CalcMethod it's custom variables. This
/// class holds all Salah/Z calculation variables that originate from
/// differences in different CalculationMethods (e.g. ISNA vs Diyanet).
class CalcMethodParams {
  CalcMethodParams(
    this.calcMethod,
    this.fajrAngle,
    this.ishaAngle,
    this.ishaIntervalMins,
    this.maghribAngle,
    this.methodAdjustments,
  ) {
    if (calcMethod == CalcMethod.Custom) {
      s.wr('calcMethod_idx', CalcMethod.Custom.index);
      s.wr('calcMethod_fajrAngle', fajrAngle);
      s.wr('calcMethod_ishaAngle', ishaAngle);
      s.wr('calcMethod_ishaInterval', ishaIntervalMins);
      s.wr('calcMethod_maghribAngle', maghribAngle);

      s.wr('calcMethod_maFajr', methodAdjustments[SalahAdjust.fajr]);
      s.wr('calcMethod_maSunrise', methodAdjustments[SalahAdjust.sunrise]);
      s.wr('calcMethod_maDhuhr', methodAdjustments[SalahAdjust.dhuhr]);
      s.wr('calcMethod_maAsr', methodAdjustments[SalahAdjust.asr]);
      s.wr('calcMethod_maMaghrib', methodAdjustments[SalahAdjust.maghrib]);
      s.wr('calcMethod_maIsha', methodAdjustments[SalahAdjust.isha]);
    }
  }

  /// Salah Calculation Method, references itself here so origin is known for
  /// quick comparisons, niceName printing needs, etc.
  final CalcMethod calcMethod;

  /// Must have all these SalahAdjust values:
  ///     'fajr': 0
  ///     'sunrise': 0
  ///     'dhuhr': 0
  ///     'asr': 0
  ///     'maghrib': 0
  ///     'isha': 0
  final Map<SalahAdjust, int> methodAdjustments;

  /// Angle of sun below horizon marking start of fajr
  final double fajrAngle;

  /// Angle of sun below horizon marking start of isha, if set should not have
  /// ishaIntervalMins and vice versa.
  final double ishaAngle;

  /// Set to >0 to use a fixed isha start time (Umm Al-Qura and Qatar only) -
  /// This does not use solar calculations for start of isha.
  /// NOTE: <= 0 disables this.
  final int ishaIntervalMins;

  /// Set to >0 to use maghrib angle (Tehran only), otherwise disabled.
  /// NOTE: <= 0 disables this.
  final double maghribAngle;
}
