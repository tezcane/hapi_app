import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/constants/app_routes.dart';
import 'package:hapi/ui/home_ui.dart';
import 'package:hapi/ui/quests_ui.dart';

class MenuController extends GetxController {
  static MenuController to = Get.find();

  final store = GetStorage();

  /// controls fab icon animation
  late AnimationController _acFabIcon;
  void initACFabIcon(AnimationController ac) => _acFabIcon = ac;

  /// controls nav menu animation
  late AnimationController _acNavMenu;
  void initACNavMenu(AnimationController navMenuAC) => _acNavMenu = navMenuAC;

  // use to control fab animation depending if it as a root or deeper page
  final AnimatedIconData animatedIconMenuClose = AnimatedIcons.menu_close;
  final AnimatedIconData animatedIconMenuArrow = AnimatedIcons.arrow_menu;
  AnimatedIconData _fabAnimatedIcon = AnimatedIcons.menu_close;
  AnimatedIconData getFabAnimatedIcon() => _fabAnimatedIcon;

  RxBool _isFabBackMode = false.obs;
  RxBool get isFabBackMode => _isFabBackMode;

  /// Track pushed pages so we can backtrack to main nav menu page
  // TODO Persist this, where possible, pass in arguments to classes to rebuild:
  List<String> _pushedPageStack = [];

  Widget _foregroundPage = QuestsUI();
  int initForegroundPage(bool updateUI) {
    int navIdx = store.read('lastNavIdx') ?? NavPage.QUESTS.index; //Quests
    navigateToNavPage(navIdx, updateUI); // set foreground to last opened page
    return navIdx;
  }

  Widget getForegroundPage() {
    return _foregroundPage;
  }

  /// Use to switch to a high level nav page only (e.g. Quests, Quran, etc.)
  void navigateToNavPage(int navIdx, bool updateUI) {
    for (GetPage getPage in AppRoutes.routes) {
      if (getPage.name == kNavs[navIdx].page) {
        _foregroundPage = getPage.page(); // set the foreground in homepage

        store.write('lastNavIdx', navIdx); // save so app restarts at this idx

        if (_pushedPageStack.length > 0) {
          _pushedPageStack = []; // clear stack in case we jump to this menu
        }
        if (isFabBackMode.value == true) {
          _setFabBackMode(false, false);
        }

        // don't call update on init, as we are still building all widgets
        if (updateUI) {
          update();
        }

        break;
      }
    }
  }

  /// use to push a NavPages sub page (Tarikh Favorites, etc.) on top of menu stack
  /// About page is ok here too
  void pushToPage(String pageName) {
    if (_pushedPageStack.length != 0) {
      if (_pushedPageStack[_pushedPageStack.length - 1] == pageName) {
        //print('$pageName already on stack, returning!');
        return;
      }
    }

    if (_isFabBackMode.value != true) {
      _setFabBackMode(true, false);
    }

    for (GetPage getPage in AppRoutes.routes) {
      if (getPage.name == pageName) {
        //print('Pushing $pageName to menu stack');
        _pushedPageStack.add(pageName);
        _foregroundPage = getPage.page(); // set the foreground in homepage

        update();
        break;
      }
    }
  }

  void _setFabBackMode(bool newfabBackMode, bool updateUI) {
    _isFabBackMode.value = newfabBackMode;
    // TODO smooth back<->menu<->close transitions
    if (_isFabBackMode.value) {
      _fabAnimatedIcon = animatedIconMenuArrow;
    } else {
      _fabAnimatedIcon = animatedIconMenuClose;
    }

    if (updateUI) {
      update();
    }
  }

  void handleBackButtonHit() {
    _pushedPageStack.removeLast(); // always pop the stack

    if (_pushedPageStack.length == 0) {
      initForegroundPage(true); // this clears out fab back mode
    } else {
      Get.back(); // pop the sub menu stack
    }
  }

  bool isAboutPageShowing() {
    if (_pushedPageStack.length != 0) {
      return _pushedPageStack[_pushedPageStack.length - 1] == '/about';
    }
    return false;
  }

  RxBool _isMenuShowing = false.obs;
  RxBool _isMenuShowingNav = false.obs;
  RxBool _isMenuShowingSpecial = false.obs; // TODO
  RxBool _isSpecialActionReady = false.obs;

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
