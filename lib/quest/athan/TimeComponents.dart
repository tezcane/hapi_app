class TimeComponents {
  late final int hours;
  late final int minutes;
  late final int seconds;

  TimeComponents(double number) {
    this.hours = (number).floor();
    this.minutes = ((number - this.hours) * 60).floor();
    this.seconds = ((number - (this.hours + this.minutes / 60)) * 3600).floor();
  }

  DateTime utcDate(int year, int month, int date) {
    return new DateTime.utc(
        year, month, date, this.hours, this.minutes, this.seconds);
  }
}
