import 'package:geolocator/geolocator.dart';
import 'package:hapi/controller/time_c.dart';

/// Used for GPS coordinates, extends more detailed Position class used by
/// geolocator.  Does this since we only, so far, need lat/lng only.
class Cord extends Position {
  Cord(double lat, double lng, {double altitude = 0})
      : super(
          latitude: lat,
          longitude: lng,
          timestamp: TimeC.to.now2(),
          altitude: altitude,
          accuracy: 0.0,
          heading: 0.0,
          floor: null,
          speed: 0.0,
          speedAccuracy: 0.0,
          isMocked: false,
        );

  double get lat => latitude; // latitude
  double get lng => longitude; // longitude

  static Cord fromPosition(Position position) =>
      Cord(position.latitude, position.longitude, altitude: position.altitude);
}
