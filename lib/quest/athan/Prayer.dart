enum Prayer {
  Fajr,
  Sunrise, // begin sunrise (kerahat 1), also Morning Adhkar time
  Ishraq,
  Duha,
  Zawal, // begin sun zentih/peaking (kerahat 2)
  Dhuhr,
  Asr,
  Sun_Setting, // begin sunset (kerahat 3), also Evening Adhkar time
  Maghrib,
  Isha,
  Middle_of_Night,
  Last_1__3_of_Night,
  Fajr_Tomorrow,
  Sunrise_Tomorrow,
}

extension enumUtil on Prayer {
  String name() {
    return this
        .toString()
        .split('.')
        .last
        .replaceFirst('__', '/')
        .replaceAll('_', ' ');
  }
}
