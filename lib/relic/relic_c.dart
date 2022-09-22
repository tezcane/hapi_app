import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/relic/ummah/prophet.dart';
import 'package:hapi/service/db.dart';
import 'package:hapi/tarikh/event/event.dart';

class RelicC extends GetxHapi {
  static RelicC get to => Get.find();

  /// Perfect hash, access via [RELIC_TYPE.index]
  final List<RelicSet> _relicSets = [];

  /// needed by relic tab bar
  bool initNeeded = true;

  @override
  void onInit() {
    _initRelicSets();
    super.onInit();
  }

  // TODO get working via something like Relic.init() abstract method...
  Future<List<Relic>> _initRelics(RELIC_TYPE relicType) async {
    switch (relicType) {
      case (RELIC_TYPE.Quran_AlAnbiya):
        return await initProphets();
      default:
        return []; // TODO enable: return l.E('relicType=${relicType.name} init() not implemented yet');
    }
  }

  /// Merge relic events with a time into tarikh events so they show Timeline
  /// and return all relic events in another list which is needed for further
  /// app init.
  List<Event> mergeRelicAndTarikhEvents(List<Event> events) {
    List<Event> eventsRelics = [];
    for (RELIC_TYPE relicType in RELIC_TYPE.values) {
      RelicSet relicSet = getRelicSet(relicType);
      for (Relic relic in relicSet.relics) {
        if (relic.isTimeLineEvent) events.add(relic);
        eventsRelics.add(relic);

        /// Add event reference 1 of 2: TODO this is a hack, access via map?
        relic.asset.event = relic; // can and must only do this once
      }
    }
    return eventsRelics;
  }

  void _initRelicSets() async {
    // No internet needed to init, but we put a back off just in case:
    await AuthC.to.waitForFirebaseLogin('RelicC._initRelics');

    /// perfect hash ajrLevel[RELIC_TYPE.index] = Map<relicId, int ajrLevel>
    final List<Map<int, int>> ajrLevels = [];

    // init relics and ajrLevels with empty Maps structures
    for (RELIC_TYPE relicType in RELIC_TYPE.values) {
      RelicSet relicSet = RelicSet(
        relicType: relicType,
        relics: await _initRelics(relicType),
      );
      _relicSets.add(relicSet);

      // init ajrLevels to be used in DB access
      Map<int, int> relicIdMap = {};
      for (int relicId = 0; relicId < relicSet.relics.length; relicId++) {
        relicIdMap[relicId] = 0; // set all relicId's for given RELIC_TYPE
      }
      ajrLevels.add(relicIdMap);
    }

    await Db.getRelicAjrLevels(ajrLevels); // merge DB ajrLevels into default 0

    // RelicSets.relics initialized and DB ajrLevels returned, set ajrLevels:
    for (RELIC_TYPE relicType in RELIC_TYPE.values) {
      int relicId = 0;
      for (Relic relic in _relicSets[relicType.index].relics) {
        relic.ajrLevel = ajrLevels[relicType.index][relicId++]!;
      }
    }

    // // Playground to find sort order data or dump defaults:
    // RelicSet relicSet = relics[RELIC_TYPE.Prophet]!;
    // int idx = 0;
    // print('********* RELIC INIT START *********');
    // for (Relic relic in relicSet.relics) {
    //   if ((relic as Prophet).isUluAlAzm() /* isRasul()) { */) {
    //     print(
    //         '$idx, // ${(relic as Prophet).quranMentionCount} ${relic.trKeyEndTagLabel}');
    //   }
    //   idx++;
    // }
    // print('********* RELIC INIT DONE *********');

    initNeeded = false; // Relic UIs can now initialize

    update(); // we better repaint for all those waiting UIs!
  }

  RelicSet getRelicSet(RELIC_TYPE relicType) => _relicSets[relicType.index];
//List<Relic> getRelics(RELIC_TYPE relicType) => _relicSets[relicType.index].relics;

  int getFilterIdx(RELIC_TYPE relicType) =>
      s.rd('filterIdx${relicType.index}') ?? 0;
  setFilterIdx(RELIC_TYPE relicType, int newVal) {
    s.wr('filterIdx${relicType.index}', newVal);
    updateOnThread1Ms(); // NOTE: Used to lock UI so used addPostFrameCallback()
  }

  int getTilesPerRow(RELIC_TYPE relicType, int relicSetFilterIdx) =>
      s.rd('tilesPerRow${relicType.index}_$relicSetFilterIdx') ??
      RelicSetFilter.DEFAULT_TPR;
  setTilesPerRow(RELIC_TYPE relicType, int relicSetFilterIdx, int newVal) {
    s.wr('tilesPerRow${relicType.index}_$relicSetFilterIdx', newVal);
    updateOnThread1Ms(); // update() worked, but this is safer.
  }

  bool getShowTileText(RELIC_TYPE relicType) =>
      s.rd('showTileText${relicType.index}') ?? true;
  setShowTileText(RELIC_TYPE relicType, bool newVal) {
    s.wr('showTileText${relicType.index}', newVal);
    updateOnThread1Ms();
  }

  int getSelectedTabIdx(RELIC_TAB relicTab) =>
      s.rd('selectedTabIdx${relicTab.index}') ?? 0;
  setLastSelectedTabIdx(RELIC_TAB relicTab, int newVal) {
    s.wr('selectedTabIdx${relicTab.index}', newVal);
    //updateOnThread1Ms(); <- not needed, called after UI changes are done
  }
}
