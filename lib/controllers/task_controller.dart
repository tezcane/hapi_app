import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hapi/models/task_model.dart';
import 'package:hapi/services/database.dart';

import 'auth_controller.dart';

class TaskController extends GetxController {
  Rx<List<TaskModel>> taskList = Rx<List<TaskModel>>([]);
  Rxn<User> firebaseUser = Rxn<User>();

  List<TaskModel> get tasks => taskList.value;

  @override
  void onInit() {
    String uid = Get.find<AuthController>().firebaseUser.value!.uid;
    taskList.bindStream(Database().taskStream(uid)); //stream from firebase

    super.onInit();
  }
}
