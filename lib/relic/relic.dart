import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/et_extension.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';

/// Abstract class that all relics need to extend. Also extends Events so we can
/// Relics on the Timeline (if they have dates), you're welcome.
abstract class Relic extends Event {
  Relic({
    // Event data:
    required ET et,
    required String tkEra,
    required String tkTitle,
    required double start,
    required double end,
    // Relic data:
    required this.e,
  }) : super(
          et: et,
          tkEra: tkEra,
          tkTitle: tkTitle,
          start: start,
          end: end,
          accent: null, // TODO
        );
  final Enum e; // Unique relicId for this EVENT_TYPE (ET)

  int get ajrLevel => RelicC.to.getAjrLevel(et, e.index);

  /// Override to show num (e.g. Surah Number) on RelicSetUI() title line.
  bool get showNum => false;
  int get num => e.index + 1; // +1 since enums 0 indexed

  /// Abstract methods:
  Asset getAsset();
  Widget get widget; // widget with all relic info

  /* NOTE: Sub classes implement these static methods used in et_extension.dart:
  static List<Relic> get relics => _relics;
  static List<RelicSetFilter> get relicSetFilters => _relicSetFilters; */
}

/// Inits and stores all data needed to show a RelicSet, see RelicSetUI().
class RelicSet {
  RelicSet(this.et) {
    tkTitle = et.tkRelicSetTitle;
    relics = et.initRelics();
    filterList = et.initRelicSetFilters();
  }
  final ET et;

  late final String tkTitle;
  late final List<Relic> relics;
  late final List<RelicSetFilter> filterList;
}

/// Used to tell RelicSetUI() to show a special field under the relic.
enum FILTER_FIELD {
  // Nabi and Asma ul-Husna:
  QuranMentionCount,
  // Surah:
  OrderByEgyptianStandard,
  OrderByNoldeke,
  OrderByVerseCount,
  OrderByRukuCount,
  ShowJuz,
  StartToEndDate,
  HasMuqattaat,
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
