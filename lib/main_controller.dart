import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/menu/menu_controller.dart';

class MainController extends GetxHapi {
  static MainController get to => Get.find();

  late final TargetPlatform _platform;

  bool isAppInitDone = false;

  RxBool isPortrait = true.obs; // MUST LEAVE TRUE FOR APP TO START

  @override
  void onInit() {
    super.onInit();

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
      print('ERROR: Unknown platform, defaulting to Android');
      _platform = TargetPlatform.android;
    }
  }

  TargetPlatform get platform => _platform;

  void setAppInitDone() {
    // Splash animations done, now allow screen rotations for the rest of time:
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Disable all OS overlay bars (e.g. top status and bottom navigation bar):
    SystemChrome.setEnabledSystemUIOverlays([]); // TODO deprecated

    isAppInitDone = true;
  }

  void setOrientation(bool isPortrait) {
    // don't proceed with any auto-orientation yet
    if (!isAppInitDone) {
      print('ORIENTATION: App is not initialized yet.');
      return;
    }

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

    if (MenuController.to.isAnySubPageShowing()) {
      update(); // notify watchers
    } else {
      // TODO only do this to fix slide menu for now
      if (MenuController.to.isMenuShowing()) {
        MenuController.to.hideMenu();
      }
      MenuController.to.navigateToNavPage(MenuController.to.getLastNavPage());
    }
  }
}
