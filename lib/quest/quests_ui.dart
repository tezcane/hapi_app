import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

enum QUEST_TAB {
  hapi,
  Time,
  Daily,
  Active,
}

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class QuestsUI extends StatelessWidget {
  const QuestsUI();
  static const navPage = NavPage.Quests;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (c) {
      final List<BottomBarItem> bbItems = [
        BottomBarItem(
          Container(),
          null,
          a('a.hapi'),
          'i.Set long-term goals'.tr,
          Icons.brightness_3_outlined,
          AppThemes.logoText,
        ),
        BottomBarItem(
          Container(),
          null,
          a('a.Zaman'),
          'i.Manage and prioritize your time'.tr,
          Icons.timer_outlined,
          Colors.greenAccent.shade700,
        ),
        BottomBarItem(
          const DoListUI(),
          null,
          'i.Daily'.tr,
          'i.Build religious and healthy habits'.tr,
          Icons.brightness_high_outlined,
          AppThemes.ajr5Legendary,
        ),
        BottomBarItem(
          const ActiveQuestsUI(),
          ActiveQuestsSettingsUI(),
          'i.Active'.tr,
          '                 ${'i.Pray like the Prophet (AS)'.tr}                 ', // FAB
          Icons.how_to_reg_outlined,
          Colors.blue,
        ),
      ];

      List<BottomBarItem> bottomBarItems = bbItems;
      if (c.isRTL) {
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
