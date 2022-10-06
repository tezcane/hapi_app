import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';

/// Abstract class that all relics need to extend. Also extends Events so we can
/// Relics on the Timeline (if they have dates), you're welcome.
abstract class Relic extends Event {
  Relic({
    // Event data:
    required EVENT eventType,
    required String tkEra,
    required String tkTitle,
    required double startMs,
    required double endMs,
    // Relic data:
    required this.e,
  }) : super(
          eventType: eventType,
          tkEra: tkEra,
          tkTitle: tkTitle,
          startMs: startMs,
          endMs: endMs,
          accent: null, // TODO
        );
  final Enum e; // Unique relicId for this RELIC_TYPE

  int get ajrLevel => RelicC.to.getAjrLevel(eventType, e.index);

  /// Abstract methods:
  RelicAsset getRelicAsset({width = 200.0, height = 200.0, scale = 1.0});
  Widget get widget; // widget with all relic info
}

/// Stores all information needed to show a RelicSet, see RelicSetUI().
class RelicSet {
  RelicSet({
    required this.eventType,
    required this.relics,
    required this.tkTitle,
  });
  final EVENT eventType;
  final List<Relic> relics;
  final String tkTitle;

  /// Must init after relics are entered into this class or Tree filters fail.
  late final List<RelicSetFilter> filterList; // TODO cleaner way to init?
}

/// Used to tell RelicSetUI() to show a special field under the relic.
enum FILTER_FIELD {
  QuranMentionCount,
}

/// Used to be able to change Relic's view/information as a way for the user to
/// learn from a RelicSet, e.g. see only or highlight Ulu Al-Azm Prophets from
/// the list of all the Prophet relics. Another example, to show the Prophets or
/// Muhammad's Al-Bayt family tree views.
class RelicSetFilter {
  /// We must ensure tprMin/tprMax for all filters can support this value:
  static const DEFAULT_TPR = 5; // TODO

  const RelicSetFilter({
    required this.tkLabel,
    required this.idxList,
    required this.tprMax,
    this.tprMin = 1,
    this.field,
    this.treeGraph1,
    this.treeGraph2,
  });
  final String tkLabel;

  /// List of indexes to original relic list to display a full or
  /// subset of that list. For example, you can send in order of Prophets
  /// mentioned in the Quran count, i.e. [13, (136 Musa), 5, (69 Ibrahim)...]).
  final List<int> idxList;

  /// Work with "tpr" variable found and initialized in [RelicSetUI] (Sorry...)
  final int tprMax;
  final int tprMin;

  /// You can add a string/int/object? and we will have a switch in the UI to
  /// detect this field and then we hard code to display the fields value under
  /// the relics, e.g. Prophet names mentioned in the Quran count.
  final FILTER_FIELD? field;

  /// If [FILTER_TYPE.Tree], must specify treeGraph1 and optionally treeGraph2.
  final Graph? treeGraph1;
  final Graph? treeGraph2;

  bool get isTreeFilter => treeGraph1 != null || treeGraph2 != null;

  /// Tells if [RelicSetUI] should show -/+ buttons:
  bool get isResizeable => tprMin != tprMax; // TODO needed?
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
