import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_set.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/relic/ummah/prophet.dart';
import 'package:hapi/services/db.dart';

class RelicController extends GetxHapi {
  static RelicController get to => Get.find();

  /// perfect hash map[int RELIC_ID.index] = int ajrLevel (init with 0's)
  final List<int> ajrLevels = List.filled(RELIC_ID.values.length, 0);
  final Map<RELIC_TYPE, RelicSet> relics = {};

  bool isNotInitialized = true;

  @override
  void onInit() {
    _initRelics();
    super.onInit();
  }

  void _initRelics() async {
    // No internet needed to init, but we put a back off just in case:
    await AuthController.to.waitForFirebaseLogin('RelicController._initRelics');

    await Db.getRelicAjrLevels(ajrLevels); // updates ajrLevel

    // must have ajrLevels initialized before calling initProphets(), etc.
    relics[RELIC_TYPE.Prophet] = RelicSet(
      relicType: RELIC_TYPE.Prophet,
      trKeyTitle: 'a.Anbiya',
      // TODO drop down other filters here:
      trValSubtitle: '_i.mentioned in the_'.tr + ('a.Quran'),
      relics: await initProphets(),
    );

    isNotInitialized = false; // Relic UIs can now initialize

    update(); // we better repaint for all those waiting UIs!
  }

  RelicSet getRelicSet(RELIC_TYPE relicType) => relics[relicType]!;
  List<Relic> getRelics(RELIC_TYPE relicType) =>
      relics[relicType]!.relics as List<Relic>;

  // int getTilesPerRow(RELIC_TYPE relicType) {
  //   s.wr('tilesPerRow${relicType.index}', 4);
  //   return s.rd('tilesPerRow${relicType.index}') ?? 4; // 4 is default for all
  // }
  int getTilesPerRow(RELIC_TYPE relicType) =>
      s.rd('tilesPerRow${relicType.index}') ?? 4; // 4 is default for all relics
  setTilesPerRow(RELIC_TYPE relicType, int newVal) {
    s.wr('tilesPerRow${relicType.index}', newVal);
    update();
  }

  // toggleShowTileHeader(RELIC_TYPE relicType) {
  //   s.wr('showTileHeader${relicType.index}', true);
  //   setShowTileHeader(relicType, !getShowTileHeader(relicType));
  // }
  toggleShowTileHeader(RELIC_TYPE relicType) =>
      _setShowTileHeader(relicType, !getShowTileHeader(relicType));
  bool getShowTileHeader(RELIC_TYPE relicType) =>
      s.rd('showTileHeader${relicType.index}') ?? true;
  _setShowTileHeader(RELIC_TYPE relicType, bool newVal) {
    s.wr('showTileHeader${relicType.index}', newVal);
    updateOnThread1Ms();
  }

  int getLastSelectedTab(RELIC_TAB relicTab) =>
      s.rd('selectedTab${relicTab.index}') ?? 0;
  setLastSelectedTab(RELIC_TAB relicTab, int newVal) {
    s.wr('selectedTab${relicTab.index}', newVal);
    //update();
  }
}
