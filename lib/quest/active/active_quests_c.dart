import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/zaman_c.dart';

class ActiveQuestsC extends GetxHapi {
  static ActiveQuestsC get to => Get.find();

  // Needed for Salah Calculations:
  int _salahCalcMethod =
      s.rd('salahCalcMethod') ?? CalcMethod.America____ISNA___.index;
  int get salahCalcMethod => _salahCalcMethod;
  bool _salahAsrEarlier = s.rd('salahAsrEarlier') ?? true;
  bool get salahAsrEarlier => _salahAsrEarlier;
  bool _showSecPrecision = s.rd('showSecPrecision') ?? false;
  bool get showSecPrecision => _showSecPrecision;

  bool _showJumahOnFriday = s.rd('showJumahOnFriday') ?? true;
  bool get showJumahOnFriday => _showJumahOnFriday;

  bool _show12HourClock = s.rd('show12HourClock') ?? true;
  bool get show12HourClock => _show12HourClock;

  bool _showPinnedSalahRow = s.rd('showPinnedSalahRow') ?? true;
  bool get showPinnedSalahRow => _showPinnedSalahRow;

  bool _showLayl2 = s.rd('showLayl2') ?? true;
  bool get showLayl2 => _showLayl2;
  bool _showLayl3 = s.rd('showLayl3') ?? true;
  bool get showLayl3 => _showLayl3;

  bool _swiperAutoPlayEnabled = s.rd('swiperAutoPlayEnabled') ?? true;
  bool get swiperAutoPlayEnabled => _swiperAutoPlayEnabled;
  int _swiperImageIdx = s.rd('swiperImageIdx') ?? -1;
  int get swiperImageIdx => _swiperImageIdx;
  int _swiperLastIdx = 0;
  int get swiperLastIdx => _swiperLastIdx;

  set salahCalcMethod(int value) {
    _salahCalcMethod = value;
    s.wr('salahCalcMethod', value);
    ZamanC.to.forceSalahRecalculation();
    //update(); update needs to be done later after athan recalculated
  }

  set salahAsrEarlier(bool value) {
    _salahAsrEarlier = value;
    s.wr('salahAsrEarlier', value);
    ZamanC.to.forceSalahRecalculation();
    //update(); update needs to be done later after athan recalculated
  }

  set showSecPrecision(bool value) {
    _showSecPrecision = value;
    s.wr('showSecPrecision', value);
    ZamanC.to.forceSalahRecalculation();
    //update();
  }

  set showJumahOnFriday(bool value) {
    _showJumahOnFriday = value;
    s.wr('showJumahOnFriday', value);
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock = value;
    s.wr('show12HourClock', value);
    update();
  }

  set showPinnedSalahRow(bool value) {
    _showPinnedSalahRow = value;
    s.wr('showPinnedSalahRow', _showPinnedSalahRow);
    update();
  }

  set showLayl2(bool value) {
    _showLayl2 = value;
    s.wr('showLayl2', _showLayl2);
    update();
  }

  set showLayl3(bool value) {
    _showLayl3 = value;
    s.wr('showLayl3', _showLayl3);
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
