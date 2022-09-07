import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_tab_bar.dart';
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
      trKeyTitle: 'a.Al-Anbiya',
      relics: await initProphets(),
    );

    isNotInitialized = false; // Relic UIs can now initialize

    update(); // we better repaint for all those waiting UIs!
  }

  RelicSet getRelicSet(RELIC_TYPE relicType) => relics[relicType]!;
  List<Relic> getRelics(RELIC_TYPE relicType) =>
      relics[relicType]!.relics as List<Relic>;
}
