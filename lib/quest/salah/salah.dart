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

// main() {
//   String text = "asdf";
//   String text2 = 'asdf';
//
//   int number = 0;
//   double number2 = 0;
//
//   //List<int> numbers = [number, number + 1, number + 2];
//
//   // for (int num in numbers) {
//   //   print('num=$num');
//   // }
//   //
//   // for (int idx = 0; idx <= 10; idx++) {
//   //   print('num=$idx');
//   // }
//
//   // for (int idx = 10; idx >= 0; idx--) {
//   //   print('num=$idx');
//   // }
//
//   // int num = 0;
//   // while (true) {
//   //   //print(num);
//   //   num++;
//   //   // num += 1;
//   //   // num = num + 1;
//   //   if (num == 10) {
//   //     break;
//   //   } else if (num == 3) {
//   //     //print('not at ten, got $num');
//   //     num++;
//   //   } else {
//   //     print('not at ten, got $num');
//   //   }
//   // }
//
//   //print(num);
//
//   List<Animal> animals = [Cat(), Snake(), Cat()];
//
//   for (Animal animal in animals) {
//   print('Animal is ${animal.name} and hasLegs=${animal.hasLegs()}');
//   }
//
//   print('Animal is ${animals[0].name} and hasLegs=${animals[0].hasLegs()}');
//   print('Animal is ${animals[1].name} and hasLegs=${animals[1].hasLegs()}');
//
//   for (int i = 0; i < animals.length; i++) {
//   print('Animal is ${animals[i].name} and hasLegs=${animals[i].hasLegs()}');
//   }
//   }
//
//   class Animal {
//     Animal(this.name);
//
//     String name;
//
//     String getName() {
//       return name;
//     }
//
//     bool hasLegs() {
//       return true;
//     }
//   }
//
//   class Cat extends Animal {
//     Cat() : super("cat");
//
//   // @override
//   // bool hasLegs() {
//   //   return true;
//   // }
//   }
//
//   class Snake extends Animal {
//     Snake() : super("snake");
//
//     @override
//     bool hasLegs() {
//       return false;
//     }
//   }
// }
