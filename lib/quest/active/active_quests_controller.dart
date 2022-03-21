import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/time_of_day.dart';
import 'package:hapi/quest/active/athan/tod.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:intl/intl.dart';

enum DAY_OF_WEEK {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}

DAY_OF_WEEK getDayOfWeek(DateTime dateTime) {
  // TODO test in other locales also // TODO test, used to be DateTime now()
  String day = DateFormat('EEEE').format(dateTime);
  for (var dayOfWeek in DAY_OF_WEEK.values) {
    if (day == dayOfWeek.name) {
      return dayOfWeek;
    }
  }

  DAY_OF_WEEK defaultDayOfWeek = DAY_OF_WEEK.Monday;
  l.e('getDayOfWeek: Invalid day of week, defaulting to; method found: $defaultDayOfWeek');
  return defaultDayOfWeek;
}

class ActiveQuestsController extends GetxController {
  static ActiveQuestsController get to => Get.find(); // A.K.A. cQstA

  DAY_OF_WEEK _dayOfWeek = getDayOfWeek(DUMMY_TIME);
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek;
  updateDayOfWeek() async =>
      _dayOfWeek = getDayOfWeek(await TimeController.to.now());

  bool isFriday() => _dayOfWeek == DAY_OF_WEEK.Friday;

  // Needed for Salah Calculations:
  int _salahCalcMethod = CalcMethod.America____ISNA___.index;
  int get salahCalcMethod => _salahCalcMethod;
  bool _salahAsrSafe = true; // true hanafi, false other
  bool get salahAsrSafe => _salahAsrSafe;
  bool _salahKerahatSafe = true; // true hanafi, false other
  bool get salahKerahatSafe => _salahKerahatSafe;

  bool _showJummahOnFriday = true; // if friday=true, shows jummah
  bool get showJummahOnFriday => _showJummahOnFriday;

  bool _show3rdOfNight = true; // true=last 1/3, false=middle night
  bool get showLast3rdOfNight => _show3rdOfNight;

  bool _show12HourClock = true; // false = 24h clock/military time
  bool get show12HourClock => _show12HourClock;

  bool _showActiveSalah = true; // true shows TOD actions, false hides them
  bool get showActiveSalah => _showActiveSalah;

  TimeOfDay? _tod;
  set tod(TimeOfDay? tod) {
    _tod = tod;
    update();
  }

  TimeOfDay? get tod => _tod;

  @override
  void onInit() {
    super.onInit();

    _salahCalcMethod =
        s.rd('salahCalcMethod') ?? CalcMethod.America____ISNA___.index;
    _salahAsrSafe = s.rd('salahAsrSafe') ?? true;
    _salahKerahatSafe = s.rd('salahKerahatSafe') ?? true;

    _showJummahOnFriday = s.rd('showJummahOnFriday') ?? true;
    _show3rdOfNight = s.rd('show3rdOfNight') ?? true;
    _show12HourClock = s.rd('show12HourClock') ?? true;

    _showActiveSalah = s.rd('showActiveSalah') ?? true;
  }

  set salahCalcMethod(int value) {
    _salahCalcMethod = value;
    s.wr('salahCalcMethod', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set salahAsrSafe(bool value) {
    _salahAsrSafe = value;
    s.wr('salahAsrSafe', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set salahKerahatSafe(bool value) {
    _salahKerahatSafe = value;
    s.wr('salahKerahatSafe', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set showJummahOnFriday(bool value) {
    _showJummahOnFriday = value;
    s.wr('showJummahOnFriday', value);
    update();
  }

  set showLast3rdOfNight(bool value) {
    _show3rdOfNight = value;
    s.wr('show3rdOfNight', value);
    //ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock = value;
    s.wr('show12HourClock', value);
    //ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  void toggleShowActiveSalah() {
    _showActiveSalah = !_showActiveSalah;
    s.wr('showActiveSalah', _showActiveSalah);
    update();
  }

  /// Iterate through given TODs for a given salah row and see if it matches the
  /// current TOD.
  bool isSalahRowActive(TOD tod) {
    List<TOD> tods;

    switch (tod) {
      case TOD.Fajr:
        tods = [TOD.Fajr, TOD.Fajr_Tomorrow];
        break;
      case TOD.Duha:
        tods = [TOD.Kerahat_Sunrise, TOD.Ishraq, TOD.Duha, TOD.Kerahat_Zawal];
        break;
      case TOD.Dhuhr:
        tods = [TOD.Dhuhr];
        break;
      case TOD.Asr:
        tods = [TOD.Asr, TOD.Kerahat_Sun_Setting];
        break;
      case TOD.Maghrib:
        tods = [TOD.Maghrib];
        break;
      case TOD.Isha:
        tods = [TOD.Isha];
        break;
      case TOD.Night__3:
        tods = [TOD.Isha, TOD.Night__2, TOD.Night__3];
        break;
      default:
        var e = 'Invalid TOD ($tod) given when in isSalahRowActive called';
        l.e(e);
        throw e;
    }

    TOD currTOD = ZamanController.to.currTOD;
    for (TOD tod in tods) {
      if (tod == currTOD) return true; // time of day is active
    }

    return false; // this time of day is not active
  }

  // void toggleSalahAlarm(TOD tod) {
  //   // TODO asdf
  // }
  //
  // void toggleFlipCard(FlipCardController flipCardController) {
  //   flipCardController.toggleCard();
  //   update();
  // }
}
