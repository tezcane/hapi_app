import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';

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
      // do here to save memory:
      final List<BottomBarItem> bottomBarItems = [
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
