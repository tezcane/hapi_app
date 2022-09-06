import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

/// Controls NavPage bottom bars and loads/persists new tab selections.
// ignore: must_be_immutable
class BottomBarMenu extends StatelessWidget {
  BottomBarMenu(this.navPage, this.bottomBarItems, this.aliveMainWidgets);
  final NavPage navPage;
  final List<BottomBarItem> bottomBarItems;
  final List<Widget> aliveMainWidgets;

  late PageController _pageController;
  bool initNeeded = true;
  int navMovingToIdx = -1;
  int curBottomBarHighlightIdx = 0; // to briefly highlight bottom bar indexes

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavPageController>(builder: (c) {
      if (initNeeded) {
        initNeeded = false;
        _initPageControllerAndBottomBar(c.getLastIdx(navPage));
      }

      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: PageView(
          controller: _pageController,
          children: aliveMainWidgets,
          onPageChanged: (newIdx) => _onPageChanged(newIdx),
        ),
        bottomNavigationBar: BottomBar(
          selectedIndex: curBottomBarHighlightIdx,
          items: bottomBarItems,
          height: bottomBarItems.length < 5 ? 35 : 65,
          onTap: (newIdx) => _onBottomBarTabTapped(newIdx),
          // Disable to turn off bottom bar view, so menu blends to page:
          //backgroundColor: Theme.of(context).scaffoldBackgroundColor, null
          //showActiveBackgroundColor: false,
        ),
      );
    });
  }

  /// Called at init only
  _initPageControllerAndBottomBar(int newIdx) {
    curBottomBarHighlightIdx = newIdx;
    _pageController = PageController(initialPage: newIdx);
    _handlePostFrameAnimation(newIdx); // needed for RTL<->LTR
  }

  /// Called directly when swiping page or indirectly on bottom bar tab tap
  _onPageChanged(int newIdx) {
    curBottomBarHighlightIdx = newIdx; // always highlight current page

    // only do below work when we get final animated page or if swiped to page
    if (navMovingToIdx == newIdx || navMovingToIdx == -1) {
      if (navMovingToIdx == newIdx) navMovingToIdx = -1;
      // Optional callback, can enable/disable a tab page's animations,
      // hide the keyboard (if for example was open from searching and user
      // swiped screen to go to another bottom_bar/tab), etc.
      if (bottomBarItems[newIdx].onPressed != null) {
        bottomBarItems[newIdx].onPressed!.call();
      }
      NavPageController.to.setLastIdx(navPage, newIdx);
    } else {
      NavPageController.to.update(); // to flash intermediate bottom bar select
    }
  }

  /// Called only when bottom bar tab is tapped
  _onBottomBarTabTapped(int newIdx) {
    if (newIdx == NavPageController.to.getLastIdx(navPage)) return; // we r here
    navMovingToIdx = newIdx;
    _handlePostFrameAnimation(newIdx); // needed for stateless widget to work
  }

  /// Called at init and when bottom bar tab is pressed, must do in
  /// PostFrameCallback so all needed objects are initialized.
  _handlePostFrameAnimation(int newIdx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.animateToPage(
        newIdx,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 750),
      ); // this animates to the page on tab press
      // jumpToPage/animateToPage triggers onPageChanged, so don't need:
      //NavPageController.to.setLastIdx(widget.navPage, newIdx);
    });
  }
}
