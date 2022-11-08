import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/favorite/event_favorite_ui.dart';
import 'package:hapi/event/search/event_search_ui.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/relic/relic_tab_bar.dart';

/// TODO this is needed in another class, should it be?
enum RELIC_TAB {
  Al__Asma__, // Names
  Islam,
  Akadimi, // Academic
  Ummah,
  Mamlaka, // Dynasties/Kingdoms
  // Search, TODO arabee translate these
  // Favorites,
}

/// Init all of this NavPage's main widgets and bottom bar
class RelicsUI extends StatelessWidget {
  const RelicsUI();

  @override
  Widget build(BuildContext context) {
    List<Widget?> settingsWidgets = [];
    List<Widget> aliveMainWidgets = [];
    for (BottomBarItem bottomBarItem in _bottomBarItems) {
      settingsWidgets.add(bottomBarItem.settingsWidget);
      aliveMainWidgets.add(bottomBarItem.aliveMainWidget);
    }

    return MenuRightUI(
      navPage: _navPage,
      settingsWidgets: settingsWidgets,
      foregroundPage: BottomBarMenu(
        _navPage,
        _bottomBarItems,
        aliveMainWidgets,
      ),
    );
  }
}

const _navPage = NavPage.Alathar;

const List<BottomBarItem> _bottomBarItems = [
  BottomBarItem(
    // Center(child: T('Coming Soon', tsN, h: 50)),
    RelicTabBar(
      relicTab: RELIC_TAB.Islam,
      etList: [ET.Delil, ET.Al__Aqida],
    ),
    null,
    'a.Islam',
    'About Islam',
    Icons.brightness_3_outlined,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    RelicTabBar(
      relicTab: RELIC_TAB.Al__Asma__,
      etList: [ET.Asma_ul__Husna, ET.Nabi],
    ),
    null,
    "a.Al'Asma'",
    'Big Names',
    Icons.apps_outlined,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    RelicTabBar(
      relicTab: RELIC_TAB.Akadimi,
      etList: [ET.Surah],
    ),
    null,
    'a.Akadimi',
    'Academic Knowledge',
    Icons.auto_stories,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    RelicTabBar(
      relicTab: RELIC_TAB.Ummah,
      etList: [ET.Makan],
    ),
    null,
    'a.Ummah',
    'Muslim Things',
    Icons.mosque_outlined, //connect_without_contact_outlined/wine_bar_sharp
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    RelicTabBar(
      relicTab: RELIC_TAB.Mamlaka,
      etList: [ET.Rasulallah],
    ),
    null,
    'a.Mamlaka', // Relics
    'Large Muslim Dynasties',
    Icons.map_outlined, // TODO Icons.school_outlined
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    EventSearchUI(_navPage),
    null,
    'a.Search', // TODO
    'Alathar Search',
    Icons.search_outlined,
  ),
  BottomBarItem(
    EventFavoriteUI(ET.Nabi, _navPage),
    null,
    'a.Favorites', // TODO
    'Alathar Favorites',
    Icons.favorite_border_outlined,
    onPressed: _hideKeyboard, // in case search is showing keyboard
  ),
];

_hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');
