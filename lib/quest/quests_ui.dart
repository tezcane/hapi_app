import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';
import 'package:hapi/settings/language/language_controller.dart';
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

  static final List<BottomBarItem> bbItems = [
    BottomBarItem(
      Container(),
      null,
      Quests.hapi.name,
      Icons.brightness_3_outlined,
      '${Quests.hapi.name} Quests has app and long-term goals',
      AppThemes.logoText,
    ),
    BottomBarItem(
      Container(),
      null,
      Quests.Time.name,
      Icons.timer_outlined,
      '${Quests.Time.name} Quests to prioritize and manage your time',
      Colors.greenAccent.shade700, //.orange,
    ),
    BottomBarItem(
      const DoListUI(),
      null,
      Quests.Daily.name,
      Icons.brightness_high_outlined,
      '${Quests.Daily.name} Quests to build good habits',
      const Color(0xFFF1AC44),
    ),
    BottomBarItem(
      const ActiveQuestsUI(),
      ActiveQuestsSettingsUI(),
      Quests.Active.name,
      Icons.how_to_reg_outlined,
      '            ' // Get around FAB
      '${Quests.Active.name} Quests to enhance prayers'
      '            ', // Get around FAB
      Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (c) {
      List<BottomBarItem> bottomBarItems = bbItems;
      if (c.isRightToLeftLang) {
        // TODO swap langs PageController index is off
        bottomBarItems = List<BottomBarItem>.from(bbItems.reversed);
      }

      final List<Widget> mainWidgets = [
        bottomBarItems[0].aliveMainWidget,
        bottomBarItems[1].aliveMainWidget,
        bottomBarItems[2].aliveMainWidget,
        bottomBarItems[3].aliveMainWidget,
      ];

      final List<Widget?> settingsWidgets = [
        bottomBarItems[0].settingsWidget,
        bottomBarItems[1].settingsWidget,
        bottomBarItems[2].settingsWidget,
        bottomBarItems[3].settingsWidget,
      ];

      return FabNavPage(
        navPage: navPage,
        settingsWidgets: settingsWidgets,
        bottomWidget: HapiShareUI(),
        foregroundPage: BottomBarMenu(navPage, bottomBarItems, mainWidgets),
      );
    });
  }
}
