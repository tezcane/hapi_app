import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

class ActiveQuestsController extends GetxController {
  static ActiveQuestsController get to => Get.find(); // A.K.A. cQstA

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

  bool _showActiveSalah = true; // true shows salah actions, false hides them
  bool get showActiveSalah => _showActiveSalah;

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
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock = value;
    s.wr('show12HourClock', value);
    update();
  }

  void toggleShowActiveSalah() {
    _showActiveSalah = !_showActiveSalah;
    s.wr('showActiveSalah', _showActiveSalah);
    update();
  }
}
