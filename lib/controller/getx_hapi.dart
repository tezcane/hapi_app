import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';

/// To help find bugs and understand Getx/Flutter states we print all state
/// transitions here.  CANDO: removed once code is stable?
abstract class GetxHapi extends GetxController {
  GetxHapi() {
    l.v('GetxHapi.Constructor: $runtimeType');
  }

  /// Called immediately after the widget is allocated in memory.
  /// You might use this to initialize something for the controller.
  @override
  @mustCallSuper
  void onInit() {
    l.v('GetxHapi.onInit: $runtimeType');
    super.onInit();
  }

  /// Called 1 frame after onInit(). It is the perfect place to enter
  /// navigation events, like snackbar, dialogs, or a new route, or
  /// async request.
  @override
  void onReady() {
    l.v('GetxHapi.onReady: $runtimeType');
    super.onReady();
  }

  /// Called before [onDelete] method. [onClose] might be used to
  /// dispose resources used by the controller. Like closing events,
  /// or streams before the controller is destroyed.
  /// Or dispose objects that can potentially create some memory leaks,
  /// like TextEditingControllers, AnimationControllers.
  /// Might be useful as well to persist some data on disk.
  @override
  void onClose() {
    l.v('GetxHapi.onClose: $runtimeType');
    super.onClose();
  }

  /// Sometimes we need to run update() in another thread or there is a
  /// render/build/dirty error:
  void updateOnThread1Sec() =>
      Timer(const Duration(seconds: 1), () => update());

  /// Sometimes we need to run update() in another thread or there is a
  /// render/build/dirty error:
  void updateOnThread1Ms() =>
      Timer(const Duration(milliseconds: 1), () => update());
}
