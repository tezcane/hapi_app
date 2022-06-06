import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/helpers/loading.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/about_ui.dart';
import 'package:hapi/menu/settings_ui.dart';
import 'package:hapi/quest/active/active_quest_action_ui.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/settings/reset_password_ui.dart';
import 'package:hapi/settings/update_profile_ui.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/tarikh_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

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
  NPV(NavPage.Relics, '', Icons.brightness_3_outlined),
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
      // case (NavPage.Relics):
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

enum SubPage {
  About,
  Settings,
  Update_Profile,
  Reset_Password,
  Tarikh_Timeline,
  Tarikh_Article,
  Active_Quest_Action,
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

    /// pop the page out of the stack
    _subPageStack.removeLast();

    /// handle tarikh animated pages, set active/inactive
    if (getLastNavPage() == NavPage.Tarikh) {
      // if timeline showing again (after article view), make timeline active
      if (_subPageStack.isNotEmpty &&
          _subPageStack.last == SubPage.Tarikh_Timeline) {
        TarikhController.to.isActiveTimeline = true; // reactivate timeline
      } else {
        TarikhController.to.isActiveTimeline = false; // inactivate timeline

        if (_subPageStack.isEmpty &&
            NavPageController.to.getLastIdxName(NavPage.Tarikh) ==
                TARIKH_TAB.Menu.name) {
          TarikhController.to.isActiveTarikhMenu = true; // reactivate menu
        }
      }
    }

    Get.back(); // pop the sub menu stack

    update(); // updates FAB tooltip to say what back button does
  }

  /// Handle the fab button hint, required update() to be called on page
  /// insertion and deletion.
  String trValMenuTooltip() {
    if (_subPageStack.isNotEmpty) {
      if (_subPageStack.length > 1) {
        return 'i.Go back to previous page'.tr;
      } else {
        return at('at.Go back to {0} home page', [getLastNavPage().trKey]);
      }
    } else if (_isMenuShowing) {
      return 'i.Hide menu'.tr;
    } else {
      return 'i.Show menu'.tr;
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

  int _getLastNavIdx() => s.rd('lastNavIdx') ?? NavPage.Quests.index;

  NavPage getLastNavPage() => _getNavPage(_getLastNavIdx());

  bool isFastStartupMode() => s.rd('fastStartupMode') ?? true; // TODO persists

  /// set foreground to last opened page
  initAppsFirstPage() {
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

  _navigateToNavPage(
    NavPage navPage, {
    //dynamic arguments,
    int transitionMs = 1000,
    Transition transition = Transition.fade,
  }) {
    TarikhController.to.isActiveTimeline = false; // turn off timeline rendering

    switch (navPage) {
      case (NavPage.Tarikh):
        Get.offAll(
          () => const TarikhUI(),
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
      TarikhController.to.isActiveTarikhMenu = false; // inactivate tarikh menu
    }

    switch (subPage) {
      case (SubPage.Tarikh_Timeline):
        await _handleTimelineNotInitializedYet();
        Get.to(
          () => TarikhTimelineUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.Tarikh_Article):
        Get.to(
          () => TarikhArticleUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.Active_Quest_Action):
        Get.to(
          () => ActiveQuestActionUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.Update_Profile):
        Get.to(
          () => UpdateProfileUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.Reset_Password):
        Get.to(
          () => ResetPasswordUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.Settings):
        Get.to(
          () => SettingsUI(),
          arguments: arguments,
          transition: transition,
          duration: Duration(milliseconds: transitionMs),
        );
        break;
      case (SubPage.About):
      default:
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
    if (TarikhController.to.isTimelineInitDone) return; // already initialized

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
