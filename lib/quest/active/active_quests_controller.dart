import 'package:flip_card/flip_card_controller.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main.dart';
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
  print(
      'ERROR: getDayOfWeek: Invalid day of week, defaulting to; method found: $defaultDayOfWeek');
  return defaultDayOfWeek;
}

class ActiveQuestsController extends GetxController {
  static ActiveQuestsController get to => Get.find(); // A.K.A. cQstA

  final Rx<DAY_OF_WEEK> _dayOfWeek = getDayOfWeek(DUMMY_TIME).obs;
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek.value;
  updateDayOfWeek() async =>
      _dayOfWeek.value = getDayOfWeek(await TimeController.to.now());

  bool isFriday() => _dayOfWeek.value == DAY_OF_WEEK.Friday;

  final RxBool _showSunnahMuak = true.obs;
  final RxBool _showSunnahNafl = true.obs;
  final RxBool _showSunnahDuha = false.obs;
  final RxBool _showSunnahLayl = false.obs;
  final RxBool _showSunnahKeys = true.obs;
  final RxInt _salahCalcMethod = 0.obs; // 0 = America (ISNA)
  final RxBool _showJummahOnFriday = true.obs; // if friday=true, shows jummah
  final RxBool _show3rdOfNight = true.obs; // true=last 1/3, false=middle night
  final RxBool _show12HourClock = true.obs; // false = 24h clock/military time
  final RxBool _salahAsrSafe = true.obs; // true hanafi, false other
  final RxBool _salahKerahatSafe = true.obs; // true hanafi, false other

  TimeOfDay? _tod;
  set tod(TimeOfDay? tod) {
    _tod = tod;
    update();
  }

  TimeOfDay? get tod => _tod;

  @override
  void onInit() {
    super.onInit();

    _showSunnahMuak.value = s.read('showSunnahMuak') ?? true;
    _showSunnahNafl.value = s.read('showSunnahNafl') ?? true;
    _showSunnahDuha.value = s.read('showSunnahDuha') ?? false;
    _showSunnahLayl.value = s.read('showSunnahLayl') ?? false;
    _showSunnahKeys.value = s.read('showSunnahKeys') ?? true;
    _showJummahOnFriday.value = s.read('showJummahOnFriday') ?? true;
    _show3rdOfNight.value = s.read('show3rdOfNight') ?? true;
    _show12HourClock.value = s.read('show12HourClock') ?? true;
    _salahAsrSafe.value = s.read('salahAsrSafe') ?? true;
    _salahKerahatSafe.value = s.read('salahKerahatSafe') ?? true;
    _salahCalcMethod.value = s.read('salahCalcMethod') ?? 0;
  }

  bool get showSunnahMuak => _showSunnahMuak.value;
  bool get showSunnahNafl => _showSunnahNafl.value;
  bool get showSunnahDuha => _showSunnahDuha.value;
  bool get showSunnahLayl => _showSunnahLayl.value;
  bool get showSunnahKeys => _showSunnahKeys.value;
  bool get showJummahOnFriday => _showJummahOnFriday.value;
  bool get showLast3rdOfNight => _show3rdOfNight.value;
  bool get show12HourClock => _show12HourClock.value;
  bool get salahAsrSafe => _salahAsrSafe.value;
  bool get salahKerahatSafe => _salahKerahatSafe.value;
  int get salahCalcMethod => _salahCalcMethod.value;

  void toggleShowSunnahMuak() {
    _showSunnahMuak.value = !_showSunnahMuak.value;
    s.write('showSunnahMuak', _showSunnahMuak.value);
    update();
  }

  void toggleShowSunnahNafl() {
    _showSunnahNafl.value = !_showSunnahNafl.value;
    s.write('showSunnahNafl', _showSunnahNafl.value);
    update();
  }

  void toggleShowSunnahDuha() {
    _showSunnahDuha.value = !_showSunnahDuha.value;
    s.write('showSunnahDuha', _showSunnahDuha.value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  void toggleShowSunnahLayl() {
    _showSunnahLayl.value = !_showSunnahLayl.value;
    s.write('showSunnahLayl', _showSunnahLayl.value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set showSunnahKeys(bool value) {
    _showSunnahKeys.value = value;
    s.write('showSunnahKeys', value);
    update();
  }

  set showJummahOnFriday(bool value) {
    _showJummahOnFriday.value = value;
    s.write('showJummahOnFriday', value);
    update();
  }

  set showLast3rdOfNight(bool value) {
    _show3rdOfNight.value = value;
    s.write('show3rdOfNight', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock.value = value;
    s.write('show12HourClock', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set salahAsrSafe(bool value) {
    _salahAsrSafe.value = value;
    s.write('salahAsrSafe', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set salahKerahatSafe(bool value) {
    _salahKerahatSafe.value = value;
    s.write('salahKerahatSafe', value);
    ZamanController.to.forceSalahRecalculation = true;
    update();
  }

  set salahCalcMethod(int value) {
    _salahCalcMethod.value = value;
    s.write('salahCalcMethod', value);
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
