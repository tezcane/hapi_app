import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
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
      // need for when timeline finally loads at init, add timeline data to UI:
      return GetBuilder<TarikhController>(builder: (tc) {
        // do here to save memory:
        final List<BottomBarItem> bottomBarItems = [
          BottomBarItem(
            const TarikhFavoritesUI(),
            null,
            'i.Favorites'.tr,
            at('at.{0} Favorites'.tr, [navPage.trKey]),
            Icons.favorite_border_outlined,
            AppThemes.ajr0Missed,
            onPressed: setTarikhMenuInactive,
          ),
          BottomBarItem(
            const TarikhSearchUI(),
            null,
            'i.Search'.tr,
            at('at.{0} Search'.tr, [navPage.trKey]),
            Icons.search_outlined,
            AppThemes.ajr1Common,
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
            AppThemes.ajr6Mythic,
            onPressed: setTarikhMenuActive,
          ),
        ];

        final List<BottomBarItem> bbItems = c.isLTR
            ? bottomBarItems
            : List<BottomBarItem>.from(bottomBarItems.reversed);

        List<Widget> mainWidgets = [];
        List<Widget?> settingsWidgets = [];
        for (int idx = 0; idx < bottomBarItems.length; idx++) {
          mainWidgets.add(bbItems[idx].aliveMainWidget);
          settingsWidgets.add(bbItems[idx].settingsWidget);
        }

        return MenuRightUI(
          navPage: navPage,
          settingsWidgets: settingsWidgets,
          foregroundPage: BottomBarMenu(navPage, bbItems, mainWidgets),
        );
      });
    });
  }

  setTarikhMenuInactive() => TarikhController.to.isActiveTarikhMenu = false;
  setTarikhMenuActive() => TarikhController.to.isActiveTarikhMenu = true;
}
