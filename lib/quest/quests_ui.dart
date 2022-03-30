import 'package:flutter/material.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';

enum Quests {
  hapi,
  Time,
  Daily,
  Active,
}

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class QuestsUI extends StatelessWidget {
  static const navPage = NavPage.Quests;

  static final List<BBItem> bbItemList = [
    BBItem(
      navPage,
      Container(),
      null,
      AppThemes.logoText,
      Icons.brightness_3_outlined,
      Quests.hapi.name,
      '${Quests.hapi.name} Quests has app and long-term goals',
      useHapiLogoFont: true,
    ),
    BBItem(
      navPage,
      Container(),
      null,
      Colors.greenAccent.shade700, //.orange,
      Icons.timer_outlined,
      Quests.Time.name,
      '${Quests.Time.name} Quests to prioritize and manage your time',
    ),
    BBItem(
      navPage,
      const DoListUI(),
      null,
      const Color(0xFFF1AC44),
      Icons.brightness_high_outlined,
      Quests.Daily.name,
      '${Quests.Daily.name} Quests to build good habits',
    ),
    BBItem(
      navPage,
      ActiveQuestsUI(),
      ActiveQuestsSettingsUI(),
      Colors.blue,
      Icons.how_to_reg_outlined,
      Quests.Active.name,
      ''
      '            ' // Get around FAB
      '${Quests.Active.name} Quests to enhance prayers'
      '            ', // Get around FAB
    ),
  ];

  static final List<Widget> mainWidgets = [
    bbItemList[0].aliveMainWidget,
    bbItemList[1].aliveMainWidget,
    bbItemList[2].aliveMainWidget,
    bbItemList[3].aliveMainWidget,
  ];
  static final List<Widget?> settingsWidgets = [
    bbItemList[0].settingsWidget,
    bbItemList[1].settingsWidget,
    bbItemList[2].settingsWidget,
    bbItemList[3].settingsWidget,
  ];

  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: navPage,
      settingsWidgets: settingsWidgets,
      bottomWidget: HapiShareUI(),
      foregroundPage: BottomBarMenu(navPage, bbItemList, mainWidgets),
    );
  }
}
