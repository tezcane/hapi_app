import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/surah/surah.dart';
import 'package:hapi/relic/ummah/nabi.dart';
import 'package:hapi/tarikh/event/et.dart';

/// See [et.dart] for detailed description why we need this in a separate file.
extension EtExtension on ET {
  String get tkRelicSetTitle => tkIsimA; // name of EVENT is "a." title
  String get trPath => 'event/${name.toLowerCase()}/';

  bool get isRelic => index != ET.Tarikh.index;

  List<Relic> initRelics() {
    switch (this) {
      case ET.Nabi:
        return relicsNabi;
      case ET.Surah:
        return relicsSurah;
      case ET.Tarikh:
        return l.E('$name is not a relic');
    }
  }

  List<RelicSetFilter> initRelicSetFilters() {
    switch (this) {
      case ET.Nabi:
        return relicSetFiltersNabi;
      case ET.Surah:
        return relicSetFiltersSurah;
      case ET.Tarikh:
        return l.E('$name is not a relic');
    }
  }
}
