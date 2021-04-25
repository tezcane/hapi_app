import 'package:get/get.dart';

class MenuController extends GetxController {
  static MenuController to = Get.find();

  RxBool _open = false.obs;
//RxBool settingsShowing = false.obs;

  RxBool get isOpen => _open;
  void _updateOpen(bool value) async {
    _open.value = value;
    print('updateOpen open $value');
    update();
  }

  void handleOnPressed() {
    print('handleOnPressed = $_open');
    _updateOpen(!_open.value);
  }

// RxBool get isSettingsShowing => settingsShowing;
//
// void setSettingsShowing(bool value) {
//   settingsShowing.value = value;
//   print('settingsShowing = $value');
//   update();
// }

}
