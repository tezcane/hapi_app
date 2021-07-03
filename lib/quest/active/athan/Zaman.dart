enum Zaman {
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

extension enumUtil on Zaman {
  String name() {
    return this
        .toString()
        .split('.')
        .last
        .replaceFirst('__', '/')
        .replaceAll('_', ' ');
  }

  String salahRow() {
    switch (this) {
      case (Zaman.Fajr):
        return Zaman.Fajr.name().toUpperCase();
      case (Zaman.Sunrise):
      case (Zaman.Ishraq):
      case (Zaman.Duha):
      case (Zaman.Zawal):
        return Zaman.Duha.name().toUpperCase();
      case (Zaman.Dhuhr):
        return Zaman.Dhuhr.name().toUpperCase();
      case (Zaman.Asr):
      case (Zaman.Sun_Setting):
        return Zaman.Asr.name().toUpperCase();
      case (Zaman.Maghrib):
        return Zaman.Maghrib.name().toUpperCase();
      case (Zaman.Isha):
      default:
        return Zaman.Isha.name().toUpperCase();
    }
  }
}
