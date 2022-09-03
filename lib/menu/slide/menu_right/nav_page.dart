import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/tarikh/tarikh_ui.dart';

/// NPV= Nav Page Value holds values used to init a NavPage.
class NPV {
  const NPV(this.navPage, this.initTabName, this.icon);
  final NavPage navPage;
  final String initTabName;
  final IconData icon;
}

/// Must keep in sync with NavPage/menu list
final navPageValues = [
  NPV(NavPage.Ajr, '', Icons.leaderboard_rounded),
  NPV(NavPage.Tools, '', Icons.explore_outlined),
  NPV(NavPage.Dua, '', Icons.volunteer_activism),
  NPV(NavPage.Hadith, '', Icons.menu_book_outlined),
  NPV(NavPage.Quran, '', Icons.auto_stories),
  NPV(NavPage.Tarikh, TARIKH_TAB.Menu.name, Icons.history_edu_outlined),
  NPV(NavPage.Relics, RELIC_TAB.Anbia.name, Icons.brightness_3_outlined),
  NPV(NavPage.Quests, QUEST_TAB.Active.name, Icons.how_to_reg_outlined),
];

/// must keep in sync with navPageValues
enum NavPage {
  Ajr,
  Tools,
  Dua,
  Hadith,
  Quran,
  Tarikh,
  Relics,
  Quests,
}

extension EnumUtil on NavPage {
  String get trKey {
    String transliteration = name;
    switch (this) {
      case (NavPage.Ajr):
      case (NavPage.Dua):
      case (NavPage.Hadith):
      case (NavPage.Quran):
      case (NavPage.Tarikh):
        break;
      case (NavPage.Tools):
        transliteration = "'Adawat";
        break;
      case (NavPage.Relics):
        transliteration = 'Alathar';
        break;
      case (NavPage.Quests):
        transliteration = "'Asyila";
        break;
    }
    return 'a.$transliteration';
  }

  String get trValTooltip {
    switch (this) {
      case (NavPage.Ajr):
        return 'i.View your rewards'.tr;
      case (NavPage.Dua):
        return 'i.Find prayers'.tr;
      case (NavPage.Hadith):
        return 'i.Read from Books of Hadith'.tr;
      case (NavPage.Quran):
        return 'i.Read the Quran'.tr;
      case (NavPage.Tarikh):
        return 'i.View the history of Islam and our Universe'.tr;
      case (NavPage.Tools):
        return 'i.Use tools like the Qiblah Finder and Islamic Dictionary'.tr;
      case (NavPage.Relics):
        return 'i.Collect, upgrade and learn from Relics'.tr;
      case (NavPage.Quests):
        return 'i.Earn rewards for this life and the next'.tr;
      default:
        return l.E('Quests.trValTooltip: Unknown Quest "$this"');
    }
  }

  List<dynamic> get ltrTabList {
    switch (this) {
    // case (NavPage.Ajr):
    // case (NavPage.Dua):
    // case (NavPage.Hadith):
    // case (NavPage.Quran):
      case (NavPage.Tarikh):
        return TARIKH_TAB.values;
    // case (NavPage.Tools):
      case (NavPage.Relics):
        return RELIC_TAB.values;
      case (NavPage.Quests):
        return QUEST_TAB.values;
      default:
        return l.E('Quests.tabEnum: Unknown Quest "$this"');
    }
  }

  List<dynamic> get rtlTabList => List<dynamic>.from(ltrTabList.reversed);

  List<dynamic> get tabEnumList =>
      LanguageController.to.isRTL ? rtlTabList : ltrTabList;
}