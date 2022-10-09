import 'package:flutter/material.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class QuestsUI extends StatelessWidget {
  const QuestsUI();

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

const NavPage _navPage = NavPage.a_Asyila;

const List<BottomBarItem> _bottomBarItems = [
  BottomBarItem(
    ActiveQuestsUI(),
    ActiveQuestsSettingsUI(),
    'Active',
    'Pray like the Prophet (AS)', // FAB padding
    Icons.how_to_reg_outlined,
  ),
  BottomBarItem(
    DoListUI(),
    null,
    'Daily',
    'Build religious and healthy habits',
    Icons.brightness_high_outlined,
  ),
  BottomBarItem(
    SizedBox(),
    null,
    'a.Zaman',
    'Manage and prioritize your time',
    Icons.timer_outlined,
  ),
  BottomBarItem(
    SizedBox(),
    null,
    'a.hapi',
    'Set long-term goals',
    Icons.brightness_3_outlined,
  ),
];
