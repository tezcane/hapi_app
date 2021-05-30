double degreesToRadians(double degrees) {
  return (degrees * 3.1415926535897932) / 180.0;
}

double radiansToDegrees(double radians) {
  return (radians * 180.0) / 3.1415926535897932;
}

double normalizeToScale(double number, double max) {
  return number - (max * ((number / max).floor()));
}

double unwindAngle(double angle) {
  return normalizeToScale(angle, 360.0);
}

double quadrantShiftAngle(double angle) {
  if (angle >= -180 && angle <= 180) {
    return angle;
  }

  return angle - (360 * (angle / 360).round());
}
