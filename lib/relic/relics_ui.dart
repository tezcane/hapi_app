import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/relic/relic_tab_bar.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/favorite/event_favorite_ui.dart';
import 'package:hapi/tarikh/event/search/event_search_ui.dart';

enum RELIC_TAB {
  Favorites,
  Search,
  Relics, // a.Alathar
  Places,
  Delil,
  Ummah,
  Allah, //Asma_ul_Husna,
}

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class RelicsUI extends StatelessWidget {
  const RelicsUI();

  static const navPage = NavPage.Relics;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageC>(builder: (c) {
      // do here to save memory:
      final List<BottomBarItem> bottomBarItems = [
        BottomBarItem(
          const EventFavoriteUI(EVENT.Nabi, navPage),
          null,
          'Favorites'.tr,
          at('at.{0} Favorites', [navPage.tk]),
          Icons.favorite_border_outlined,
          onPressed: hideKeyboard, // in case search is showing keyboard
        ),
        BottomBarItem(
          const EventSearchUI(navPage),
          null,
          'Search'.tr,
          at('at.{0} Search', [navPage.tk]),
          Icons.search_outlined,
        ),
        BottomBarItem(
          Center(child: T('Coming Soon', tsN, h: 50)),
          null,
          'a.Alathar'.tr, // Relics
          'Islamic relics'.tr,
          Icons.brightness_3_outlined, // Icons.wine_bar_sharp
          onPressed: hideKeyboard,
        ),
        BottomBarItem(
          Center(child: T('Coming Soon', tsN, h: 50)),
          null,
          'Places'.tr,
          'Famous Muslim Places'.tr,
          Icons.map_outlined, // TODO Icons.mosque_outlined/.school_outlined
          onPressed: hideKeyboard,
        ),
        BottomBarItem(
          Center(child: T('Coming Soon', tsN, h: 50)),
          null,
          'a.Delil'.tr,
          'Proofs of Islam'.tr,
          Icons.auto_stories,
          onPressed: hideKeyboard,
        ),
        BottomBarItem(
          const RelicTabBar(
            relicTab: RELIC_TAB.Ummah,
            eventTypes: [
              EVENT.Nabi,
              EVENT.Surah,
            ],
          ),
          null,
          a('a.Ummah'),
          '              ' + 'Remarkable Muslims'.tr + '              ',
          Icons.connect_without_contact_outlined,
          onPressed: hideKeyboard,
        ),
        BottomBarItem(
          const Center(child: T('Coming Soon', tsN, h: 50)),
          null,
          a('a.Allah'), //a('Asma-ul-Husna'),
          '              ' +
              at('at.About {0} {1}', ['a.Allah', 'a.SWT']) +
              '              ',
          Icons.apps_outlined,
          onPressed: hideKeyboard,
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

  hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');
}
