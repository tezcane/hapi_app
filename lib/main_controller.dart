import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_controller.dart';

final MainController cMain = Get.find();

class MainController extends GetxController {
  static MainController get to => Get.find();

  late final TargetPlatform _platform;

//bool? lastOrientationWasPortrait;
  RxBool isPortrait = true.obs;

  @override
  void onInit() {
    // TODO test all these platforms and add web
    if (Platform.isAndroid) {
      _platform = TargetPlatform.android;
    } else if (Platform.isIOS) {
      _platform = TargetPlatform.iOS;
    } else if (Platform.isWindows) {
      _platform = TargetPlatform.windows;
    } else if (Platform.isMacOS) {
      _platform = TargetPlatform.macOS;
    } else if (Platform.isLinux) {
      _platform = TargetPlatform.linux;
    } else if (Platform.isFuchsia) {
      _platform = TargetPlatform.fuchsia;
    } else {
      print('Unknown platform, defaulting to android');
      _platform = TargetPlatform.android;
    }

    ///lastState = MediaQuery.of(context).orientation == Orientation.portrait;

    super.onInit();
  }

  TargetPlatform get platform => _platform;

  // void initOrientation(bool isPortrait) {
  //   lastOrientationWasPortrait = isPortrait;
  // }

  void setOrientation(bool isPortrait) {
    bool lastModeWasPortait = this.isPortrait.value;

    if (lastModeWasPortait && isPortrait) {
      print('ORIENTATION: Still in portrait');
      return;
    }

    // if still in landscape mode return
    if (!lastModeWasPortait && !isPortrait) {
      print('ORIENTATION: Still in landscape');
      return;
    }

    if (isPortrait) {
      print('ORIENTATION: Switched to portrait');
    } else {
      print('ORIENTATION: Switched to landscape');
    }

    this.isPortrait.value = isPortrait;

    if (cMenu.isAnySubPageShowing()) {
      update(); // notify watchers
    } else {
      // TODO only do this to fix slide menu for now
      if (cMenu.isMenuShowing()) {
        cMenu.hideMenu();
      }
      cMenu.navigateToNavPage(cMenu.getLastNavPage());
    }
  }
}
