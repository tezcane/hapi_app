// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hapi/controllers/connectivity_controller.dart';
import 'package:ntp/ntp.dart';

final TimeController cTime = Get.find();

/// used to know if NTP time is received or not
const DEFAULT_NTP_OFFSET = -999999;

/// Tez Birthday, used for init time, should never see this.
// ignore: non_constant_identifier_names
final DateTime DEFAULT_TIME = DateTime.parse("1983-09-24T01:02:03.004Z");

/// Used to get accurate server UTC/NTP based time incase user's clock is off
class TimeController extends GetxController {
  final RxInt _ntpOffset = DEFAULT_NTP_OFFSET.obs;

  final Rx<DateTime> _lastNtpTime = DEFAULT_TIME.obs;
  final Rx<DateTime> _lastLocTime = DEFAULT_TIME.obs;
  DateTime get lastUtcTime => _lastNtpTime.value;
  DateTime get lastLocTime => _lastLocTime.value;

  // TODO: handle this in geolocation controller and also pass timezone here
  // Location? _timeZone;
  // Coordinates _gps = Coordinates(36.950663449472, -122.05716133118);
  // double? _qiblaDirection;
  // double? get qiblaDirection => _qiblaDirection;

  bool forceSalahRecalculation = false;

  @override
  void onInit() async {
    super.onInit();
    updateNtpTime();
  }

  /// Gets NTP time from server when called, if internet is on
  updateNtpTime() async {
    if (!cConn.isInternetOn) {
      print('cTime:updateNtpTime: aborting NTP update, no internet connection');
      return;
    }
    print('cTime:updateNtpTime: Called');
    DateTime appTime = DateTime.now().toLocal();
    try {
      _ntpOffset.value = await NTP.getNtpOffset(localTime: appTime);
      _lastNtpTime.value =
          appTime.add(Duration(milliseconds: _ntpOffset.value));

      print(
          'cTime:updateNtpTime: NTP DateTime offset align (ntpOffset=$_ntpOffset):');
      print('cTime:updateNtpTime: locTime was=${appTime.toLocal()}');
      print('cTime:updateNtpTime: ntpTime now=${_lastNtpTime.value.toLocal()}');
    } on Exception catch (e) {
      print(
          'cTime:updateNtpTime: Exception: Failed to call NTP.getNtpOffset()');
    }
  }

  /// Get's local time, uses ntp offset to calculate more accurate time
  Future<DateTime> now() async {
    if (_ntpOffset.value == DEFAULT_NTP_OFFSET) {
      print('cTime:now: called but there is no ntp offset');
      await updateNtpTime();
    }
    DateTime time = DateTime.now().toLocal();
    if (_ntpOffset.value != DEFAULT_NTP_OFFSET) {
      time = time.add(Duration(milliseconds: _ntpOffset.value));
    }
    // print('cTime:now: (ntpOffset=$_ntpOffset) ${time.toLocal()}');
    return time.toLocal();
  }

  // TODO can delete after checking times more:
  // Future<double> getUTCTimeDifference() async {
  //   DateTime _myTime;
  //   DateTime _ntpTime;
  //
  //   /// Or you could get NTP current (It will call DateTime now() and add NTP offset to it)
  //   _myTime = await getUtcTime();
  //
  //   /// Or get NTP offset (in milliseconds) and add it yourself
  //   final int offset = await NTP.getNtpOffset(localTime: DateTime .now());
  //   _ntpTime = _myTime.add(Duration(milliseconds: offset));
  //
  //   print('My time: $_myTime');
  //   print('NTP time: $_ntpTime');
  //   print('Difference: ${_myTime.difference(_ntpTime).inMilliseconds}ms');
  //
  //   return _myTime.difference(_ntpTime).inMilliseconds;
  // }
}
