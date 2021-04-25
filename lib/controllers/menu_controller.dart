import 'package:flutter/src/animation/animation_controller.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  static MenuController to = Get.find();

  RxBool _open = false.obs;
//RxBool settingsShowing = false.obs;
  AnimationController? _animationController;

  RxBool get isOpen => _open;
  void _updateOpen(bool value) async {
    _open.value = value;
    print('updateOpen open $value');

    if (_animationController != null) {
      _open.value // depending if we are open or not we do this animation
          ? _animationController!.forward()
          : _animationController!.reverse();
    }

    update();
  }

  void handleOnPressed() {
    print('handleOnPressed = $_open');
    _updateOpen(!_open.value);
    update();
  }

  void initMenuButtonAnimatedController(
      AnimationController animationController) {
    _animationController = animationController;
  }

// RxBool get isSettingsShowing => settingsShowing;
//
// void setSettingsShowing(bool value) {
//   settingsShowing.value = value;
//   print('settingsShowing = $value');
//   update();
// }

}
