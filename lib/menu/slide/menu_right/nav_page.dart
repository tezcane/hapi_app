import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';

/// NPV= Nav Page Value holds values used to init a NavPage.
class NPV {
  const NPV(this.navPage, this.initTabName, this.icon);
  final NavPage navPage;
  final String initTabName;
  final IconData icon;
}

/// Must keep in sync with NavPage/menu list
final navPageValues = [
  NPV(NavPage.Ajr, NavPage.Ajr.initEnum.name, Icons.leaderboard_rounded),
  NPV(NavPage.a_Adawat, NavPage.a_Adawat.initEnum.name, Icons.explore_outlined),
  NPV(NavPage.Dua, NavPage.Dua.initEnum.name, Icons.volunteer_activism),
  NPV(NavPage.Hadith, NavPage.Hadith.initEnum.name, Icons.menu_book_outlined),
  NPV(NavPage.Quran, NavPage.Quran.initEnum.name, Icons.auto_stories),
  NPV(NavPage.Tarikh, NavPage.Tarikh.initEnum.name, Icons.history_edu_outlined),
  NPV(NavPage.Alathar, NavPage.Alathar.initEnum.name,
      Icons.brightness_3_outlined),
  NPV(NavPage.a_Asyila, NavPage.a_Asyila.initEnum.name,
      Icons.how_to_reg_outlined),
];

/// must keep in sync with navPageValues
enum NavPage {
  Ajr,
  a_Adawat, // Tools
  Dua,
  Hadith,
  Quran,
  Tarikh,
  Alathar, // Relics
  a_Asyila, // Quests
}

extension EnumUtil on NavPage {
  String get tvTooltip {
    switch (this) {
      case NavPage.Ajr:
        return 'View your rewards'.tr;
      case NavPage.Dua:
        return 'Find prayers'.tr;
      case NavPage.Hadith:
        return 'Read from Books of Hadith'.tr;
      case NavPage.Quran:
        return 'Read the Quran'.tr;
      case NavPage.Tarikh:
        return 'View the history of Islam and our Universe'.tr;
      case NavPage.a_Adawat:
        return 'Use tools like the Qiblah Finder and Islamic Dictionary'.tr;
      case NavPage.Alathar:
        return 'Collect, upgrade and learn from Relics'.tr;
      case NavPage.a_Asyila:
        return 'Earn rewards for this life and the next'.tr;
    }
  }

  /// [tabListRTL] has main tab at idx 0, [tabListLTR] at last idx.
  Enum get initEnum =>
      tabListLTR[LanguageC.to.isRTL ? 0 : tabListLTR.length - 1];

  /// Used to display tabs in right->left mode in LTR mode.
  /// [tabListLTR] has the most significant tab at the last index.
  List<Enum> get tabListLTR {
    switch (this) {
      case NavPage.Ajr: // TODO implement these
      case NavPage.a_Adawat:
      case NavPage.Dua:
      case NavPage.Hadith:
      case NavPage.Quran:
      case NavPage.Tarikh:
        return TARIKH_TAB.values;
      case NavPage.Alathar:
        return RELIC_TAB.values;
      case NavPage.a_Asyila:
        return QUEST_TAB.values;
    }
  }

  /// Used to display tabs in right->left mode in RTL mode.
  /// [tabListRTL] has the most significant tab at the first index (index 0).
  List<Enum> get tabListRTL => List<Enum>.from(tabListLTR.reversed);

  List<Enum> get tabList => LanguageC.to.isLTR ? tabListLTR : tabListRTL;
}

enum TARIKH_TAB {
  Favorites,
  Search,
  Menu,
}

enum RELIC_TAB {
  Favorites,
  Search,
  Relics, // a.Alathar
  Places,
  Delil,
  Ummah,
  Allah, // Asma_ul_Husna,
}

enum QUEST_TAB {
  hapi,
  Time,
  Daily,
  Active,
}
