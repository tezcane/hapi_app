import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

/// Controls NavPage bottom bars and loads/persists new tab selections.
// ignore: must_be_immutable
class BottomBarMenu extends StatelessWidget {
  BottomBarMenu(this.navPage, this.bottomBarItems, this.aliveMainWidgets) {
    _initPageControllerAndBottomBar(NavPageC.to.getLastIdx(navPage));
  }
  final NavPage navPage;
  final List<BottomBarItem> bottomBarItems;
  final List<Widget> aliveMainWidgets;

  late final PageController _pageController;
  late int curBottomBarHighlightIdx; // to briefly highlight bottom bar indexes

  int movingToIdx = -1;

  /// Used to show/hide the bottom bar on up/dn scroll detection. Static so when
  /// FAB MenuC button can force show bottom bar so it is not in way of menu UI.
  static bool isBottomBarVisible = true;
  double position = 0.0; // Used to store +/- scroll direction position
//final double sensitivityFactor = 0.0; // # pixels before up/dn state triggers (replace ">= 0.0" checks below to use)

  /// Due to complexities of multiple widget's having different scroll
  /// directions, these variables are used to detect vertical (for Relic Lists)
  /// and horizontal (for PageView BottomBar) scrolling. These variables are
  /// used to create a state machine to accurately detect user scrolling. It
  /// seems overly complicated, but this needed to overcome edge cases, e.g. if
  /// the user swipes LEFT, his finger may also be sliding upwards and cause a
  /// scroll UP command(s) to come between scroll left commands. This would
  /// cause the bottom bar to wrongly hide down.
  ///
  /// Here is how the NotificationListener states come in:
  /// 1. ScrollStartNotification
  ///   - used to reset state machine as a new scroll input has started
  /// 2. UserScrollNotification
  ///   - This only comes in when the user scrolls with their finger.
  ///   - If the user hits a button that scrolls, this does not come in so its a
  ///     quick way to quickly rule out non-finger input scrolls.
  /// 3. ScrollUpdateNotification
  ///   - The majority of notifications, gives new scroll position data.
  /// 4. OverscrollNotification
  ///   - If the UI can't scroll anymore (stuck on screen edge) this comes in.
  ///   - There shouldn't be anything to do here unless you want special logic
  ///     to do something on edge hits.
  /// 5. ScrollEndNotification
  ///   - Always comes in once scrolling stops, so scrolling is in idle.
  final int UP = 0; // scroll up state and idx of scrolls array
  final int DN = 1; // scroll up down state and idx of scrolls array
  final int LF = 2; // scroll up left state and idx of scrolls array
  final int RT = 3; // scroll up right state and idx of scrolls array
  final int IDLE = 4; // IDLE state, no scrolling going on
  final int FOUND_START = 5; // sets after ScrollStartNotification comes
  final int DETECT = 6; // Ready to detect a user scroll direction
  final int BUTTON_PRESSED = 7; // sets if UserScrollNotification didn't come in
  int state = 4; // start in IDLE state
  List<int> scrolls = [0, 0, 0, 0]; // counts a scroll direction events in a row
  final int CHANGE_TO_DIRECTION_STATE_THRESHOLD = 4; // goes +1 times than this
  int cnt = 0; //counts scroll events for debug and to understand scroll logic

  _initPageControllerAndBottomBar(int newIdx) {
    curBottomBarHighlightIdx = newIdx;
    _pageController = PageController(initialPage: newIdx);
    _handlePostFrameAnimation(newIdx); // needed for RTL<->LTR
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavPageC>(
      // needed, or bar doesn't update
      builder: (c) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: NotificationListener<ScrollNotification>(
            child: PageView(
//            pageSnapping: false,
              controller: _pageController,
              children: aliveMainWidgets,
              onPageChanged: (newIdx) => _onPageChanged(newIdx, c),
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if (kDebugMode) cnt++; // help detect

              /// Left as an example, you can use it to horizontally scroll the
              /// bottom bar faster/smoother, needs PageView.pageSnapping=false:
              // if (scrollInfo is ScrollEndNotification) {
              //   Future.delayed(const Duration(milliseconds: 0), () {
              //     int newPage = _pageController.page!.round();
              //     _pageController.animateToPage(
              //       newPage,
              //       duration: const Duration(milliseconds: 80),
              //       curve: Curves.fastOutSlowIn,
              //     );
              //   });
              // }

              if (scrollInfo is ScrollUpdateNotification) {
                if (state == DETECT) {
                  if (kDebugMode) l.v('$cnt $state SN: Update, detect state');
                } else if (state == FOUND_START || state == BUTTON_PRESSED) {
                  state = BUTTON_PRESSED;
                  if (kDebugMode) l.v('$cnt $state SN: Update, button pressed');
                  return true; // ignore scroll data from button presses
                }
                // in state detect/up/dn/lf/rt, so go to scroll direction logic
              } else if (scrollInfo is ScrollStartNotification) {
                cnt = 1; // so debug prints start from 1
                scrolls = [0, 0, 0, 0]; // reset all scroll in a row counts
                state = FOUND_START;
                if (kDebugMode) l.v('$cnt $state SN: Start');
                return true; // return, no scroll data comes with this
              } else if (scrollInfo is UserScrollNotification) {
                if (state == FOUND_START) {
                  state = DETECT;
                  if (kDebugMode) l.v('$cnt $state SN: User, start detect');
                  // scroll data sometimes came in with this, i think
                } else {
                  state = IDLE;
                  if (kDebugMode) l.v('$cnt $state SN: User, End');
                  return true; // return, at end of user scroll event
                }
              } else if (scrollInfo is ScrollEndNotification) {
                state = IDLE;
                if (kDebugMode) l.v('$cnt $state SN: End');
                return true; // return, nothing to do
              } else if (scrollInfo is OverscrollNotification) {
                if (kDebugMode) l.v('$cnt $state SN: Overscroll');
                return true; // return, nothing to do
              } else {
                if (kDebugMode) l.w('$cnt $state SN: ??? $scrollInfo');
                return true; // return, nothing to do
              }

              if (_pageController.position.userScrollDirection ==
                  ScrollDirection.reverse) {
                // IF HERE PAGE VIEW IS SCROLLING LEFT
                if (scrolls[RT] == 0 && scrolls[UP] == 0 && scrolls[DN] == 0) {
                  if (scrolls[LF] > CHANGE_TO_DIRECTION_STATE_THRESHOLD) {
                    state = LF;
                    if (kDebugMode) l.v('$cnt $state LEFT STATE SET');
                  }
                } else {
                  scrolls = [0, 0, 0, 0]; // reset
                  state = DETECT;
                  if (kDebugMode) l.v('$cnt $state LEFT DETECT');
                }
                scrolls[LF]++;
              } else if (_pageController.position.userScrollDirection ==
                  ScrollDirection.forward) {
                // IF HERE PAGE VIEW IS SCROLLING RIGHT
                if (scrolls[LF] == 0 && scrolls[UP] == 0 && scrolls[DN] == 0) {
                  if (scrolls[RT] > CHANGE_TO_DIRECTION_STATE_THRESHOLD) {
                    state = RT;
                    if (kDebugMode) l.v('$cnt $state RIGHT STATE SET');
                  }
                } else {
                  scrolls = [0, 0, 0, 0]; // reset
                  state = DETECT;
                  if (kDebugMode) l.v('$cnt $state RIGHT DETECT');
                }
                scrolls[RT]++;
              } else if (scrollInfo.metrics.pixels - position >= 0.0) {
                position = scrollInfo.metrics.pixels;
                // IF HERE PAGE VIEW'S WIDGET IS SCROLLING UP
                if (scrolls[LF] == 0 && scrolls[RT] == 0 && scrolls[DN] == 0) {
                  if (scrolls[UP] > CHANGE_TO_DIRECTION_STATE_THRESHOLD) {
                    state = UP;
                    if (kDebugMode) l.v('$cnt $state UP STATE SET');
                    if (isBottomBarVisible) {
                      if (kDebugMode) l.d('$cnt $state hide bottom bar');
                      isBottomBarVisible = false;
                      c.updateOnThread1Ms();
                    }
                  }
                } else {
                  scrolls = [0, 0, 0, 0]; // reset
                  state = DETECT;
                  if (kDebugMode) l.v('$cnt $state UP DETECT');
                }
                scrolls[UP]++;
              } else if (position - scrollInfo.metrics.pixels >= 0.0) {
                // IF HERE PAGE VIEW'S WIDGET IS SCROLLING DOWN
                position = scrollInfo.metrics.pixels;
                if (scrolls[LF] == 0 && scrolls[RT] == 0 && scrolls[UP] == 0) {
                  if (scrolls[DN] > CHANGE_TO_DIRECTION_STATE_THRESHOLD) {
                    state = DN;
                    if (kDebugMode) l.v('$cnt $state DOWN STATE SET');
                    if (!isBottomBarVisible) {
                      if (kDebugMode) l.d('$cnt $state show bottom bar');
                      isBottomBarVisible = true;
                      c.updateOnThread1Ms();
                    }
                  }
                } else {
                  scrolls = [0, 0, 0, 0]; // reset
                  state = DETECT;
                  if (kDebugMode) l.v('$cnt $state DOWN DETECT');
                }
                scrolls[DN]++;
              }
              return true;
            },
          ),
          // AnimatedContainer animates the showing/hiding of bottom bar
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isBottomBarVisible
                ? bottomBarItems.length < 5
                    ? 35
                    : 65
                : 0, // here is the magic that hides the bar
            // Wrap needed or get overflow errors
            child: Wrap(
              children: [
                BottomBar(
                  selectedIndex: curBottomBarHighlightIdx,
                  items: bottomBarItems,
                  height: bottomBarItems.length < 5 ? 35 : 65,
                  onTap: (newIdx) => _onBottomBarTabTapped(newIdx),
                  // Disable to turn off bottom bar view, so menu blends to page:
                  //backgroundColor: Theme.of(context).scaffoldBackgroundColor, null
                  //showActiveBackgroundColor: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Called directly when swiping page or indirectly on bottom bar tab tap
  _onPageChanged(int newIdx, NavPageC c) {
    isBottomBarVisible =
        true; // if bottom bar hidden, force show on page view change

    curBottomBarHighlightIdx = newIdx; // always highlight current page

    // only do below work when we get final animated page or if swiped to page
    if (movingToIdx == newIdx || movingToIdx == -1) {
      if (movingToIdx == newIdx) movingToIdx = -1;
      // Optional callback, can enable/disable a tab page's animations,
      // hide the keyboard (if for example was open from searching and user
      // swiped screen to go to another bottom_bar/tab), etc.
      if (bottomBarItems[newIdx].onPressed != null) {
        bottomBarItems[newIdx].onPressed!.call();
      }
      NavPageC.to.setLastIdx(navPage, newIdx);
    } else {
      NavPageC.to.update(); // to flash intermediate bottom bar select
    }
  }

  /// Called only when bottom bar tab is tapped
  _onBottomBarTabTapped(int newIdx) {
    if (newIdx == NavPageC.to.getLastIdx(navPage)) return; // we r here
    movingToIdx = newIdx;
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
      //NavPageC.to.setLastIdx(widget.navPage, newIdx);
    });
  }
}
