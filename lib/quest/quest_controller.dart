import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/quest/quest_model.dart';
import 'package:hapi/services/database.dart';

final QuestController cQust = Get.find();

class QuestController extends GetxController {
  Rx<List<QuestModel>> questList = Rx<List<QuestModel>>([]);
  Rxn<User> firebaseUser = Rxn<User>();

  List<QuestModel> get quests => questList.value;

  RxBool _showSunnahMuak = true.obs;
  RxBool _showSunnahNafl = false.obs;

  @override
  void onInit() {
    _showSunnahMuak.value = s.read('showSunnahMuak') ?? true;
    _showSunnahNafl.value = s.read('showSunnahNafl') ?? false;

    // TODO this looks unreliable:
    String uid = Get.find<AuthController>().firebaseUser.value!.uid;
    print('QuestController.onInit: binding to db with uid=$uid');
    questList.bindStream(Database().questStream(uid)); //stream from firebase

    super.onInit();
  }

  bool get showSunnahMuak => _showSunnahMuak.value;
  bool get showSunnahNafl => _showSunnahNafl.value;

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
}
