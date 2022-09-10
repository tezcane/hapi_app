import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/relic/ummah/prophet.dart' as prophets;
import 'package:hapi/service/db.dart';

class RelicC extends GetxHapi {
  static RelicC get to => Get.find();

  /// perfect hash map[int RELIC_ID.index] = int ajrLevel (init with 0's)
  final List<int> ajrLevels = List.filled(RELIC_ID.values.length, 0);
  final Map<RELIC_TYPE, RelicSet> relics = {};

  bool initNeeded = true;

  @override
  void onInit() {
    _initRelics();
    super.onInit();
  }

  void _initRelics() async {
    // No internet needed to init, but we put a back off just in case:
    await AuthC.to.waitForFirebaseLogin('RelicC._initRelics');

    await Db.getRelicAjrLevels(ajrLevels); // updates ajrLevel

    // must have ajrLevels initialized before calling initProphets(), etc.
    relics[RELIC_TYPE.Prophet] = RelicSet(
      relicType: RELIC_TYPE.Prophet,
      relics: await prophets.init(),
    );

    // // Playground to find sort order data or dump defaults:
    // RelicSet relicSet = relics[RELIC_TYPE.Prophet]!;
    // int idx = 0;
    // for (Relic relic in relicSet.relics) {
    //   print('$idx, // ${(relic as Prophet).quranMentionCount} ${relic.trKeyEndTagLabel}');
    //   idx++;
    // }

    initNeeded = false; // Relic UIs can now initialize

    update(); // we better repaint for all those waiting UIs!
  }

  RelicSet getRelicSet(RELIC_TYPE relicType) => relics[relicType]!;
  List<Relic> getRelics(RELIC_TYPE relicType) => relics[relicType]!.relics;

  int getFilterIdx(RELIC_TYPE relicType) =>
      s.rd('filterIdx${relicType.index}') ?? 0;
  setFilterIdx(RELIC_TYPE relicType, int newVal) {
    s.wr('filterIdx${relicType.index}', newVal);
    //updateOnThread1Ms(); // <-can't do or UI loops continuously
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
