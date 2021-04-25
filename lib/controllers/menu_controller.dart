import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  static MenuController to = Get.find();

  AnimationController? _fabAnimationController;
  void initMenuButtonAnimatedController(
      AnimationController animationController) {
    _fabAnimationController = animationController;
  }

  RxBool _isMenuShowing = false.obs;
  RxBool _isMenuShowingNav = false.obs;
  RxBool _isMenuShowingSpecial = false.obs;
  RxBool _isSpecialActionReady = false.obs;

  RxBool get isMenuShowing => _isMenuShowing;
  RxBool get isMenuNavShowing => _isMenuShowing;
  RxBool get isSpecialShowing => _isMenuShowing;
  RxBool get isSpecialActionReady => _isMenuShowing;

  void showMenu() {
    _isMenuShowing.value = true;
    _isMenuShowingNav.value = true;
    _isMenuShowingSpecial.value = false;
    _isSpecialActionReady.value = false;
  }

  void hideMenu() {
    _isMenuShowing.value = false;
    _isMenuShowingNav.value = false;
    _isMenuShowingSpecial.value = false;
    _isSpecialActionReady.value = false;
  }

  void showSpecialMenu() {
    hideMenuNav(); // same as hideMenuNav()
  }

  void hideMenuNav() {
    _isMenuShowingNav.value = false;
    _isMenuShowingSpecial.value = true;
  }

  void _updateIsMenuShowing(bool value) async {
    _isMenuShowing.value = value;
    print('_updateIsMenuShowing = $value');

    if (_fabAnimationController != null) {
      _isMenuShowing
              .value // depending if we are open or not we do this animation
          ? _fabAnimationController!.forward()
          : _fabAnimationController!.reverse();
    }

    update();
  }

  void handleOnPressed() {
    print('handleOnPressed = ${_isMenuShowing.value}');
    _updateIsMenuShowing(!_isMenuShowing.value);
  }
}
