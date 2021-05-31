import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_nav.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_search_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
import 'package:hapi/ui/about_ui.dart';

final MenuController cMenu = Get.find();

class Nav {
  const Nav({required this.np, required this.label, required this.icon});
  final NavPage np;
  final String label;
  final IconData icon;
}

const kNavs = const [
  Nav(np: NavPage.STATS, label: 'Stats', icon: Icons.leaderboard_rounded),
  Nav(np: NavPage.TOOLS, label: 'Tools', icon: Icons.explore_outlined),
  Nav(np: NavPage.DUA, label: 'Dua', icon: Icons.volunteer_activism),
  Nav(np: NavPage.HADITH, label: 'Hadith', icon: Icons.menu_book_outlined),
  Nav(np: NavPage.QURAN, label: 'Quran', icon: Icons.auto_stories),
  Nav(np: NavPage.TARIKH, label: 'Tarikh', icon: Icons.history_edu_outlined),
  Nav(np: NavPage.RELICS, label: 'Relics', icon: Icons.brightness_3_outlined),
  Nav(np: NavPage.QUESTS, label: 'Quests', icon: Icons.how_to_reg_outlined),
];

// must keep in sync with _kNavs
enum NavPage {
  STATS,
  TOOLS,
  DUA,
  HADITH,
  QURAN,
  TARIKH,
  RELICS,
  QUESTS,
}

enum SubPage {
  ABOUT,
  TARIKH_FAVORITE,
  TARIKH_SEARCH,
  TARIKH_TIMELINE,
  TARIKH_ARTICLE,
}

class MenuController extends GetxController {
  static MenuController to = Get.find();

  late AnimationController _acFabIcon; // controls fab icon animation
  late AnimationController _acNavMenu; // controls nav menu animation

  void initACFabIcon(AnimationController ac) => _acFabIcon = ac;
  void initACNavMenu(AnimationController navMenuAC) => _acNavMenu = navMenuAC;

  // TODO looks like a bug in getx for this: https://github.com/jonataslaw/getx/issues/1027
  // list aligns with enum NavPage above.
  final RxList<bool> _showBadge =
      RxList([false, true, true, false, false, false, true, false]);
  bool getShowBadge(NavPage navPage) => _showBadge[navPage.index];
  void setShowBadge(NavPage navPage, bool value) {
    _showBadge[navPage.index] = value;
    update();
  }

  RxBool _showNavSettings = false.obs;
  bool getShowNavSettings() => _showNavSettings.value;
  void setShowNavSettings(bool value) {
    _showNavSettings.value = value;
    Timer(const Duration(seconds: 0), () => update()); // requires new thread
  }

  /// Track pushed pages so we can backtrack to main nav menu page
  // TODO Persist this, where possible, pass in arguments to classes to rebuild:
  List<SubPage> _subPageStack = [];

  int _getLastNavIdx() {
    return s.read('lastNavIdx') ?? NavPage.QUESTS.index;
  }

  NavPage getLastNavPage() {
    return _getNavPage(_getLastNavIdx());
  }

  bool isFastStartupMode() {
    return s.read('fastStartupMode') ?? true; // TODO write this setting
  }

  /// set foreground to last opened page
  void initAppsFirstPage() {
    int navIdx = _getLastNavIdx(); //Quests

    NavPage lastNavPage = NavPage.QUESTS;
    try {
      lastNavPage = NavPage.values[navIdx];
    } catch (e) {
      print('ERROR: appInit last index was $navIdx, no longer used');
    }

    int heroLogoTransistionMs = 3001;
    int showMenuDuringHeroTransistionMs = heroLogoTransistionMs - 1500;
    int hideMenuAfterFullInitMs = 2000;

    if (!isFastStartupMode()) {
      _disableScreenTouch();
    } else {
      heroLogoTransistionMs = 0;
      cMain.setAppInitDone();
    }

    _navigateToNavPage(lastNavPage, transistionMs: heroLogoTransistionMs);

    if (!isFastStartupMode()) {
      Timer(Duration(milliseconds: showMenuDuringHeroTransistionMs), () {
        showMenu(); // open menu to let logo slide into place
        Timer(Duration(milliseconds: hideMenuAfterFullInitMs), () {
          hideMenu(); // logo should be in menu by now
          Timer(navMenuShowHideMs, () {
            _enableScreenTouch(); // give time for menu to close
            cMain.setAppInitDone();
          });
        });
      });
    }
  }

  void _disableScreenTouch() {
    _isScreenDisabled.value = true;
    update();
  }

  void _enableScreenTouch() {
    _isScreenDisabled.value = false;
    update();
  }

  NavPage _getNavPage(int navIdx) {
    try {
      return NavPage.values[navIdx];
    } catch (e) {
      print('ERROR did not find navIdx $navIdx page, trying for Quest');
      return NavPage.QUESTS;
    }
  }

  /// Use to switch to a high level nav page only (e.g. Quests, Quran, etc.)
  void navigateToNavPage(NavPage navPage, {bool offAll = false}) {
    // clear stack in case we jump to this next nav menu
    if (_subPageStack.length > 0) {
      _subPageStack = [];
    }

    // save so app restarts at this idx
    s.write('lastNavIdx', navPage.index);

    _navigateToNavPage(navPage);
  }

  void _navigateToNavPage(
    NavPage navPage, {
    //dynamic arguments,
    int transistionMs = 1000,
    Transition transition = Transition.fade,
  }) {
    _showNavSettings.value = false; // clear last setting icon if was showing

    switch (navPage) {
      case (NavPage.STATS):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.TOOLS):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.DUA):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.HADITH):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.QURAN):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.TARIKH):
        Get.offAll(
          () => TarikhMenuUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.RELICS):
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (NavPage.QUESTS):
      default:
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
    }
  }

  /// use to push a NavPages sub page (Tarikh Favorites, etc.) on top of menu stack
  /// About page is ok here too
  void pushSubPage(
    SubPage subPage, {
    dynamic arguments,
    int transistionMs = 1000,
    Transition transition = Transition.fade,
  }) {
    // // TODO option for disallow duplicates so might not need this
    // if (_subPageStack.length != 0) {
    //   if (_subPageStack[_subPageStack.length - 1] == subPage) {
    //     //print('$pageName already on stack, returning!');
    //     return;
    //   }
    // }

    _subPageStack.add(subPage);

    switch (subPage) {
      case (SubPage.TARIKH_FAVORITE):
        Get.to(
          () => TarikhFavoritesUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.TARIKH_SEARCH):
        Get.to(
          () => TarikhSearchUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.TARIKH_TIMELINE):
        Get.to(
          () => TarikhTimelineUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.TARIKH_ARTICLE):
        Get.to(
          () => TarikhArticleUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.ABOUT):
      default:
        Get.to(
          () => AboutUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
    }
  }

  void handleBackButtonHit() {
    if (_subPageStack.length == 1) {
      navigateToNavPage(getLastNavPage()); // this clears out fab back mode
      // TODO animate back button
    } else {
      if (_subPageStack.length > 1) {
        _subPageStack.removeLast();
      }
      Get.back(); // pop the sub menu stack
    }
  }

  bool isAnySubPageShowing() {
    if (_subPageStack.length != 0) {
      return true;
    }
    return false;
  }

  bool isSubPageShowing(SubPage subPage) {
    if (_subPageStack.length != 0) {
      return _subPageStack[_subPageStack.length - 1] == subPage;
    }
    return false;
  }

  RxBool _isScreenDisabled = false.obs;
  RxBool _isMenuShowing = false.obs;
  RxBool _isMenuShowingNav = false.obs;
  RxBool _isMenuShowingSettings = false.obs;

  RxBool get isScreenDisabled => _isScreenDisabled;
  RxBool get isMenuShowing => _isMenuShowing;
  RxBool get isMenuShowingNav => _isMenuShowingNav;
  RxBool get isMenuShowingSettings => _isMenuShowingSettings;

  void showMenu() {
    _isMenuShowing.value = true;
    _isMenuShowingNav.value = true;
    _isMenuShowingSettings.value = false;

    _acFabIcon.forward();
    _acNavMenu.reverse();

    update();
  }

  void hideMenu() {
    _isMenuShowing.value = false;
    _isMenuShowingNav.value = false;
    _isMenuShowingSettings.value = false;

    _acFabIcon.reverse();
    _acNavMenu.forward();

    update();
  }

  void hideMenuNav() {
    _isMenuShowing.value = true;
    _isMenuShowingNav.value = false;
    _isMenuShowingSettings.value = true;

    _acNavMenu.forward();

    update();
  }
}
