import 'package:get/get.dart';

final AjrController cAjr = Get.find();

class AjrController extends GetxController {
  RxBool _isIshaIbadahComplete = false.obs;
  bool get isIshaIbadahComplete => _isIshaIbadahComplete.value;
  set isIshaIbadahComplete(bool value) {
    _isIshaIbadahComplete.value = value;
    //s.write('showSunnahKeys', value);
    update();
  }

  @override
  void onInit() {
    //TODO //s.read('showSunnahKeys') ?? true;
    _isIshaIbadahComplete.value = false;

    super.onInit();
  }
}
