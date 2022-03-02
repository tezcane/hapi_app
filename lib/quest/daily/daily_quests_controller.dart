import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';
import 'package:hapi/services/database.dart';

class DailyQuestsController extends GetxController {
  static DailyQuestsController get to => Get.find();

  final Rx<List<DoListModel>> _doList = Rx<List<DoListModel>>([]);
  List<DoListModel> get doList => _doList.value;

  //final Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    _initDoList();
  }

  // TODO test this:
  void _initDoList() async {
    int sleepBackoffSecs = 1;

    // No internet needed to init, but we put a back off just in case:
    while (AuthController.to.firebaseUser.value == null) {
      print(
          'DailyQuestsController.initDoList: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) {
        sleepBackoffSecs++;
      }
    }

    // TODO asdf fdsa move this to TODO logic controller? this looks unreliable:
    String uid = AuthController.to.firebaseUser.value!.uid;
    print('DailyQuestsController.initDoList: binding to db with uid=$uid');
    _doList.bindStream(Database().doListStream(uid)); //stream from firebase
  }
}
