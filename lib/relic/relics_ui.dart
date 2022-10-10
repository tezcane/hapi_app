import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/relic/relic_tab_bar.dart';
import 'package:hapi/tarikh/event/et.dart';
import 'package:hapi/tarikh/event/favorite/event_favorite_ui.dart';
import 'package:hapi/tarikh/event/search/event_search_ui.dart';

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
    Center(child: T('Coming Soon', tsN, h: 50)),
    null,
    'a.Allah',
    'About Allah SWT',
    Icons.apps_outlined,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    RelicTabBar(
      relicTab: RELIC_TAB.Ummah,
      etList: [ET.Nabi, ET.Surah],
    ),
    null,
    'a.Ummah',
    'Remarkable Muslims',
    Icons.connect_without_contact_outlined,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    Center(child: T('Coming Soon', tsN, h: 50)),
    null,
    'a.Delil',
    'Proofs of Islam',
    Icons.auto_stories,
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    Center(child: T('Coming Soon', tsN, h: 50)),
    null,
    'Places',
    'Famous Muslim Places',
    Icons.map_outlined, // TODO Icons.mosque_outlined/.school_outlined
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    Center(child: T('Coming Soon', tsN, h: 50)),
    null,
    'a.Alathar', // Relics
    'Islamic relics',
    Icons.brightness_3_outlined, // Icons.wine_bar_sharp
    onPressed: _hideKeyboard,
  ),
  BottomBarItem(
    EventSearchUI(_navPage),
    null,
    'Search',
    'Alathar Search',
    Icons.search_outlined,
  ),
  BottomBarItem(
    EventFavoriteUI(ET.Nabi, _navPage),
    null,
    'Favorites',
    'Alathar Favorites',
    Icons.favorite_border_outlined,
    onPressed: _hideKeyboard, // in case search is showing keyboard
  ),
];

_hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');
