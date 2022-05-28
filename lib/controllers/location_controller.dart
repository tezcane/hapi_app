import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/helpers/cord.dart';
import 'package:hapi/main_controller.dart';

// TODO finish setup geolocator for all platforms: https://pub.dev/packages/geolocator
// TODO currently used high for accuracy and 1000 meter filter, test all platforms
/// LocationController is used to get location/gps coordinates.
///
/// Uses Flutter geolocation plugin "geolocator" to provide easy access to
/// platform specific location services (FusedLocationProviderClient or if not
/// available the LocationManager on Android and CLLocationManager on iOS).
/// FusedLocationProviderClient - https://developers.google.com/android/reference/com/google/android/gms/location/FusedLocationProviderClient
/// LocationManager (Android)   - https://pub.dev/packages/geolocator#:~:text=not%20available%20the-,LocationManager,-on%20Android%20and
/// CLLocationManager (iOS)     - https://developer.apple.com/documentation/corelocation/cllocationmanager
///
/// Features
/// Get the last known location;
/// Get the current location of the device;
/// Get continuous location updates;
/// Check if location services are enabled on the device;
/// Calculate the distance (in meters) between two geocoordinates;
/// Calculate the bearing between two geocoordinates;
/// Location accuracy
/// The table below outlines the accuracy options per platform:
///
/// Accuracy Level      Android    iOS
/// lowest              500m       3000m
/// low                 500m       1000m
/// medium              100-500m   100m
/// high                0-100m     10m
/// best                0-100m     ~0m
/// bestForNavigation   0-100m     Optimized for navigation: https://developer.apple.com/documentation/corelocation/kcllocationaccuracybestfornavigation
class LocationController extends GetxHapi {
  static LocationController get to => Get.find();

  late final LocationSettings _locationSettings;

  late final StreamSubscription<Position> _positionStream;
  late final StreamSubscription<ServiceStatus> _serviceStatusStream;

  Cord? _lastKnownCord;
  set lastKnownCord(Cord? cord) {
    if (cord != null) {
      s.wr('lastKnownCordLat', cord.latitude);
      s.wr('lastKnownCordLng', cord.longitude);
      _lastKnownCord = cord;
    }
  }

  Cord get lastKnownCord {
    if (_lastKnownCord == null) {
      if (s.rd('lastKnownCordLat') != null &&
          s.rd('lastKnownCordLng') != null) {
        return Cord(s.rd('lastKnownCordLat'), s.rd('lastKnownCordLng'));
      } else {
        // TODO show map to choose?
        l.e('get lastKnownCord using default cord');
        return Cord(36.950663449472, -122.05716133118);
      }
    }

    return _lastKnownCord!;
  }

  late double _qiblaDirection;
  double get qiblaDirection => _qiblaDirection;

  @override
  onInit() async {
    super.onInit();
    await _initLocation();
  }

  _initLocation() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1000,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        // //(Optional) Set foreground notification config to keep the app alive
        // //when going to the background TODO don't need/want?
        // foregroundNotificationConfig: const ForegroundNotificationConfig(
        //   notificationText:
        //       "hapi will continue to receive your location even when you aren't using it",
        //   notificationTitle: "Running in Background",
        //   enableWakeLock: true,
        // ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 1000,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      _locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1000,
      );
    }

    /// Checks permissions, shows system dialogs if needed, and gets position
    try {
      Position position = await _determinePosition();
      _updatePosition(position);
    } on Exception {
      // TODO
    }

    // To listen for location changes you can call the getPositionStream to
    // receive stream you can listen to and receive position updates. You can
    // finetune the results by specifying the following parameters:
    //
    // accuracy:       the accuracy of the location data that your app wants to
    //                 receive;
    // distanceFilter: the minimum distance (measured in meters) a device must
    //                 move horizontally before an update event is generated;
    // timeLimit:      the maximum amount of time allowed between location
    //                 updates.
    //
    // When the time limit is passed a TimeOutException will be thrown and the
    // stream will be cancelled. By default no limit is configured.
    _positionStream =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((Position? position) {
      if (position == null) {
        l.e('STREAM UPDATE: _positionStream: Unknown GPS position');
      } else {
        l.i('STREAM UPDATE: _positionStream: $position');
      }
      _updatePosition(position);
    });

    // To listen for service status (enabled/disabled) changes you can call the
    // getServiceStatusStream.  This will return a Stream<ServiceStatus> which
    // can be listened to, to receive location service status updates.
    _serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      l.i('STREAM UPDATE: _serviceStatusStream=$status');
      _updatePosition(null);
    });
  }

  _updatePosition(Position? position) async {
    position ??= await getLastKnownPosition();
    lastKnownCord = Cord.fromPosition(position!);
    _qiblaDirection =
        LocationController.to.getQiblaBearing(lastKnownCord); // Qibla Direction
    l.i('qibla bearing: $_qiblaDirection');
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  /// To query the last known location retrieved stored on the device you can
  /// use the getLastKnownPosition method (note that this can result in a null
  /// value when no location details are available):
  Future<Position?> getLastKnownPosition() async =>
      await Geolocator.getLastKnownPosition();

  /// Location accuracy (Android and iOS 14+ only)
  /// To query if a user enabled Approximate location fetching or Precise
  /// location fetching, you can call the Geolocator().getLocationAccuracy()
  /// method. This will return a Future<LocationAccuracyStatus>, which when
  /// completed contains a LocationAccuracyStatus.reduced if the user has
  /// enabled Approximate location fetching or LocationAccuracyStatus.precise
  /// if the user has enabled Precise location fetching. When calling
  /// getLocationAccuracy before the user has given permission, the method will
  /// return LocationAccuracyStatus.reduced by default.
  ///
  /// On iOS 13 or below, the method getLocationAccuracy will always return
  /// LocationAccuracyStatus.precise, since that is the default value for iOS 13
  /// and below.
  Future<LocationAccuracyStatus> _getLocationAccuracy() async =>
      await Geolocator.getLocationAccuracy();

  /// To check if location services are enabled.
  Future<bool> _isLocationServiceEnabled() async =>
      await Geolocator.isLocationServiceEnabled();

  /// Permissions 1 of 2:
  /// When using the web platform, the checkPermission method will return the
  /// LocationPermission.denied status, when the browser doesn't support the
  /// JavaScript Permissions API. Nevertheless, the getCurrentPosition and
  /// getPositionStream methods can still be used on the web platform.
  ///
  /// If you want to check if the user already granted permissions to acquire
  /// the device's location you can make a call to the checkPermission method:
  Future<LocationPermission> _checkPermissionOnWeb() async =>
      await Geolocator.checkPermission();

  /// Permissions 2 of 2:
  /// If you want to request permission to access the device's location you can
  /// call the requestPermission method.
  ///
  /// Possible results from the checkPermission and requestPermission methods:
  ///
  /// Permission    Description
  /// denied        Permission to access the device's location is denied by the
  ///               user. You are free to request permission again (this is also
  ///               the initial permission state).
  /// deniedForever Permission to access the device's location is permenantly
  ///               denied. When requesting permissions the permission dialog
  ///               will not been shown until the user updates the permission in
  ///               the App settings.
  /// whileInUse    Permission to access the device's location is allowed only
  ///               while the App is in use.
  /// always        Permission to access the device's location is allowed even
  ///               when the App is running in the background.
  ///
  /// Note: Android can only return whileInUse, always or denied when checking
  /// permissions. Due to limitations on the Android OS it is not possible to
  /// determine if permissions are denied permanently when checking permissions.
  /// Using a workaround the geolocator is only able to do so as a result of the
  /// requestPermission method. More information can be found in our wiki:
  /// https://github.com/Baseflow/flutter-geolocator/wiki/Breaking-changes-in-7.0.0#android-permission-update
  Future<LocationPermission> _requestPermission() async =>
      await Geolocator.requestPermission();

  /// Settings 1 of 2
  /// In some cases it is necessary to ask the user and update their device
  /// settings. For example when the user initially permanently denied
  /// permissions to access the device's location or if the location services
  /// are not enabled (and, on Android, automatic resolution didn't work). In
  /// these cases you can use the openAppSettings or openLocationSettings
  /// methods to immediately redirect the user to the device's settings page.
  Future<bool> _openLocationSettings() async =>
      await Geolocator.openLocationSettings();

  /// Settings 2 of 2
  /// On Android the openAppSettings method will redirect the user to the App
  /// specific settings where the user can update necessary permissions. The
  /// openLocationSettings method will redirect the user to the location
  /// settings where the user can enable/disable the location services.
  ///
  /// On iOS we are not allowed to open specific setting pages so both methods
  /// will redirect the user to the Settings App from where the user can
  /// navigate to the correct settings category to update permissions or
  /// enable/disable the location services.
  Future<bool> _openAppSettings() async => await Geolocator.openAppSettings();

  /// Utility method 1 of 2
  /// To calculate the distance (in meters) between two geocoordinates you can
  /// use the distanceBetween method.
  ///
  /// The distanceBetween method takes four parameters:
  ///    Parameter        Type     Description
  ///    startLatitude    double   Latitude of the start position
  ///    startLongitude   double   Longitude of the start position
  ///    endLatitude      double   Latitude of the destination position
  ///    endLongitude     double   Longitude of the destination position
  double _distanceInMeters(Cord start, Cord end) =>
      Geolocator.distanceBetween(start.lat, start.lng, end.lat, end.lng);

  double distanceToKabaa(Cord cord) {
    return _distanceInMeters(cord, getKabaaCord());
  }

  /// Utility method 2 of 2
  /// If you want to calculate the bearing between two geocoordinates you can
  /// use the bearingBetween method. The bearingBetween method also takes four
  /// parameters:
  ///
  /// The distanceBetween method takes four parameters:
  ///    Parameter        Type     Description
  ///    startLatitude    double   Latitude of the start position
  ///    startLongitude   double   Longitude of the start position
  ///    endLatitude      double   Latitude of the destination position
  ///    endLongitude     double   Longitude of the destination position
  ///
  /// The initial bearing will most of the time be different than the end
  /// bearing, see https://www.movable-type.co.uk/scripts/latlong.html#bearing.
  double _bearingBetween(Cord start, Cord end) => Geolocator.bearingBetween(
      start.latitude, start.longitude, end.latitude, end.longitude);

  double getQiblaBearing(Cord cord) {
    return _bearingBetween(cord, getKabaaCord());
  }

  Cord getKabaaCord() => Cord(
      21.422487, // 21.4225239  21.422522 TODO find most accurate, makkah = Coord(21.4225241, 39.8261818);
      39.826206, //39.8261816 39.826181
      altitude: 277.063);
}
