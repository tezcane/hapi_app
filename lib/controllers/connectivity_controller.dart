import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityController extends GetxHapi {
  static ConnectivityController get to => Get.find();

  final Rx<ConnectivityResult> _connResult = ConnectivityResult.none.obs;
  ConnectivityResult get connResult => _connResult.value;

  final RxBool _isInternetOn = false.obs;
  bool get isInternetOn => _isInternetOn.value;
  set isInternetOn(bool isInternetOn) {
    if (_isInternetOn.value != isInternetOn) {
      _hasUpdate.value = true;
      update();
    }
    _isInternetOn.value = isInternetOn;
  }

  /// used to track if internet connection went up or down, can be read once
  final RxBool _hasUpdate = true.obs; // true so we check on init
  bool get hasUpdate {
    bool internetConnHasUpdate = _hasUpdate.value;
    _hasUpdate.value = false; // clear for next update
    return internetConnHasUpdate;
  }

  final Connectivity _conn = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;

  @override
  onInit() {
    super.onInit();
    initConnectivity();
    _streamSubscription =
        _conn.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  initConnectivity() async {
    try {
      ConnectivityResult connResult = await _conn.checkConnectivity();
      _updateConnectionStatus(connResult);
    } on PlatformException catch (e) {
      l.e('initConnectivity: Error Occurred: ${e.toString()}');
    }
  }

  _updateConnectionStatus(ConnectivityResult connResult) {
    l.i('Connectivity changed from ${_connResult.value} to $connResult');
    _connResult.value = connResult;

    // we only know radio/physical layer is on, check for internet connection
    checkIfInternetIsOn(connResult: connResult);
  }

  /// check if there is an internet connection
  Future<bool> checkIfInternetIsOn({ConnectivityResult? connResult}) async {
    //with result we can check if mobile data, wifi, ethernet, bluetooth or none
    final result = connResult ?? await _conn.checkConnectivity();

    // if connResult is one that can connect to the internet
    if (result != ConnectivityResult.bluetooth &&
        result != ConnectivityResult.none) {
      // check internet connection
      if (await InternetConnectionChecker().hasConnection) {
        isInternetOn = true; // device is connected to the internet
      } else {
        isInternetOn = false; // phy connected, but no internet
      }
    } else {
      isInternetOn = false; // mobile/wifi/ethernet is disconnected
    }

    l.d('checkIfInternetIsOn: _isInternetOn=${_isInternetOn.value}');

    return _isInternetOn.value;
  }

  /// Check if radio/physical layers are on
  bool get isPhysicalLayerOn =>
      _connResult.value == ConnectivityResult.mobile ||
      _connResult.value == ConnectivityResult.ethernet ||
      _connResult.value == ConnectivityResult.wifi;

  /// Be sure to cancel subscription after you are done
  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}
