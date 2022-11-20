import 'package:flutter/material.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/et_extension.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';

/// Peace be upon all (SAW) all the Anbiya/Prophets mentioned in the code.
class Rasulallah extends Relic {
  Rasulallah(Enum e)
      : super(
          // Event data:
          et: ET.Asma_ul__Husna,
          tkEra: ET.Asma_ul__Husna.tkRelicSetTitle,
          tkTitle: e.tkIsimA,
          start: 0,
          end: 0,
          // Relic data:
          e: e,
        );

  @override
  Asset getAsset() => Asset(filename: 'images/logo/logo.png');

  @override
  // TODO: implement widget
  Widget get widget => throw UnimplementedError();

  static List<Relic> get relics => _relics;
  static List<RelicSetFilter> get relicSetFilters => _relicSetFilters;
}

final List<Relic> _relics = [
  Rasulallah(AUH.asdf),
];

List<RelicSetFilter> _relicSetFilters = [
  RelicSetFilter(
    tkLabel: 'a.Nabi',
    idxList: List.generate(
      _relics.length,
      (index) => _relics[index].e.index,
    ),
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'a.Rasul',
    idxList: [
      AUH.asdf.index,
    ],
    tprMax: _relics.length,
  ),
];

/// TODO
enum AUH {
  asdf,
  ;
}
