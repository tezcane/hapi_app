import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// NPV= Nav Page Value holds values used to init a NavPage.
class NPV {
  const NPV(this.navPage, this.icon);
  final NavPage navPage;
  final IconData icon;
}

/// Must keep in sync with NavPage/menu list
const List<NPV> navPageValues = [
  NPV(NavPage.Ajr, Icons.leaderboard_rounded),
  NPV(NavPage.a_Adawat, Icons.explore_outlined),
  NPV(NavPage.Dua, Icons.volunteer_activism),
  NPV(NavPage.Hadith, Icons.menu_book_outlined),
  NPV(NavPage.Quran, Icons.auto_stories),
  NPV(NavPage.Tarikh, Icons.history_edu_outlined),
  NPV(NavPage.Alathar, Icons.brightness_3_outlined),
  NPV(NavPage.a_Asyila, Icons.how_to_reg_outlined),
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
}

/// TODO this is needed in another class, should it be?
enum RELIC_TAB {
  Favorites,
  Search,
  Relics, // a.Alathar
  Places,
  Delil,
  Ummah,
  Allah, // Asma_ul_Husna,
}
