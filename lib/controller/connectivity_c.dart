import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityC extends GetxHapi {
  static ConnectivityC get to => Get.find();

  ConnectivityResult _connResult = ConnectivityResult.none;
  ConnectivityResult get connResult => _connResult;

  // default to internet on so we force NTP init attempt at app init
  bool _isInternetOn = true;
  bool get isInternetOn => _isInternetOn;
  set isInternetOn(bool isInternetOn) {
    if (_isInternetOn != isInternetOn) {
      _hasUpdate = true;
      update();
    }
    _isInternetOn = isInternetOn;
  }

  /// used to track if internet connection went up or down, can be read once
  bool _hasUpdate = true; // true so we check on init
  bool get hasUpdate {
    bool internetConnHasUpdate = _hasUpdate;
    _hasUpdate = false; // clear for next update
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
    l.i('Connectivity changed from $_connResult to $connResult');
    _connResult = connResult;

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

    l.d('checkIfInternetIsOn: _isInternetOn=$_isInternetOn');

    return _isInternetOn;
  }

  /// Check if radio/physical layers are on
  bool get isPhysicalLayerOn =>
      _connResult == ConnectivityResult.mobile ||
      _connResult == ConnectivityResult.ethernet ||
      _connResult == ConnectivityResult.wifi;

  /// Be sure to cancel subscription after you are done
  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}
