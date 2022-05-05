import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';
import 'package:hapi/services/db.dart';

class DailyQuestsController extends GetxHapi {
  static DailyQuestsController get to => Get.find();

  /// _doList is an observable object so we can do streams:
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
      l.w('DailyQuestsController.initDoList: not ready, try again after sleeping $sleepBackoffSecs Secs...');
      await Future.delayed(Duration(seconds: sleepBackoffSecs));
      if (sleepBackoffSecs < 4) {
        sleepBackoffSecs++;
      }
    }

    _doList.bindStream(Db.doListStream()); //stream from firebase
  }
}
