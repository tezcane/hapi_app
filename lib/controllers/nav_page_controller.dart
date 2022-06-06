import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';

/// Controller to track a NavPages last selected SubPages. Used to persist UI
/// (e.g. bottom bar, lists of sub pages, etc.) last selected idx. Does this so
/// we can enable/disable settings icon and show/hide them on the Nav Menu among
/// other things to come with page swipe transitions.
///
/// Note: Originally stored idx of the bottom bar/NavPage tab, but when you
/// swap LTR/RTL languages this index is no longer valid.  Thus, now uses the
/// Tab enum's name to do the index switching.
class NavPageController extends GetxHapi {
  static NavPageController get to => Get.find();

  final Map<NavPage, String> pageIdxMap = {};

  key(NavPage navPage) => navPage.name + '_lastIdx';

  @override
  onInit() {
    for (NPV npv in navPageValues) {
      pageIdxMap[npv.navPage] = s.rd(key(npv.navPage)) ?? npv.initTabName;
    }
    super.onInit();
  }

  setLastIdx(NavPage navPage, int newIdx) {
    pageIdxMap[navPage] = getEnumName(navPage.tabEnumList, newIdx);
    s.wr(key(navPage), pageIdxMap[navPage]);
    update(); // needed to show bottom bar UI animation and tab selection
  }

  int getLastIdx(NavPage navPage) {
    List<dynamic> tabEnumList = navPage.tabEnumList;

    for (int idx = tabEnumList.length - 1; idx >= 0; idx--) {
      if (getEnumName(tabEnumList, idx) == pageIdxMap[navPage]!) return idx;
    }
    return l.E('tabEnumList "$tabEnumList" missing ${pageIdxMap[navPage]!}');
  }

  String getLastIdxName(NavPage navPage) => pageIdxMap[navPage]!;
  // setLastIdxName(NavPage navPage, String newIdxName) =>
  //     pageIdxMap[navPage] = newIdxName;

  /// When enum is in List<dynamic>, enum.name not accessible, so use old way:
  String getEnumName(eList, int idx) => eList[idx].toString().split('.')[1];
}
