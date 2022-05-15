import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/helpers/loading.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/about_ui.dart';
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

/// Class to hold values needed to initialize NavPage and its defaults.
class NavPageValue {
  const NavPageValue(this.defaultIdx, this.navPage, this.icon);
  final int defaultIdx;
  final NavPage navPage;
  final IconData icon;
}

/// must keep in sync with NavPage
final navPageValues = [
  NavPageValue(0, NavPage.Ajr, Icons.leaderboard_rounded),
  NavPageValue(0, NavPage.Tools, Icons.explore_outlined),
  NavPageValue(0, NavPage.Dua, Icons.volunteer_activism),
  NavPageValue(0, NavPage.Hadith, Icons.menu_book_outlined),
  NavPageValue(0, NavPage.Quran, Icons.auto_stories),
  NavPageValue(0, NavPage.Tarikh, Icons.history_edu_outlined),
  NavPageValue(0, NavPage.Relics, Icons.brightness_3_outlined),
  NavPageValue(Quests.Active.index, NavPage.Quests,
      Icons.how_to_reg_outlined), // 3=Active Quests
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
}

enum SubPage {
  About,
  Update_Profile,
  Reset_Password,
  Tarikh_Favorite,
  Tarikh_Search,
  Tarikh_Timeline,
  Tarikh_Article,
  Active_Quest_Action,
}

extension EnumUtil2 on SubPage {
  get niceName => name.replaceAll('_', ' ');
}

class MenuController extends GetxHapi with GetTickerProviderStateMixin {
  static MenuController get to => Get.find();

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

  /// Here we handle when the FAB button is hit for show/hide menu or back btn.
  void handlePressedFAB() {
    if (fabButtonIsTransitioning) {
      l.w('GOOD TRY, FAB is still transitioning!!!!!!!!!!');
      return; // POSSIBLE HAPI QUEST: "Interrupt/Break Menu Button" hapi task
    }

    // if on main menu page, just show/hide menu per usual
    if (_subPageStack.isEmpty) {
      if (_isMenuShowing) {
        hideMenu(); // just hit close on fab
      } else {
        showMenu(); // just hit menu on fab
      }
    } else {
      // if we are in sub page then it means back button was hit
      if (_subPageStack.length == 1) {
        // if page before main menu page, play animation
        _acFabIcon.reverse();
        // and switch back to menu close icon
        _fabAnimatedIcon = AnimatedIcons.menu_close;
        update();
      }

      // pop the page out of the stack
      _subPageStack.removeLast();

      // if timeline showing again, turn timeline rendering back on
      if (_subPageStack.isNotEmpty &&
          _subPageStack.last == SubPage.Tarikh_Timeline) {
        TarikhController.to.isActiveTimeline = true;
      } else {
        if (_subPageStack.isEmpty && getLastNavPage() == NavPage.Tarikh) {
          TarikhController.to.isActiveTarikhMenu = true;
        }
      }

      Get.back(); // pop the sub menu stack

      update(); // updates FAB tooltip to say what back button does
    }
  }

  /// Handle the fab button hint, required update() to be called on page
  /// insertion and deletion.
  String getToolTip() {
    if (_subPageStack.isNotEmpty) {
      if (_subPageStack.length > 1) {
        return 'Go back to ${_subPageStack[_subPageStack.length - 2].niceName} Page';
      } else {
        return 'Go back to ${getLastNavPage().name} Home';
      }
    } else if (_isMenuShowing) {
      return 'Hide menu';
    } else {
      return 'Show menu';
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

  int _getLastNavIdx() {
    return s.rd('lastNavIdx') ?? NavPage.Quests.index;
  }

  NavPage getLastNavPage() {
    return _getNavPage(_getLastNavIdx());
  }

  bool isFastStartupMode() {
    return s.rd('fastStartupMode') ?? true; // TODO write this setting
  }

  /// set foreground to last opened page
  void initAppsFirstPage() {
    int navIdx = _getLastNavIdx(); //Quests

    NavPage lastNavPage = NavPage.Quests;
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
      MainController.to.setAppInitDone();
    }

    _navigateToNavPage(lastNavPage, transitionMs: heroLogoTransitionMs);

    if (!isFastStartupMode()) {
      Timer(Duration(milliseconds: showMenuDuringHeroTransitionMs), () {
        showMenu(); // open menu to let logo slide into place
        Timer(Duration(milliseconds: hideMenuAfterFullInitMs), () {
          hideMenu(); // logo should be in menu by now
          Timer(animationDuration, () {
            _enableScreenTouch(); // give time for menu to close
            MainController.to.setAppInitDone();
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
      return NavPage.Quests;
    }
  }

  /// Use to switch to a high level nav page only (e.g. Quests, Quran, etc.)
  void navigateToNavPage(NavPage navPage, {bool offAll = false}) {
    // clear stack in case we jump to this next nav menu
    if (_subPageStack.isNotEmpty) {
      _subPageStack = [];
    }

    // save so app restarts at this idx
    s.wr('lastNavIdx', navPage.index);

    _navigateToNavPage(navPage);
  }

  void _navigateToNavPage(
    NavPage navPage, {
    //dynamic arguments,
    int transitionMs = 1000,
    Transition transition = Transition.fade,
  }) {
    TarikhController.to.isActiveTimeline = false; // turn off timeline rendering

    switch (navPage) {
      case (NavPage.Tarikh):
        Get.offAll(
          () => TarikhMenuUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (NavPage.Ajr):
      case (NavPage.Tools):
      case (NavPage.Dua):
      case (NavPage.Hadith):
      case (NavPage.Quran):
      case (NavPage.Relics):
      case (NavPage.Quests):
      default:
        Get.offAll(
          () => QuestsUI(),
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
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
  }) async {
    // // TODO option for disallow duplicates so might not need this
    // if (_subPageStack.length != 0) {
    //   if (_subPageStack[_subPageStack.length - 1] == subPage) {
    //     //print('$pageName already on stack, returning!');
    //     return;
    //   }
    // }

    // if we are in Tarikh page and switch to a page that needs timeline fully
    // initialized, we must wait for it to initialize:
    if (getLastNavPage() == NavPage.Tarikh) {
      switch (subPage) {
        case (SubPage.Tarikh_Favorite):
        case (SubPage.Tarikh_Search):
        case (SubPage.Tarikh_Timeline):
          await handleTimelineNotInitializedYet();
          break;
        default:
          break;
      }
    }

    _subPageStack.add(subPage);

    /// HERE WE HANDLE THE FAB BUTTON ANIMATIONS ON INSERTING NEW SUB PAGES
    // if adding first sub page, animate menu turning into an arrow
    if (_subPageStack.length == 1) {
      fabButtonIsTransitioning = true;
      if (_isMenuShowing) {
        // i.e. about page is clicked
        hideMenu(); // spin out of showing X to menu, then we turn into arrow
      }
      Timer(animationDuration, () {
        _fabAnimatedIcon = AnimatedIcons.menu_arrow;
        update();
        _acFabIcon.forward();
        fabButtonIsTransitioning = false;
      }); // requires new thread
    }

    switch (subPage) {
      case (SubPage.Tarikh_Favorite):
        Get.to(
          () => TarikhFavoritesUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Tarikh_Search):
        Get.to(
          () => const TarikhSearchUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Tarikh_Timeline):
        Get.to(
          () => TarikhTimelineUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Tarikh_Article):
        Get.to(
          () => TarikhArticleUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Active_Quest_Action):
        Get.to(
          () => ActiveQuestActionUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Update_Profile):
        Get.to(
          () => UpdateProfileUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.Reset_Password):
        Get.to(
          () => ResetPasswordUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
        );
        break;
      case (SubPage.About):
      default:
        Get.to(
          () => AboutUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transistionMs),
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

  handleTimelineNotInitializedYet() async {
    if (TarikhController.to.isTimelineInitDone) {
      return; // already initialized, no need to show loading and wait
    }

    showLoadingIndicator();
    while (true) {
      if (TarikhController.to.isTimelineInitDone) {
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
