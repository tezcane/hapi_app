import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

class ActiveQuestsController extends GetxController {
  static ActiveQuestsController get to => Get.find(); // A.K.A. cQstA

  // Needed for Salah Calculations:
  int _salahCalcMethod = CalcMethod.America____ISNA___.index;
  int get salahCalcMethod => _salahCalcMethod;
  bool _salahAsrEarlier = true; // earlier=true, 1 shadow, later=false, 2 shadow
  bool get salahAsrEarlier => _salahAsrEarlier;
  bool _last3rdOfNight = true; // true=last 1/3, false=middle night
  bool get last3rdOfNight => _last3rdOfNight;
  bool _showSecPrecision = false; // false = round athan times to minutes
  bool get showSecPrecision => _showSecPrecision;
  bool _salahKarahatSafe = true; // true slightly safer/longer karahat times
  bool get salahKarahatSafe => _salahKarahatSafe;

  bool _showJummahOnFriday = true; // if friday=true, shows jummah
  bool get showJummahOnFriday => _showJummahOnFriday;

  bool _show12HourClock = true; // false = 24h clock/military time
  bool get show12HourClock => _show12HourClock;

  bool _showActiveSalah = true; // true shows salah actions, false hides them
  bool get showActiveSalah => _showActiveSalah;
  bool _showSalahResults = true; // true shows salah results, false hides them
  bool get showSalahResults => _showSalahResults;

  bool _swiperAutoPlayEnabled = true;
  bool get swiperAutoPlayEnabled => _swiperAutoPlayEnabled;
  int _swiperImageIdx = -1;
  int get swiperImageIdx => _swiperImageIdx;
  int _swiperLastIdx = 0;
  int get swiperLastIdx => _swiperLastIdx;

  @override
  void onInit() {
    super.onInit();

    _salahCalcMethod =
        s.rd('salahCalcMethod') ?? CalcMethod.America____ISNA___.index;
    _salahAsrEarlier = s.rd('salahAsrEarlier') ?? true;
    _last3rdOfNight = s.rd('last3rdOfNight') ?? true;
    _showSecPrecision = s.rd('showSecPrecision') ?? false;
    _salahKarahatSafe = s.rd('salahKarahatSafe') ?? true;

    _showJummahOnFriday = s.rd('showJummahOnFriday') ?? true;
    _show12HourClock = s.rd('show12HourClock') ?? true;

    _showActiveSalah = s.rd('showActiveSalah') ?? true;
    _showSalahResults = s.rd('showSalahResults') ?? false;

    _swiperAutoPlayEnabled = s.rd('swiperAutoPlayEnabled') ?? true;
    _swiperImageIdx = s.rd('swiperImageIdx') ?? -1;
  }

  set salahCalcMethod(int value) {
    _salahCalcMethod = value;
    s.wr('salahCalcMethod', value);
    ZamanController.to.forceSalahRecalculation = true;
    //update(); update needs to be done later after athan recalculated
  }

  set salahAsrEarlier(bool value) {
    _salahAsrEarlier = value;
    s.wr('salahAsrEarlier', value);
    ZamanController.to.forceSalahRecalculation = true;
    //update(); update needs to be done later after athan recalculated
  }

  set last3rdOfNight(bool value) {
    _last3rdOfNight = value;
    s.wr('last3rdOfNight', value);
    ZamanController.to.forceSalahRecalculation = true; // update countdown timer
    //update(); update needs to be done later after athan recalculated
  }

  set showSecPrecision(bool value) {
    _showSecPrecision = value;
    s.wr('showSecPrecision', value);
    ZamanController.to.forceSalahRecalculation = true;
    //update();
  }

  set salahKarahatSafe(bool value) {
    _salahKarahatSafe = value;
    s.wr('salahKarahatSafe', value);
    ZamanController.to.forceSalahRecalculation = true;
    //update(); update needs to be done later after athan recalculated
  }

  set showJummahOnFriday(bool value) {
    _showJummahOnFriday = value;
    s.wr('showJummahOnFriday', value);
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

  void toggleShowSalahResults() {
    _showSalahResults = !_showSalahResults;
    s.wr('showSalahResults', _showSalahResults);
    update();
  }

  void toggleSwiperAutoPlayEnabled(int idx) {
    if (_swiperAutoPlayEnabled) {
      // if auto playing, just disable it and set swiper image idx
      _swiperAutoPlayEnabled = false;
      _swiperImageIdx = idx;
    } else {
      // if autoplay is already off
      if (idx == _swiperImageIdx) {
        // and same image is tapped, then re-enable autoplay
        _swiperAutoPlayEnabled = true;
        _swiperLastIdx = idx; // to resume swipe animation from current image
        _swiperImageIdx = -1;
      } else {
        // and different image is tapped (after swiped), then just pin new image
        _swiperImageIdx = idx;
      }
    }
    s.wr('swiperAutoPlayEnabled', _swiperAutoPlayEnabled);
    s.wr('swiperImageIdx', _swiperImageIdx);
    update();
  }
}
