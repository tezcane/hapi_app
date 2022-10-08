import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/tarikh/event/et.dart';
import 'package:hapi/tarikh/event/favorite/event_favorite_ui.dart';
import 'package:hapi/tarikh/event/search/event_search_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

enum HADITH_TAB {
  Favorites,
  Search,
  Menu, // TODO
}

class HadithUI extends StatelessWidget {
  const HadithUI();
  static const navPage = NavPage.Hadith;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageC>(builder: (c) {
      // need for when timeline finally loads at init, add timeline data to UI:
      return GetBuilder<TarikhC>(builder: (tc) {
        // do here to save memory:
        final List<BottomBarItem> bottomBarItems = [
          BottomBarItem(
            const EventFavoriteUI(ET.Tarikh, navPage),
            null,
            'Favorites'.tr,
            at('at.{0} Favorites', [navPage.tkIsimA]),
            Icons.favorite_border_outlined,
            onPressed: setTarikhMenuInactive,
          ),
          BottomBarItem(
            const EventSearchUI(navPage),
            null,
            'Search'.tr,
            at('at.{0} Search', [navPage.tkIsimA]),
            Icons.search_outlined,
            onPressed: setTarikhMenuInactive,
          ),
          BottomBarItem(
            const TarikhMenuUI(),
            null,
            'Menu'.tr,
            '                 ' +
                at('at.{0} Menu', [navPage.tkIsimA]) +
                '                 ', // FAB padding
            Icons.menu_open_rounded,
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

  hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');

  setTarikhMenuInactive() {
    TarikhC.to.isActiveTarikhMenu = false;
    hideKeyboard();
  }

  setTarikhMenuActive() {
    TarikhC.to.isActiveTarikhMenu = true;
    hideKeyboard();
  }
}
