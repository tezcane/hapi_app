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
    final Map<Salah, int> adjustSecs = {
      Salah.fajr: 0,
      Salah.sunrise: 0,
      Salah.dhuhr: 0,
      Salah.asr: 0,
      Salah.maghrib: 0,
      Salah.isha: 0,
    };

    switch (this) {
      case (CalcMethod.Singapore):
        adjustSecs[Salah.dhuhr] = 1 * 60;
        return CalcMethodParams(this, 20.0, 18.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Egypt____GAS___):
        adjustSecs[Salah.dhuhr] = 1 * 60;
        return CalcMethodParams(this, 19.5, 17.5, 0, 0.0, adjustSecs);
      case (CalcMethod.Morocco____MHIA___):
        adjustSecs[Salah.sunrise] = -3 * 60;
        adjustSecs[Salah.dhuhr] = 5 * 60;
        adjustSecs[Salah.maghrib] = 5 * 60;
        return CalcMethodParams(this, 19.0, 17.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Dubai):
        adjustSecs[Salah.sunrise] = -3 * 60;
        adjustSecs[Salah.dhuhr] = 3 * 60;
        adjustSecs[Salah.asr] = 3 * 60;
        adjustSecs[Salah.maghrib] = 3 * 60;
        return CalcMethodParams(this, 18.2, 18.2, 0, 0.0, adjustSecs);
      case (CalcMethod.Moonsight_Committee):
        adjustSecs[Salah.dhuhr] = 5 * 60;
        adjustSecs[Salah.maghrib] = 3 * 60;
        return CalcMethodParams(this, 18.0, 18.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Karachi____UIS___):
        adjustSecs[Salah.dhuhr] = 1 * 60;
        return CalcMethodParams(this, 18.0, 18.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Kuwait):
        return CalcMethodParams(this, 18.0, 17.5, 0, 0.0, adjustSecs);
      case (CalcMethod.Turkey____Diyanet___):
        adjustSecs[Salah.sunrise] = -7 * 60;
        adjustSecs[Salah.dhuhr] = 5 * 60;
        adjustSecs[Salah.asr] = 4 * 60;
        adjustSecs[Salah.maghrib] = 7 * 60;
        return CalcMethodParams(this, 18.0, 17.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Muslim_World_League):
        adjustSecs[Salah.dhuhr] = 1 * 60;
        return CalcMethodParams(this, 18.0, 17.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Umm_Al__Qura____UM___):
        return CalcMethodParams(this, 18.5, 0.0, 90, 0.0, adjustSecs);
      case (CalcMethod.Qatar):
        return CalcMethodParams(this, 18.0, 0.0, 90, 0.0, adjustSecs);
      case (CalcMethod.Tehran____IGUT___):
        return CalcMethodParams(this, 17.7, 14.0, 0, 4.5, adjustSecs);
      case (CalcMethod.America____ISNA___):
        adjustSecs[Salah.dhuhr] = 1 * 60;
        return CalcMethodParams(this, 15.0, 15.0, 0, 0.0, adjustSecs);
      case (CalcMethod.Custom):
      default:
        CalcMethod calcMethod = CalcMethod
            .values[s.rd('calcMethod_idx') ?? CalcMethod.Custom.index];
        double fajrAngle = s.rd('calcMethod_fajrAngle') ?? 18.0;
        double ishaAngle = s.rd('calcMethod_ishaAngle') ?? 18.0;
        int ishaInterval = s.rd('calcMethod_ishaInterval') ?? 0;
        double maghribAngle = s.rd('calcMethod_maghribAngle') ?? 0.0;

        final Map<Salah, int> adjustSecs = {
          Salah.fajr: s.rd('calcMethod_asFajr') ?? 0,
          Salah.sunrise: s.rd('calcMethod_asSunrise') ?? 0,
          Salah.dhuhr: s.rd('calcMethod_asDhuhr') ?? 0,
          Salah.asr: s.rd('calcMethod_asAsr') ?? 0,
          Salah.maghrib: s.rd('calcMethod_asMaghrib') ?? 0,
          Salah.isha: s.rd('calcMethod_asIsha') ?? 0,
        };
        return CalcMethodParams(
          calcMethod,
          fajrAngle,
          ishaAngle,
          ishaInterval,
          maghribAngle,
          adjustSecs,
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

    Map<Salah, int> as1 = params1.adjustSecs; // to fit on line
    Map<Salah, int> as2 = params2.adjustSecs;

    return as1[Salah.fajr] == as2[Salah.fajr] &&
        as1[Salah.sunrise] == as2[Salah.sunrise] &&
        as1[Salah.dhuhr] == as2[Salah.dhuhr] &&
        as1[Salah.asr] == as2[Salah.asr] &&
        as1[Salah.maghrib] == as2[Salah.maghrib] &&
        as1[Salah.isha] == as2[Salah.isha] &&
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
    this.adjustSecs,
  ) {
    if (calcMethod == CalcMethod.Custom) {
      s.wr('calcMethod_idx', CalcMethod.Custom.index);
      s.wr('calcMethod_fajrAngle', fajrAngle);
      s.wr('calcMethod_ishaAngle', ishaAngle);
      s.wr('calcMethod_ishaInterval', ishaIntervalMins);
      s.wr('calcMethod_maghribAngle', maghribAngle);

      s.wr('calcMethod_asFajr', adjustSecs[Salah.fajr]);
      s.wr('calcMethod_asSunrise', adjustSecs[Salah.sunrise]);
      s.wr('calcMethod_asDhuhr', adjustSecs[Salah.dhuhr]);
      s.wr('calcMethod_asAsr', adjustSecs[Salah.asr]);
      s.wr('calcMethod_asMaghrib', adjustSecs[Salah.maghrib]);
      s.wr('calcMethod_asIsha', adjustSecs[Salah.isha]);
    }
  }

  /// Salah Calculation Method, references itself here so origin is known for
  /// quick comparisons, niceName printing needs, etc.
  final CalcMethod calcMethod;

  /// Must have all these SalahAdjust values, +/- seconds to tune a salah time:
  ///     'fajr': 0
  ///     'sunrise': 0
  ///     'dhuhr': 0
  ///     'asr': 0
  ///     'maghrib': 0
  ///     'isha': 0
  final Map<Salah, int> adjustSecs;

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
