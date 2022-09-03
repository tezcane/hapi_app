import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';
import 'package:hapi/relic/relics_favorites_ui.dart';
import 'package:hapi/relic/relics_search_ui.dart';

enum RELIC_TAB {
  Favorites,
  Search,
  Universities,
  Relics, // a.Alathar
  Mosques,
  Anbia,
  Asma_ul_Husna,
}

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class RelicsUI extends StatelessWidget {
  const RelicsUI();
  static const navPage = NavPage.Relics;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (c) {
      // do here to save memory:
      final List<BottomBarItem> bottomBarItems = [
        BottomBarItem(
          const RelicsFavoritesUI(),
          null,
          'i.Favorites'.tr,
          at('at.{0} Favorites'.tr, [navPage.trKey]),
          Icons.favorite_border_outlined,
          Colors.pinkAccent,
        ),
        BottomBarItem(
          const RelicsSearchUI(),
          null,
          'i.Search'.tr,
          at('at.{0} Search'.tr, [navPage.trKey]),
          Icons.search_outlined,
          AppThemes.logoText,
        ),
        BottomBarItem(
          T('i.Coming Soon', tsB),
          null,
          'i.Universities'.tr,
          'i.Famous Muslim Universities'.tr,
          Icons.school_outlined,
          AppThemes.ajr1Common,
        ),
        BottomBarItem(
          T('i.Coming Soon', tsB),
          null,
          'a.Alathar'.tr,
          'i.Religious relics and locations'.tr,
          Icons.wine_bar_sharp,
          AppThemes.ajr2Uncommon
        ),
        BottomBarItem(
          T('i.Coming Soon', tsB),
          null,
          'i.Mosques'.tr,
          'i.Famous mosques'.tr,
          Icons.mosque_outlined,
          AppThemes.ajr3Rare,
        ),
        BottomBarItem(
          Container(),
          null,
          a('a.Anbia'),
          '       '+'i.Prophets mentioned in the Quran'.tr+'              ',
          Icons.connect_without_contact_outlined,
            AppThemes.ajr4Epic,
        ),
        BottomBarItem(
          T('i.Coming Soon', tsB),
          null,
          a('i.Asma-ul-Husna'),
          '       '+at('at.99 names of {0} {1}', ['a.Allah', 'a.SWT'])+'              ',
          Icons.apps_outlined,
          AppThemes.ajr5Legendary,
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
  }
}
