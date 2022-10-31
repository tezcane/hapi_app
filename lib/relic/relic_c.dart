import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/service/db.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/et_extension.dart';
import 'package:hapi/event/event.dart';

class RelicC extends GetxHapi {
  static RelicC get to => Get.find();

  /// Perfect hash, access via _relicSets[ET.index]
  final List<RelicSet> _relicSets = [];

  /// Perfect hash, access via _ajrLevels[ET.index]=Map<relicId, int ajrLevel>
  final List<Map<int, int>> _ajrLevels = [];

  /// needed by relic tab bar
  bool initNeeded = true;

  @override
  void onInit() {
    _initAllRelicData();
    super.onInit();
  }

  /// Merge relic events with a time into tarikh events so they show Timeline
  /// and return all relic events in another list which is needed for further
  /// app init.
  ///
  /// Note: TarikhC calls this while Relic's are still initializing so we must
  /// spin wait for Relic's to initialize so TarikhC can get Relic events.
  Future<List<Event>> mergeRelicAndTarikhEvents(List<Event> trkhEvents) async {
    if (initNeeded) {
      int sleepBackoffMs = 250;
      // No internet needed if already initialized
      while (initNeeded) {
        l.d('mergeRelicAndTarikhEvents: Relics not ready, try again after sleeping $sleepBackoffMs ms...');
        await Future.delayed(Duration(milliseconds: sleepBackoffMs));
        if (sleepBackoffMs < 1000) sleepBackoffMs += 250;
      }
    }

    List<Event> relicEvents = [];
    for (ET et in ET.values) {
      if (!et.isRelic) continue; // skip Tarikh events

      for (Relic relic in getRelicSet(et).relics) {
        if (relic.isTimeLineEvent) trkhEvents.add(relic); // add if has date

        relicEvents.add(relic);

        /// Add event reference 1 of 2: TODO this is a hack, access via map?
        relic.asset.event = relic; // can and must only do this once
      }
    }
    return relicEvents;
  }

  _initAllRelicData() async {
    // No internet needed to init, but we put a back off just in case:
    await AuthC.to.waitForFirebaseLogin('RelicC._initRelics');

    await _initRelicSets();

    /// merge DB ajrLevels into default 0 values that (already added _ajrLevels)
    await Db.getRelicAjrLevels(_ajrLevels);

    initNeeded = false; // Relic UI/Tarikh init can now initialize

    update(); // we better repaint for all those waiting UIs!
  }

  _initRelicSets() async {
    // init relics and ajrLevels with empty Maps structures
    for (ET et in ET.values) {
      if (!et.isRelic) continue; // skip Tarikh events

      List<Relic> relics = et.initRelics();

      /// we manually set relic assets here, done here to make relic objects
      /// closer to const (future upgrade?).
      for (Relic relic in relics) {
        relic.asset = await relic.getRelicAsset().toImageEventAsset();
      }

      RelicSet relicSet = RelicSet(
        et: et,
        relics: relics,
        tkTitle: et.tkRelicSetTitle,
      );
      _relicSets.add(relicSet); // must come before next line
      relicSet.filterList = et.initRelicSetFilters();

      // init ajrLevels to be used in DB access
      Map<int, int> relicIdMap = {};
      for (int relicId = 0; relicId < relicSet.relics.length; relicId++) {
        relicIdMap[relicId] = 0; // set all relicId's for given RELIC_TYPE
      }
      _ajrLevels.add(relicIdMap); // call DB to merge ajrLevels with this next
    }

    // // Playground to find sort order data or dump defaults:
    // RelicSet relicSet = relics[RELIC_TYPE.Prophet]!;
    // int idx = 0;
    // print('********* RELIC INIT START *********');
    // for (Relic relic in relicSet.relics) {
    //   if ((relic as Prophet).isUluAlAzm() /* isRasul()) { */) {
    //     print(
    //         '$idx, // ${(relic as Prophet).quranMentionCount} ${relic.tkEndTagLabel}');
    //   }
    //   idx++;
    // }
    // print('********* RELIC INIT DONE *********');
  }

  RelicSet getRelicSet(ET et) => _relicSets[et.index];

  int getAjrLevel(ET et, int relicId) => _ajrLevels[et.index][relicId]!;

  /// To get the EventUI() UI working, with least amount of pain, we turn our
  /// relic structures into a Map<String, Event> that Tarikh code are already
  /// using. This way we can reuse lots of logic and maps are efficient anyway.
  ///
  /// This is also used by Relic's Favorites and Search UI's to be able to jump
  /// to the Relics Details view.
  Map<String, Event> getEventMap(ET et, int filterIdx) {
    RelicSet relicSet = RelicC.to.getRelicSet(et);

    // The up/dn buttons, by design will navigate through the idxList values
    // only, this may or may not be all relics of this et.
    List<int> idxList = relicSet.filterList[filterIdx].idxList;

    // Create the map to be used for up/dn buttons
    Map<String, Event> eventMap = {};
    Event? prevEvent; // start null, parent/first event has no previous event
    for (int idx = 0; idx < idxList.length; idx++) {
      Event event = relicSet.relics[idxList[idx]];
      event.previous = prevEvent;

      if (idx == idxList.length - 1) {
        event.next = null; // last idx
      } else {
        event.next = relicSet.relics[idxList[idx + 1]];
      }

      prevEvent = event; // prev event is this current event
      eventMap[event.saveTag] = event;
    }

    return eventMap;
  }

  int getFilterIdx(ET et) => s.rd('filterIdx${et.index}') ?? 0;
  setFilterIdx(ET et, int newVal) {
    s.wr('filterIdx${et.index}', newVal);
    updateOnThread1Ms(); // NOTE: Used to lock UI so used addPostFrameCallback()
  }

  int getTilesPerRow(ET et, int relicSetFilterIdx) =>
      s.rd('tilesPerRow${et.index}_$relicSetFilterIdx') ??
      RelicSetFilter.DEFAULT_TPR;
  setTilesPerRow(ET et, int relicSetFilterIdx, int newVal) {
    s.wr('tilesPerRow${et.index}_$relicSetFilterIdx', newVal);
    updateOnThread1Ms(); // update() worked, but this is safer.
  }

  bool getShowTileText(ET et) => s.rd('showTileText${et.index}') ?? true;
  setShowTileText(ET et, bool newVal) {
    s.wr('showTileText${et.index}', newVal);
    updateOnThread1Ms();
  }

  int getSelectedTabIdx(RELIC_TAB relicTab) =>
      s.rd('selectedTabIdx${relicTab.index}') ?? 0;
  setLastSelectedTabIdx(RELIC_TAB relicTab, int newVal) {
    s.wr('selectedTabIdx${relicTab.index}', newVal);
    //updateOnThread1Ms(); <- not needed, called after UI changes are done
  }
}
