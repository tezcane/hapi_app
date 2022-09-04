import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/relic/relics_favorites_ui.dart';
import 'package:hapi/relic/relics_search_ui.dart';
import 'package:hapi/relic/ummah/ummah_ui.dart';

enum RELIC_TAB {
  Favorites,
  Search,
  Relics, // a.Alathar
  Places,
  Deleel,
  Ummah,
  Allah, //Asma_ul_Husna,
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
          AppThemes.ajr0Missed,
        ),
        BottomBarItem(
          const RelicsSearchUI(),
          null,
          'i.Search'.tr,
          at('at.{0} Search'.tr, [navPage.trKey]),
          Icons.search_outlined,
          AppThemes.ajr1Common,
        ),
        BottomBarItem(
          Center(child: T('i.Coming Soon', tsN, h: 50)),
          null,
          'a.Alathar'.tr, // Relics
          'i.Islamic relics'.tr,
          Icons.brightness_3_outlined, // Icons.wine_bar_sharp
          AppThemes.ajr2Uncommon,
        ),
        BottomBarItem(
          Center(child: T('i.Coming Soon', tsN, h: 50)),
          null,
          'i.Places'.tr,
          'i.Famous Muslim Places'.tr,
          Icons.map_outlined, // TODO Icons.mosque_outlined/.school_outlined
          AppThemes.ajr3Rare,
        ),
        BottomBarItem(
          Center(child: T('i.Coming Soon', tsN, h: 50)),
          null,
          'a.Deleel'.tr,
          'i.Proofs of Islam'.tr,
          Icons.auto_stories,
          AppThemes.ajr4Epic,
        ),
        BottomBarItem(
          const UmmahUI(trKeyTitle: 'a.Ummah'),
          null,
          a('a.Ummah'),
          '              ' + 'i.Well known Muslims'.tr + '              ',
          Icons.connect_without_contact_outlined,
          AppThemes.ajr5Legendary,
        ),
        BottomBarItem(
          const Center(child: T('i.Coming Soon', tsN, h: 50)),
          null,
          a('a.Allah'), //a('i.Asma-ul-Husna'),
          '              ' +
              at('at.About {0} {1}', ['a.Allah', 'a.SWT']) +
              '              ',
          Icons.apps_outlined,
          AppThemes.ajr6Mythic,
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
