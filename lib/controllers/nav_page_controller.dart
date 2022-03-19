import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';

/// Controller to track a NavPages last selected SubPages. Used to persist UI
/// (e.g. bottom bar, lists of sub pages, etc.) last selected idx. Does this so
/// we can enable/disable settings icon and show/hide them on the Nav Menu among
/// other things to come with page swipe transitions.
class NavPageController extends GetxHapi {
  static NavPageController get to => Get.find();

  final Map<NavPage, int> pageIdxMap = {};

  // TODO not unique per user
  key(NavPage navPage) => navPage.name + '_lastIdx';

  @override
  onInit() {
    for (NavPageValue npv in navPageValues) {
      pageIdxMap[npv.navPage] = s.rd(key(npv.navPage)) ?? npv.defaultIdx;
    }
    super.onInit();
  }

  setLastIdx(navPage, newIdx) {
    pageIdxMap[navPage] = newIdx;
    s.wr(key(navPage), newIdx);
    //update(); // not needed right now
  }

  int getLastIdx(navPage) => pageIdxMap[navPage]!;

//get isLastIdxQuestHapi => getLastIdx(NavPage.Quests) == Quests.hapi.index;
//get isLastIdxQuestTime => getLastIdx(NavPage.Quests) == Quests.Time.index;
//get isLastIdxQuestDaily => getLastIdx(NavPage.Quests) == Quests.Daily.index;
//get isLastIdxQuestActive => getLastIdx(NavPage.Quests) == Quests.Active.index;
}
