import 'package:flip_card/flip_card_controller.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
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

  bool _showSunnahMuak = true;
  bool _showSunnahNafl = true;
  bool _showSunnahDuha = false;
  bool _showSunnahLayl = false;
  bool _showSunnahKeys = true;
  int _salahCalcMethod = 0; // 0 = America (ISNA)
  bool _showJummahOnFriday = true; // if friday=true, shows jummah
  bool _show3rdOfNight = true; // true=last 1/3, false=middle night
  bool _show12HourClock = true; // false = 24h clock/military time
  bool _salahAsrSafe = true; // true hanafi, false other
  bool _salahKerahatSafe = true; // true hanafi, false other

  TimeOfDay? _tod;
  set tod(TimeOfDay? tod) {
    _tod = tod;
    update();
  }

  TimeOfDay? get tod => _tod;

  @override
  void onInit() {
    super.onInit();

    _showSunnahMuak = s.rd('showSunnahMuak') ?? true;
    _showSunnahNafl = s.rd('showSunnahNafl') ?? true;
    _showSunnahDuha = s.rd('showSunnahDuha') ?? false;
    _showSunnahLayl = s.rd('showSunnahLayl') ?? false;
    _showSunnahKeys = s.rd('showSunnahKeys') ?? true;
    _showJummahOnFriday = s.rd('showJummahOnFriday') ?? true;
    _show3rdOfNight = s.rd('show3rdOfNight') ?? true;
    _show12HourClock = s.rd('show12HourClock') ?? true;
    _salahAsrSafe = s.rd('salahAsrSafe') ?? true;
    _salahKerahatSafe = s.rd('salahKerahatSafe') ?? true;
    _salahCalcMethod = s.rd('salahCalcMethod') ?? 0;
  }

  bool get showSunnahMuak => _showSunnahMuak;
  bool get showSunnahNafl => _showSunnahNafl;
  bool get showSunnahDuha => _showSunnahDuha;
  bool get showSunnahLayl => _showSunnahLayl;
  bool get showSunnahKeys => _showSunnahKeys;
  bool get showJummahOnFriday => _showJummahOnFriday;
  bool get showLast3rdOfNight => _show3rdOfNight;
  bool get show12HourClock => _show12HourClock;
  bool get salahAsrSafe => _salahAsrSafe;
  bool get salahKerahatSafe => _salahKerahatSafe;
  int get salahCalcMethod => _salahCalcMethod;

  void toggleShowSunnahMuak() {
    _showSunnahMuak = !_showSunnahMuak;
    s.wr('showSunnahMuak', _showSunnahMuak);
    update();
  }

  void toggleShowSunnahNafl() {
    _showSunnahNafl = !_showSunnahNafl;
    s.wr('showSunnahNafl', _showSunnahNafl);
    update();
  }

  void toggleShowSunnahDuha() {
    _showSunnahDuha = !_showSunnahDuha;
    s.wr('showSunnahDuha', _showSunnahDuha);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  void toggleShowSunnahLayl() {
    _showSunnahLayl = !_showSunnahLayl;
    s.wr('showSunnahLayl', _showSunnahLayl);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set showSunnahKeys(bool value) {
    _showSunnahKeys = value;
    s.wr('showSunnahKeys', value);
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
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock = value;
    s.wr('show12HourClock', value);
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

  set salahCalcMethod(int value) {
    _salahCalcMethod = value;
    s.wr('salahCalcMethod', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  void toggleSalahAlarm(TOD tod) {
    // TODO asdf
  }

  void toggleFlipCard(FlipCardController flipCardController) {
    flipCardController.toggleCard();
    update();
  }
}
