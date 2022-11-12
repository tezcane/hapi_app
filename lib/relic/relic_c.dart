import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/et_extension.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_asset.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/service/db.dart';

class RelicC extends GetxHapi {
  static RelicC get to => Get.find();

  /// Access via _relicSets[ET]
  /// Note: Can be a perfect hash too but relicSetFilter init complicates this.
  final Map<ET, RelicSet> _relicSets = {};

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

      RelicSet relicSet = getRelicSet(et);

      /// we manually set relic assets here, done here to make relic objects
      /// closer to const (future upgrade?).
      for (Relic relic in relicSet.relics) {
        relic.asset = await getEventAsset(relic.getAsset());
      }

      // init ajrLevels to be used in DB access
      Map<int, int> relicIdMap = {};
      for (int relicId = 0; relicId < relicSet.relics.length; relicId++) {
        relicIdMap[relicId] = 0; // set all relicId's for given EVENT_TYPE
      }
      _ajrLevels.add(relicIdMap); // call DB to merge ajrLevels with this next
    }

    // // Playground to find sort order data or dump defaults:
    // String output = '';
    // for (int i = 0; i < 114; i++) output += ', $i';
    // print(output);
    //
    // RelicSet relicSet = getRelicSet(ET.Nabi);
    // int idx = 0;
    // for (Relic relic in relicSet.relics) {
    //   if (!(relic as Nabi).isRasul()) {
    //     print('AS.${relic.e.name}.index, ');
    //   }
    //   idx++;
    // }

    // RelicSet relicSet = getRelicSet(ET.Asma_ul__Husna);
    // int idx = 0;
    // String output = '';
    // List<AsmaUlHusna> auhs = [];
    // for (Relic relic in relicSet.relics) {
    //   AsmaUlHusna auh = relic as AsmaUlHusna;
    //   auhs.add(auh);
    //   // for (GT gt in auh.gts) {
    //   //   if (gt == GT.Not_In_Quran) {
    //   //     output += 'AUH.${auh.e.name}.index, ';
    //   //   }
    //   // }
    //   // print(relic.e.tkIsimA);
    //   idx++;
    // }
    // auhs.sort((a, b) => a.quranMentionCount.compareTo(b.quranMentionCount));
    // for (AsmaUlHusna auh in auhs.reversed) {
    //   output += 'AUH.${auh.e.name}.index, ';
    //   if (output.length > 1000) {
    //     print(output);
    //     output = ''; // max char print limit protection, flushed out
    //   }
    // }
    // print(output);

    // RelicSet relicSet = getRelicSet(ET.Surah);
    // int idx = 0;
    // String output = '';
    // List<Surah> rels = [];
    // for (Relic relic in relicSet.relics) {
    //   Surah rel = relic as Surah;
    //   rels.add(rel);
    //   if (rel.isMuqattaat) {
    //     output += 'S.${rel.e.name}.index, ';
    //     if (output.length > 1000) {
    //       print(output);
    //       output = ''; // max char print limit protection, flushed out
    //     }
    //   }
    //   idx++;
    // }
    // print(output);
    //
    // // rels.sort((a, b) => a.cntRuku.compareTo(b.cntRuku));
    // // for (Surah rel in rels.reversed) {
    // //   output += 'S.${rel.e.name}.index, ';
    // //   if (output.length > 1000) {
    // //     print(output);
    // //     output = ''; // max char print limit protection, flushed out
    // //   }
    // // }
    // // print(output);

    l.d('********* RELIC INIT DONE *********');
  }

  RelicSet getRelicSet(ET et) {
    // if not in _relicSets yet, add it now
    if (!_relicSets.containsKey(et)) _relicSets[et] = RelicSet(et);
    return _relicSets[et]!;
  }

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
