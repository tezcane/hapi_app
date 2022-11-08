import 'package:flutter/material.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';

/// Peace be upon all (SAW) all the Anbiya/Prophets mentioned in the code.
class AlAqida extends Relic {
  AlAqida(Enum e)
      : super(
          // Event data:
          et: ET.Al__Aqida,
          tkEra: ET.Al__Aqida.tkIsimA,
          tkTitle: e.tkIsimA,
          start: 0,
          end: 0,
          // Relic data:
          e: e,
        );

  @override
  Asset getAsset({width = 200.0, height = 200.0, scale = 1.0}) => Asset(
        filename: 'images/logo/logo.png', // TODO asdf: implement
        width: width,
        height: height,
        scale: scale,
      );

  @override
  // TODO: implement widget
  Widget get widget => throw UnimplementedError();

  static List<Relic> get relics => _relics;
  static List<RelicSetFilter> get relicSetFilters => _relicSetFilters;
}

final List<Relic> _relics = [
  AlAqida(TENETS.Pillars_),
];

final List<RelicSetFilter> _relicSetFilters = [
  RelicSetFilter(
    tkLabel: ET.Al__Aqida.tkIsimA,
    idxList: List.generate(
      _relics.length,
      (index) => _relics[index].e.index,
    ),
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'Five Pillars of Islam',
    idxList: [
      TENETS.Pillars_.index,
    ],
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'Six Articles of Faith',
    idxList: [
      TENETS.Pillars_.index,
    ],
    tprMax: _relics.length,
  ),
];

/// TODO
enum TENETS {
  Pillars_,
  Articles_Of_Faith_;
}
