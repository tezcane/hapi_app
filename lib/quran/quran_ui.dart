import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/favorite/event_favorite_ui.dart';
import 'package:hapi/event/search/event_search_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

/// Init all of this NavPage's main widgets and bottom bar
class QuranUI extends StatelessWidget {
  const QuranUI();

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

const _navPage = NavPage.Quran;

const List<BottomBarItem> _bottomBarItems = [
  BottomBarItem(
    TarikhMenuUI(),
    null,
    'Menu',
    'Quran Menu',
    Icons.menu_open_rounded,
    onPressed: _setTarikhMenuActive,
  ),
  BottomBarItem(
    EventSearchUI(_navPage),
    null,
    'Search',
    'Quran Search',
    Icons.search_outlined,
    onPressed: _setTarikhMenuInactive,
  ),
  BottomBarItem(
    EventFavoriteUI(ET.Tarikh, _navPage),
    null,
    'Favorites',
    'Quran Favorites',
    Icons.favorite_border_outlined,
    onPressed: _setTarikhMenuInactive,
  ),
];

_setTarikhMenuInactive() {
  TarikhC.to.isActiveTarikhMenu = false;
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

_setTarikhMenuActive() {
  TarikhC.to.isActiveTarikhMenu = true;
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}
