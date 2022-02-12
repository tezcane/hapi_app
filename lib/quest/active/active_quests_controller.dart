import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/quest/active/athan/TOD.dart';
import 'package:hapi/quest/active/athan/TimeOfDay.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/quest/quest_model.dart';
import 'package:hapi/services/database.dart';
import 'package:intl/intl.dart';

// Controller Quest Active:
final ActiveQuestsController cQstA = Get.find();

enum DAY_OF_WEEK {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}

DAY_OF_WEEK getDayOfWeek() {
  // TODO test in other locales
  String day = DateFormat('EEEE').format(DateTime.now());
  for (var dayOfWeek in DAY_OF_WEEK.values) {
    if (day == dayOfWeek.toString().split('.').last) {
      return dayOfWeek;
    }
  }
  return DAY_OF_WEEK.Monday;
}

class ActiveQuestsController extends GetxController {
  Rx<List<QuestModel>> questList = Rx<List<QuestModel>>([]);
  Rxn<User> firebaseUser = Rxn<User>();

  List<QuestModel> get quests => questList.value;

  Rx<DAY_OF_WEEK> _dayOfWeek = getDayOfWeek().obs;
  DAY_OF_WEEK get dayOfWeek => _dayOfWeek.value;
  void updateDayOfWeek() => _dayOfWeek.value = getDayOfWeek();

  bool isFriday() => _dayOfWeek.value == DAY_OF_WEEK.Friday;

  RxBool _showSunnahMuak = true.obs;
  RxBool _showSunnahNafl = true.obs;
  RxBool _showSunnahDuha = false.obs;
  RxBool _showSunnahLayl = false.obs;
  RxBool _showSunnahKeys = true.obs;
  RxBool _showJummahOnFriday = true.obs; // if friday and true, shows jummah
  RxBool _show3rdOfNight = true.obs; // true = last 1/3, false = middle of night
  RxBool _show12HourClock = true.obs; // false = 24 hour clock/military time
  RxInt _salahCalcMethod = 0.obs; // 0 = America (ISNA)
  RxBool _salahAsrSafe = true.obs; // true hanafi, false other
  RxBool _salahKerahatSafe = true.obs; // true hanafi, false other

  TimeOfDay? _tod;
  set tod(TimeOfDay? tod) {
    _tod = tod;
    update();
  }

  TimeOfDay? get tod => _tod;

  @override
  void onInit() {
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

    initQuestList();

    super.onInit();
  }

  // TODO test this:
  void initQuestList() async {
    int sleepBackoffSecs = 1;

    // No internet needed to init, but we put a back off just in case:
    while (Get.find<AuthController>().firebaseUser.value == null) {
      print(
          'ActiveQuestsController.initQuestList: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) {
        sleepBackoffSecs++;
      }
    }

    // TODO asdf fdsa move this to TODO logic controller? this looks unreliable:
    String uid = Get.find<AuthController>().firebaseUser.value!.uid;
    print('ActiveQuestsController.initQuestList: binding to db with uid=$uid');
    questList.bindStream(Database().questStream(uid)); //stream from firebase
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
    update();
  }

  void toggleShowSunnahLayl() {
    _showSunnahLayl.value = !_showSunnahLayl.value;
    s.write('showSunnahLayl', _showSunnahLayl.value);
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
    update();
  }

  set show12HourClock(bool value) {
    _show12HourClock.value = value;
    s.write('show12HourClock', value);
    update();
  }

  set salahAsrSafe(bool value) {
    _salahAsrSafe.value = value;
    s.write('salahAsrSafe', value);
    cZamn.forceSalahRecalculation = true;
    update();
  }

  set salahKerahatSafe(bool value) {
    _salahKerahatSafe.value = value;
    s.write('salahKerahatSafe', value);
    cZamn.forceSalahRecalculation = true;
    update();
  }

  set salahCalcMethod(int value) {
    _salahCalcMethod.value = value;
    s.write('salahCalcMethod', value);
    cZamn.forceSalahRecalculation = true;
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
