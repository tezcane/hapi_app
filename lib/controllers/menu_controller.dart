import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
import 'package:hapi/ui/about_ui.dart';
import 'package:hapi/ui/components/menu_nav.dart';
import 'package:hapi/ui/quests_ui.dart';

final MenuController cMenu = Get.find();

// must keep in sync with _kNavs
enum NavPage {
  TOOLS,
  HADITH,
  QURAN,
  TARIKH,
  RELICS,
  QUESTS,
}

enum SubPage {
  ABOUT,
  TARIKH_FAVORITE,
  TARIKH_TIMELINE,
  TARIKH_ARTICLE,
}

class MenuController extends GetxController {
  static MenuController to = Get.find();

  late AnimationController _acFabIcon; // controls fab icon animation
  late AnimationController _acNavMenu; // controls nav menu animation

  void initACFabIcon(AnimationController ac) => _acFabIcon = ac;
  void initACNavMenu(AnimationController navMenuAC) => _acNavMenu = navMenuAC;

  // use to control fab animation depending if it as a root or deeper page
  // final AnimatedIconData animatedIconMenuClose = AnimatedIcons.menu_close;
  // final AnimatedIconData animatedIconMenuArrow = AnimatedIcons.arrow_menu;
  // AnimatedIconData _fabAnimatedIcon = AnimatedIcons.menu_close;
  // AnimatedIconData getFabAnimatedIcon() => _fabAnimatedIcon;

  // RxBool _isFabBackMode = false.obs;
  // RxBool get isFabBackMode => _isFabBackMode;

  /// Track pushed pages so we can backtrack to main nav menu page
  // TODO Persist this, where possible, pass in arguments to classes to rebuild:
  List<SubPage> _subPageStack = [];

  int _getLastNavIdx() {
    return s.read('lastNavIdx') ?? NavPage.QUESTS.index;
  }

  NavPage _getLastNavPage() {
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
      heroLogoTransistionMs = 0;
      _disableScreenTouch();
    }

    _navigateToNavPage(lastNavPage, transistionMs: heroLogoTransistionMs);

    if (!isFastStartupMode()) {
      Timer(Duration(milliseconds: showMenuDuringHeroTransistionMs), () {
        showMenu(); // open menu to let logo slide into place
        Timer(Duration(milliseconds: hideMenuAfterFullInitMs), () {
          hideMenu(); // logo should be in menu by now
          Timer(navMenuShowHideMs, () {
            _enableScreenTouch(); // give time for menu to close
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
  void navigateToNavPage(int navIdx, {bool offAll = false}) {
    NavPage navPage = _getNavPage(navIdx);

    // clear stack in case we jump to this next nav menu
    if (_subPageStack.length > 0) {
      _subPageStack = [];
    }
    // if (isFabBackMode.value == true) {
    //   _setFabBackMode(false);
    // }

    // save so app restarts at this idx
    s.write('lastNavIdx', navIdx);

    _navigateToNavPage(navPage);
  }

  void _navigateToNavPage(NavPage navPage,
      {int transistionMs = 400, Transition transition = Transition.fade}) {
    switch (navPage) {
      case (NavPage.TOOLS):
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
  void pushSubPage(SubPage subPage) {
    // // TODO option for disallow duplicates so might not need this
    // if (_subPageStack.length != 0) {
    //   if (_subPageStack[_subPageStack.length - 1] == subPage) {
    //     //print('$pageName already on stack, returning!');
    //     return;
    //   }
    // }

    // if (!_isFabBackMode.value) {
    //   _setFabBackMode(true);
    // }

    _subPageStack.add(subPage);

    switch (subPage) {
      case (SubPage.ABOUT):
        Get.to(() => AboutUI());
        break;
      case (SubPage.TARIKH_FAVORITE):
        Get.to(() => TarikhFavoritesUI());
        break;
      case (SubPage.TARIKH_TIMELINE):
        Get.to(() => TarikhTimelineUI());
        break;
      case (SubPage.TARIKH_ARTICLE):
        Get.to(() => TarikhArticleUI());
        break;
      default:
        throw 'Subhanallah!';
    }
  }

  // void _setFabBackMode(bool newfabBackMode) {
  //   _isFabBackMode.value = newfabBackMode;
  //   // TODO smooth back<->menu<->close transitions
  //   if (_isFabBackMode.value) {
  //     _fabAnimatedIcon = animatedIconMenuArrow;
  //   } else {
  //     _fabAnimatedIcon = animatedIconMenuClose;
  //   }
  //   update();
  // }

  void handleBackButtonHit() {
    // // paranoid check
    // if (_subPageStack.length > 0) {
    //   print('ERROR: handleBackButtonHit paranoid check hit');
    //   _subPageStack.removeLast();
    // }

    if (_subPageStack.length == 1) {
      navigateToNavPage(_getLastNavIdx()); // this clears out fab back mode
      // TODO animate back button
    } else {
      Get.back(); // pop the sub menu stack
    }
  }

  // bool isAboutPageShowing() {
  //   if (_subPageStack.length != 0) {
  //     return _subPageStack[_subPageStack.length - 1] == SubPage.ABOUT;
  //   }
  //   return false;
  // }

  RxBool _isScreenDisabled = false.obs;
  RxBool _isMenuShowing = false.obs;
  RxBool _isMenuShowingNav = false.obs;
  RxBool _isMenuShowingSpecial = false.obs; // TODO
  RxBool _isSpecialActionReady = false.obs;

  RxBool get isScreenDisabled => _isScreenDisabled;
  RxBool get isMenuShowing => _isMenuShowing;
  RxBool get isMenuShowingNav => _isMenuShowingNav;
  RxBool get isMenuShowingSpecial => _isMenuShowingSpecial;
  RxBool get isSpecialActionReady => _isSpecialActionReady;

  void showMenu() {
    _isMenuShowing.value = true;
    _isMenuShowingNav.value = true;
    _isMenuShowingSpecial.value = false;
    _isSpecialActionReady.value = false;

    _acFabIcon.forward();
    _acNavMenu.reverse();

    update();
  }

  void hideMenu() {
    _isMenuShowing.value = false;
    _isMenuShowingNav.value = false;
    _isMenuShowingSpecial.value = false;
    _isSpecialActionReady.value = false;

    _acFabIcon.reverse();
    _acNavMenu.forward();

    update();
  }

  void hideMenuNav() {
    _isMenuShowing.value = true;
    _isMenuShowingNav.value = false;
    _isMenuShowingSpecial.value = true;
    _isSpecialActionReady.value = false;

    _acNavMenu.forward();

    update();
  }
}
