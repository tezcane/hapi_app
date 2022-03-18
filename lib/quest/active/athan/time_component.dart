class TimeComponent {
  late final int hours;
  late final int minutes;
  late final int seconds;

  TimeComponent(double number) {
    hours = (number).floor();
    minutes = ((number - hours) * 60).floor();
    seconds = ((number - (hours + minutes / 60)) * 3600).floor();
  }

  DateTime utcDate(int year, int month, int date) {
    return DateTime.utc(year, month, date, hours, minutes, seconds);
  }
}
