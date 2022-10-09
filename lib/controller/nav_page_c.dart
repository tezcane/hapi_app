import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

/// Controller to track a NavPages last selected SubPages. Used to persist UI
/// (e.g. bottom bar, lists of sub pages, etc.) last selected idx. Does this so
/// we can enable/disable settings icon and show/hide them on the Nav Menu among
/// other things to come with page swipe transitions.
class NavPageC extends GetxHapi {
  static NavPageC get to => Get.find();

  final Map<NavPage, int> pageIdxMap = {};

  _key(NavPage navPage) => navPage.name + '_lastIdx';

  @override
  onInit() {
    for (NPV npv in navPageValues) {
      pageIdxMap[npv.navPage] = s.rd(_key(npv.navPage)) ?? 0;
    }
    super.onInit();
  }

  setLastIdx(NavPage navPage, int newIdx) {
    pageIdxMap[navPage] = newIdx;
    s.wr(_key(navPage), newIdx);
    update(); // needed to show bottom bar UI animation and tab selection
  }

  int getLastIdx(NavPage navPage) => pageIdxMap[navPage] ?? 0;
}
