import 'package:flutter/material.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';

/// Peace be upon all (SAW) all the Anbiya/Prophets mentioned in the code.
class Delil extends Relic {
  Delil(Enum e)
      : super(
          // Event data:
          et: ET.Delil,
          tkEra: ET.Delil.tkIsimA,
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
  Delil(Proof.Quran),
];

final List<RelicSetFilter> _relicSetFilters = [
  RelicSetFilter(
    tkLabel: ET.Delil.tkIsimA,
    idxList: List.generate(
      _relics.length,
      (index) => _relics[index].e.index,
    ),
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'a.Quran',
    idxList: [
      Proof.Quran.index,
    ],
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'a.Sunnah',
    idxList: [
      Proof.Quran.index,
    ],
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'Nature',
    idxList: [
      Proof.Quran.index,
    ],
    tprMax: _relics.length,
  ),
  RelicSetFilter(
    tkLabel: 'Ruins',
    idxList: [
      Proof.Quran.index,
    ],
    tprMax: _relics.length,
  ),
];

enum Proof {
  Quran,
  ;
}

/*  Miracles of Quran:
The universe expands all the time. (adh-Dhariyat 51/47)
Big-Bang, the skies and the earth being cleft asunder. (al-Anbiya 21/30, Fussilat 41/11)
Winds fecundating clouds and plants. (al-Hijr 15/22)
The word "nahl", that is, "bee" being used as a feminine word and its verb forms being used with feminine forms. (an-Nahl 16/68-69)
Planets are not fixed; they have certain orbits and courses. (Ya-Sin 36/38 and 40, al-Anbiya 21/33, Luqman 31/29)
Two seas not mixing with each other; the law of "surface tension". (ar-Rahman 55/19-20, al-Furqan 25/53)
Underground waters being formed by rain water. (az-Zumar 39/21)
The earth being reduced from its outlying borders. (ar-Ra'd 13/41, al-Anbiya 21/44)
The dangers of the house built by the female spider and its insecurity. (al-Ankabut 29/41)
Femininity and masculinity in plants. (Ta-Ha 20/53, ar-Ra'd 13/3)
The three stages of the baby in the uterus: abdominal wall, uterine wall, amnionic membrane. (az-Zumar 39/6)
The phase of mudghah - a little lump of flesh (chewed substance) in the uterus. (al-Mu'minun 23/14)
Clouds are actually very heavy. (al-A'raf 7/57, ar-Ra'd 13/12)
Mountains are not fixed; they move. (an-Naml 27/88)
Iron came to the world from outer space. (al-Hadid 57/25)
We need to move while sleeping. (al-Kahf 18/18)
Ears are active during sleep. (al-Kahf 18/11)
Creation in pairs; everything is created in pairs and with opposites. (Ya-Sin 36/36)
The world is round. (az-Zumar 39/5, an-Naziat 79/30)
Oxygen decreases as altitude increases. (al-An'am 6/125)
Meteors; the atmosphere, which prevents us from harmful sun rays and adversities like space cold. (al-Anbiya 21/32)
The sky that returns; meteors, harmful rays, heat, radio waves... (at-Tariq 86/11)
Mountains with duties. (al-Anbiya 21/31, an-Naba 78/6-7, Luqman 31/10)
The star that knocks. (at-Tariq 86/1)
The red rose in the sky "Rosetta Nebula". (ar-Rahman 55/37)
Relativity of time. (as-Sajda 32/5, al-Maarij 70/4)
It is not possible to leave the atmosphere without a propelling power and a burning will occur in the meantime. (ar-Rahman 55/ 33-36)
Everybody has different fingerprints. (al-Qiyamah 75/4)
Everybody has different tongue prints. (ar-Rum 30/22)
Cattle were sent down from the sky. (az-Zumar 39/6)
 */
