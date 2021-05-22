import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/quest/quest_model.dart';
import 'package:hapi/services/database.dart';

class QuestController extends GetxController {
  Rx<List<QuestModel>> questList = Rx<List<QuestModel>>([]);
  Rxn<User> firebaseUser = Rxn<User>();

  List<QuestModel> get quests => questList.value;

  @override
  void onInit() {
    // TODO this looks unreliable:
    String uid = Get.find<AuthController>().firebaseUser.value!.uid;
    print('QuestController.onInit: binding to db with uid=$uid');
    questList.bindStream(Database().questStream(uid)); //stream from firebase

    super.onInit();
  }
}
