import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_search_ui.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';

enum TARIKH_TAB {
  Favorites,
  Search,
  Menu,
}

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class TarikhUI extends StatelessWidget {
  const TarikhUI();
  static const navPage = NavPage.Tarikh;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (c) {
      return GetBuilder<TarikhController>(builder: (tc) {
        List<BottomBarItem> bbItems = [
          BottomBarItem(
            const TarikhFavoritesUI(),
            null,
            'i.Favorites'.tr,
            at('at.{0} Favorites'.tr, [navPage.trKey]),
            Icons.favorite_border_outlined,
            Colors.pinkAccent, //const Color(0xFFF1AC44),
            onPressed: setTarikhMenuInactive,
          ),
          BottomBarItem(
            const TarikhSearchUI(),
            null,
            'i.Search'.tr,
            at('at.{0} Search'.tr, [navPage.trKey]),
            Icons.search_outlined,
            Colors.greenAccent.shade700, //.orange,
            onPressed: setTarikhMenuInactive,
          ),
          BottomBarItem(
            const TarikhMenuUI(),
            null,
            'i.Menu'.tr,
            '                 ' +
                at('at.{0} Menu'.tr, [navPage.trKey]) +
                '                 ', // FAB padding
            Icons.menu_open_rounded,
            Colors.blue,
            onPressed: setTarikhMenuActive,
          ),
        ];

        List<BottomBarItem> bottomBarItems = bbItems;
        if (c.isRTL) {
          bottomBarItems = List<BottomBarItem>.from(bbItems.reversed);
        }

        final List<Widget> mainWidgets = [
          bottomBarItems[0].aliveMainWidget,
          bottomBarItems[1].aliveMainWidget,
          bottomBarItems[2].aliveMainWidget,
        ];

        final List<Widget?> settingsWidgets = [
          bottomBarItems[0].settingsWidget,
          bottomBarItems[1].settingsWidget,
          bottomBarItems[2].settingsWidget,
        ];

        return FabNavPage(
          navPage: navPage,
          settingsWidgets: settingsWidgets,
          bottomWidget: HapiShareUI(),
          foregroundPage: BottomBarMenu(navPage, bottomBarItems, mainWidgets),
        );
      });
    });
  }

  setTarikhMenuInactive() => TarikhController.to.isActiveTarikhMenu = false;
  setTarikhMenuActive() => TarikhController.to.isActiveTarikhMenu = true;
}
