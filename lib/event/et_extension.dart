import 'package:hapi/event/et.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/akadimi/surah.dart';
import 'package:hapi/relic/al_asma/asma_ul_husna.dart';
import 'package:hapi/relic/al_asma/nabi.dart';
import 'package:hapi/relic/islam/al_aqida.dart';
import 'package:hapi/relic/islam/delil.dart';
import 'package:hapi/relic/mamlaka/rasulallah.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/ummah/makan.dart';

/// See [et.dart] for detailed description why we need this in a separate file.
extension EtExtension on ET {
  String get tkRelicSetTitle => tkIsimA; // name of EVENT is "a." title
  String get trPath => 'event/${name.toLowerCase()}/';

  bool get isRelic => index != ET.Tarikh.index;

  List<Relic> initRelics() {
    switch (this) {
      // Islam
      case ET.Delil:
        return Delil.relics;
      case ET.Al__Aqida:
        return AlAqida.relics;

      // Asma/Names
      case ET.Asma_ul__Husna:
        return AsmaUlHusna.relics;
      case ET.Nabi:
        return Nabi.relics;

      // Akadimi/Academic
      case ET.Surah:
        return Surah.relics;

      // Ummah
      case ET.Makan:
        return Makan.relics;

      // Dynasties/Kingdoms
      case ET.Rasulallah:
        return Rasulallah.relics;

      // Tarikh
      case ET.Tarikh:
        return l.E('$name is not a relic');
    }
  }

  List<RelicSetFilter> initRelicSetFilters() {
    switch (this) {
      // Islam
      case ET.Delil:
        return Delil.relicSetFilters;
      case ET.Al__Aqida:
        return AlAqida.relicSetFilters;

      // Asma/Names
      case ET.Asma_ul__Husna:
        return AsmaUlHusna.relicSetFilters;
      case ET.Nabi:
        return Nabi.relicSetFilters;

      // Akadimi/Academic
      case ET.Surah:
        return Surah.relicSetFilters;

      // Ummah
      case ET.Makan:
        return Makan.relicSetFilters;

      // Dynasties/Kingdoms
      case ET.Rasulallah:
        return Rasulallah.relicSetFilters;

      // Tarikh
      case ET.Tarikh:
        return l.E('$name is not a relic');
    }
  }
}
