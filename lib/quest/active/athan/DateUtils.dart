DateTime dateByAddingDays(DateTime date, int days) {
  return date.add(Duration(days: days));
}

DateTime dateByAddingMinutes(DateTime date, int minutes) {
  return dateByAddingSeconds(date, minutes * 60);
}

DateTime dateByAddingSeconds(DateTime date, int seconds) {
  return date.add(Duration(seconds: seconds));
}

DateTime roundedMinute(DateTime date, {bool precision = true}) {
  if (precision) return date;

  int seconds = date.toUtc().second % 60;
  int offset = seconds >= 30 ? 60 - seconds : -1 * seconds;

  return dateByAddingSeconds(date, offset);
}

int dayOfYear(DateTime date) {
  Duration diff = date.difference(DateTime(date.year, 1, 1, 0, 0));

  int returnedDayOfYear = diff.inDays + 1; // 1st Jan should be day 1

  return returnedDayOfYear;
}
