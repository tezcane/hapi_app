import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('America/Los_Angeles');
  //final location = tz.getLocation('America/California');

  // Definitions
  DateTime date = tz.TZDateTime.from(DateTime.now(), location);
  Coordinates coordinates = Coordinates(37.3382, 121.8863);

  // Parameters
  CalculationParameters params = CalculationMethod.MuslimWorldLeague();
  params.madhab = Madhab.Hanafi;
  PrayerTimes prayerTimes =
      PrayerTimes(coordinates, date, params, precision: true);

  // Prayer times
  DateTime fajrTime = tz.TZDateTime.from(prayerTimes.fajr!, location);
  DateTime sunriseTime = tz.TZDateTime.from(prayerTimes.sunrise!, location);
  DateTime dhuhrTime = tz.TZDateTime.from(prayerTimes.dhuhr!, location);
  DateTime asrTime = tz.TZDateTime.from(prayerTimes.asr!, location);
  DateTime maghribTime = tz.TZDateTime.from(prayerTimes.maghrib!, location);
  DateTime ishaTime = tz.TZDateTime.from(prayerTimes.isha!, location);

  DateTime ishabeforeTime =
      tz.TZDateTime.from(prayerTimes.ishabefore!, location);
  DateTime fajrafterTime = tz.TZDateTime.from(prayerTimes.fajrafter!, location);

  // Convenience Utilities
  String current =
      prayerTimes.currentPrayer(date: DateTime.now()); // date: date
  DateTime? currentPrayerTime = prayerTimes.timeForPrayer(current);
  String next = prayerTimes.nextPrayer();
  DateTime? nextPrayerTime = prayerTimes.timeForPrayer(next);

  // Sunnah Times
  SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);
  DateTime middleOfTheNight =
      tz.TZDateTime.from(sunnahTimes.middleOfTheNight, location);
  DateTime lastThirdOfTheNight =
      tz.TZDateTime.from(sunnahTimes.lastThirdOfTheNight, location);

  // Qibla Direction
  var qiblaDirection = Qibla.qibla(coordinates);

  print('***** Current Time');
  print('local time:  $date');

  print('\n***** Prayer Times');
  print('fajr:    $fajrTime');
  print('sunrise: $sunriseTime');
  print('dhuhr:   $dhuhrTime');
  print('asr:     $asrTime');
  print('maghrib: $maghribTime');
  print('isha:    $ishaTime');

  print('isha before Time:  $ishabeforeTime');
  print('fajr after  Time:  $fajrafterTime');

  print('\n***** Convenience Utilities');
  print('current:\t$current\t$currentPrayerTime');
  print('next:   \t$next\t$nextPrayerTime');

  print('\n***** Sunnah Times');
  print('middleOfTheNight:  \t$middleOfTheNight');
  print('lastThirdOfTheNight:  \t$lastThirdOfTheNight');

  print('\n***** Qibla Direction');
  print('qibla:  \t$qiblaDirection');
}
