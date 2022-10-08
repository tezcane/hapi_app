import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/ajr/ajr_ui.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/dua/dua_ui.dart';
import 'package:hapi/hadith/hadith_ui.dart';
import 'package:hapi/helper/loading.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/about/about_ui.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/profile/reset_password_ui.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/profile/update_profile_ui.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/quest/active/active_quest_action_ui.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/quran/quran_ui.dart';
import 'package:hapi/relic/family_tree/family_tree_ui.dart';
import 'package:hapi/relic/relics_ui.dart';
import 'package:hapi/tarikh/event/event_details_ui.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/tarikh_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
import 'package:hapi/tool/tool_ui.dart';

class MenuC extends GetxHapi with GetTickerProviderStateMixin {
  static MenuC get to => Get.find();

  /// fab and menu animation controllers
  final animationDuration = const Duration(milliseconds: 650);
  AnimatedIconData _fabAnimatedIcon = AnimatedIcons.menu_close;
  AnimatedIconData get fabAnimatedIcon => _fabAnimatedIcon;
  late AnimationController _acFabIcon; // controls fab icon animation
  late AnimationController _acNavMenu; // controls nav menu animation
  get acFabIcon => _acFabIcon;
  get acNavMenu => _acNavMenu;

  /// Track if user clicks on sub page transition so we can protect fab icon
  bool fabButtonIsTransitioning = false;

  @override
  void onInit() {
    super.onInit();

    _acFabIcon = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    _acNavMenu = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    _acNavMenu.forward(from: 1.0); // needed to hide at init
  }

  /// Needed when signing out of app, so FAB button works on sign back in.
  clearSubPageStack() => _subPageStack = [];

  /// Here we handle when the FAB button is hit for show/hide menu or back btn.
  void handlePressedFAB() {
    if (fabButtonIsTransitioning) {
      l.w('GOOD TRY, FAB is still transitioning!!!!!!!!!!');
      return; // POSSIBLE HAPI QUEST: "Interrupt/Break Menu Button" hapi task
    }

    /// Show/Hide menu hit (only available on main NavPage)
    if (_subPageStack.isEmpty) {
      if (_isMenuShowing) {
        hideMenu(); // just hit close on fab
      } else {
        showMenu(); // just hit menu on fab
      }
      return;
    }

    /// If here, back button was hit

    /// if going back to main nav page, play animation
    if (_subPageStack.length == 1) {
      _acFabIcon.reverse();
      _fabAnimatedIcon = AnimatedIcons.menu_close; // switch to menu close icon
      update();
    }

    /// User may have updated profile settings and hit back button before saving
    if (_subPageStack.isNotEmpty &&
        _subPageStack.last == SubPage.Update_Profile) {
      AuthC c = AuthC.to;
      c.nameController.text = c.firestoreUser.value!.name;
      c.emailController.text = c.firestoreUser.value!.email;
    }

    /// pop the page out of the stack
    _subPageStack.removeLast();

    /// handle tarikh animated pages, set active/inactive
    if (getLastNavPage() == NavPage.Tarikh) {
      // if timeline showing again (after event view), make timeline active
      if (_subPageStack.isNotEmpty &&
          _subPageStack.last == SubPage.Tarikh_Timeline) {
        TarikhC.to.isActiveTimeline = true; // reactivate timeline
      } else {
        TarikhC.to.isActiveTimeline = false; // inactivate timeline

        if (_subPageStack.isEmpty &&
            NavPageC.to.getLastIdxName(NavPage.Tarikh) ==
                TARIKH_TAB.Menu.name) {
          TarikhC.to.isActiveTarikhMenu = true; // reactivate menu
        }
      }
    }

    Get.back(); // pop the sub menu stack

    update(); // updates FAB tooltip to say what back button does
  }

  /// Handle the fab button hint, required update() to be called on page
  /// insertion and deletion.
  String tvMenuTooltip() {
    if (_subPageStack.isNotEmpty) {
      if (_subPageStack.length > 1) {
        return 'Go back to previous page'.tr;
      } else {
        return at(
          'at.Go back to {0} home page',
          [getLastNavPage().tkIsimA],
        );
      }
    } else if (_isMenuShowing) {
      return 'Hide menu'.tr;
    } else {
      return 'Show menu'.tr;
    }
  }

  // TODO looks like a bug in getx for this: https://github.com/jonataslaw/getx/issues/1027
  // list aligns with enum NavPage above.
  final RxList<bool> _showBadge =
      RxList([false, true, true, false, false, false, true, false]);
  bool getShowBadge(NavPage navPage) => _showBadge[navPage.index];
  void setShowBadge(NavPage navPage, bool value) {
    _showBadge[navPage.index] = value;
    update();
  }

  /// Track pushed pages so we can backtrack to main nav menu page
  // TODO Persist this, where possible, pass in arguments to classes to rebuild:
  List<SubPage> _subPageStack = [];

  int _getLastNavIdx() => s.rd('lastNavIdx') ?? NavPage.a_Asyila.index;

  NavPage getLastNavPage() => _getNavPage(_getLastNavIdx());

  bool isFastStartupMode() => s.rd('fastStartupMode') ?? true; // TODO persists

  /// set foreground to last opened page
  initAppsFirstPage() {
    int navIdx = _getLastNavIdx(); //Quests

    NavPage lastNavPage = NavPage.a_Asyila;
    try {
      lastNavPage = NavPage.values[navIdx];
    } catch (e) {
      l.e('appInit last index was $navIdx, no longer used, error: $e');
    }

    int heroLogoTransitionMs = 3001;
    int showMenuDuringHeroTransitionMs = heroLogoTransitionMs - 1500;
    int hideMenuAfterFullInitMs = 2000;

    if (!isFastStartupMode()) {
      _disableScreenTouch();
    } else {
      heroLogoTransitionMs = 0;
    }

    _navigateToNavPage(lastNavPage, transitionMs: heroLogoTransitionMs);

    if (!isFastStartupMode()) {
      Timer(Duration(milliseconds: showMenuDuringHeroTransitionMs), () {
        showMenu(); // open menu to let logo slide into place
        Timer(Duration(milliseconds: hideMenuAfterFullInitMs), () {
          hideMenu(); // logo should be in menu by now
          Timer(animationDuration, () {
            _enableScreenTouch(); // give time for menu to close
          });
        });
      });
    }
  }

  void _disableScreenTouch() {
    _isScreenDisabled = true;
    update();
  }

  void _enableScreenTouch() {
    _isScreenDisabled = false;
    update();
  }

  NavPage _getNavPage(int navIdx) {
    try {
      return NavPage.values[navIdx];
    } catch (e) {
      l.e('Did not find navIdx $navIdx page, trying for Quest, error: $e');
      return NavPage.a_Asyila;
    }
  }

  /// Use to switch to a high level nav page only (e.g. Quests, Quran, etc.)
  void navigateToNavPage(NavPage navPage, {bool offAll = false}) {
    // clear stack in case we jump to this next nav menu
    if (_subPageStack.isNotEmpty) _subPageStack = [];

    // save so app restarts at this idx
    s.wr('lastNavIdx', navPage.index);

    _navigateToNavPage(navPage);
  }

  _navigateToNavPage(
    NavPage navPage, {
    //dynamic arguments,
    int transitionMs = 1000,
    Transition transition = Transition.fade,
  }) {
    TarikhC.to.isActiveTimeline = false; // turn off timeline rendering

    switch (navPage) {
      case NavPage.Ajr:
        return Get.offAll(
          () => const AjrUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.a_Adawat:
        return Get.offAll(
          () => const ToolUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.Dua:
        return Get.offAll(
          () => const DuaUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.Hadith:
        return Get.offAll(
          () => const HadithUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.Quran:
        return Get.offAll(
          () => const QuranUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.Tarikh:
        return Get.offAll(
          () => const TarikhUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.Alathar:
        return Get.offAll(
          () => const RelicsUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
      case NavPage.a_Asyila:
        return Get.offAll(
          () => const QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
    }
  }

  /// use to push a NavPages sub page (Tarikh Favorites, etc.) on top of menu stack
  /// About page is ok here too
  void pushSubPage(
    SubPage subPage, {
    dynamic arguments,
    int transitionMs = 1000,
    Transition transition = Transition.fade,
  }) async {
    // There is a GetX option to disallow duplicates, so don't need:
    // if (_subPageStack.length != 0) {
    //   if (_subPageStack[_subPageStack.length - 1] == subPage) {
    //     //print('$pageName already on stack, returning!');
    //     return;
    //   }
    // }

    _subPageStack.add(subPage);

    /// HERE WE HANDLE THE FAB BUTTON ANIMATIONS ON INSERTING NEW SUB PAGES
    // if adding first sub page, animate menu turning into an arrow
    // e.g. go to about page tapped: Menu x -> Menu -> "<-" Back arrow
    if (_subPageStack.length == 1) {
      fabButtonIsTransitioning = true;
      if (_isMenuShowing) hideMenu();
      Timer(animationDuration, () {
        _fabAnimatedIcon = AnimatedIcons.menu_arrow;
        update();
        _acFabIcon.forward();
        fabButtonIsTransitioning = false;
      }); // requires new thread
    }

    if (getLastNavPage() == NavPage.Tarikh) {
      TarikhC.to.isActiveTarikhMenu = false; // inactivate tarikh menu
    }

    switch (subPage) {
      case SubPage.Active_Quest_Action:
        Get.to(
          () => ActiveQuestActionUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Tarikh_Timeline:
        await _handleTimelineNotInitializedYet();
        Get.to(
          () => TarikhTimelineUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Event_Details:
        Get.to(
          () => EventDetailsUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Family_Tree:
        Get.to(
          () => FamilyTreeUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Settings:
        Get.to(
          () => SettingsUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Update_Profile:
        Get.to(
          () => UpdateProfileUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.Reset_Password:
        Get.to(
          () => ResetPasswordUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case SubPage.About:
        Get.to(
          () => AboutUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
    }

    update(); // updates FAB tooltip to say what back button does
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

  bool _isScreenDisabled = false;
  bool _isMenuShowing = false;
  bool _isMenuShowingNav = false;
  bool _isMenuShowingSettings = false;

  bool get isScreenDisabled => _isScreenDisabled;
  bool get isMenuShowing => _isMenuShowing;
  bool get isMenuShowingNav => _isMenuShowingNav;
  bool get isMenuShowingSettings => _isMenuShowingSettings;

  void showMenu() {
    // If bottom bar is hidden, we must show it now so it doesn't block menu UI:
    if (!BottomBarMenu.isBottomBarVisible) {
      BottomBarMenu.isBottomBarVisible = true;
      NavPageC.to.updateOnThread1Ms();
    }

    _isMenuShowing = true;
    _isMenuShowingNav = true;
    _isMenuShowingSettings = false;

    _acFabIcon.forward();
    _acNavMenu.reverse();

    update();
  }

  void hideMenu() {
    _isMenuShowing = false;
    _isMenuShowingNav = false;
    _isMenuShowingSettings = false;

    _acFabIcon.reverse();
    _acNavMenu.forward();

    update();
  }

  void hideMenuNav() {
    _isMenuShowing = true;
    _isMenuShowingNav = false;
    _isMenuShowingSettings = true;

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

  // TODO move to main controller?
  ConfettiController confettiController() => _confettiController;
  void playConfetti() => _confettiController.play();

  /// If we are in Tarikh page and switch to a page that needs timeline fully
  /// initialized, we must wait for it to initialize:
  _handleTimelineNotInitializedYet() async {
    if (TarikhC.to.isTimelineInitDone) return; // already initialized

    showLoadingIndicator();
    while (true) {
      if (TarikhC.to.isTimelineInitDone) {
        hideLoadingIndicator();
        break;
      }
      l.w('*********** Timeline is not initialized yet ************');
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

// TODO
// @override
// void dispose() {
//   _confettiController.dispose();
//   super.dispose();
// }
}
