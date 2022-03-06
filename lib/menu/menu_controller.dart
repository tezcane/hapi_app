import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/about_ui.dart';
import 'package:hapi/menu/menu_nav.dart';
import 'package:hapi/quest/active/active_quest_action_ui.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/settings/reset_password_ui.dart';
import 'package:hapi/settings/update_profile_ui.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_search_ui.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

class Nav {
  const Nav({required this.np, required this.label, required this.icon});
  final NavPage np;
  final String label;
  final IconData icon;
}

const kNavs = [
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
  UPDATE_PROFILE,
  RESET_PASSWORD,
  TARIKH_FAVORITE,
  TARIKH_SEARCH,
  TARIKH_TIMELINE,
  TARIKH_ARTICLE,
  ACTIVE_QUEST_ACTION,
}

class MenuController extends GetxHapi {
  static MenuController get to => Get.find();

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

  final RxBool _showNavSettings = false.obs;
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
      MainController.to.setAppInitDone();
    }

    _navigateToNavPage(lastNavPage, transistionMs: heroLogoTransistionMs);

    if (!isFastStartupMode()) {
      Timer(Duration(milliseconds: showMenuDuringHeroTransistionMs), () {
        showMenu(); // open menu to let logo slide into place
        Timer(Duration(milliseconds: hideMenuAfterFullInitMs), () {
          hideMenu(); // logo should be in menu by now
          Timer(navMenuShowHideMs, () {
            _enableScreenTouch(); // give time for menu to close
            MainController.to.setAppInitDone();
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
    if (_subPageStack.isNotEmpty) {
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

    TarikhController.t.isActive = false; // turn off timeline rendering

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
          () => const TarikhMenuUI(),
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

    // turn off timeline rendering, in case it was previously showing/on
    if (subPage != SubPage.TARIKH_TIMELINE) {
      TarikhController.t.isActive = false;
    }

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
          () => const TarikhSearchUI(),
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
      case (SubPage.ACTIVE_QUEST_ACTION):
        Get.to(
          () => ActiveQuestActionUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.UPDATE_PROFILE):
        Get.to(
          () => UpdateProfileUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.RESET_PASSWORD):
        Get.to(
          () => ResetPasswordUI(),
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

        // timeline showing again so turn timeline rendering on
        if (_subPageStack[0] == SubPage.TARIKH_TIMELINE) {
          TarikhController.t.isActive = true;
        }
      }
      Get.back(); // pop the sub menu stack
    }
  }

  bool isAnySubPageShowing() {
    if (_subPageStack.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool isSubPageShowing(SubPage subPage) {
    if (_subPageStack.isNotEmpty) {
      return _subPageStack[_subPageStack.length - 1] == subPage;
    }
    return false;
  }

  final RxBool _isScreenDisabled = false.obs;
  final RxBool _isMenuShowing = false.obs;
  final RxBool _isMenuShowingNav = false.obs;
  final RxBool _isMenuShowingSettings = false.obs;

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

  static final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  ConfettiController confettiController() => _confettiController;
  void playConfetti() => _confettiController.play();

// TODO
// @override
// void dispose() {
//   _confettiController.dispose();
//   super.dispose();
// }
}
