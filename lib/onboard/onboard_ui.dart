import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_list_ui.dart';
import 'package:hapi/menu/slide/menu_right/menu_right_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/onboard/auth/sign_in_ui.dart';

/// Init all of this NavPage's main widgets and bottom bar
class OnboardUI extends StatelessWidget {
  const OnboardUI();

  /// Variables to detect tutorial task completion (red->green text)
  static bool tabChangedByTabTap = false;
  static bool tabChangedBySwipe = false;
  static bool tabBarWasHidden = false;
  static bool tabBarWasShown = false;
  static bool menuUsedToSwitchFeatures = false;
  static bool menuUsedToViewAboutPage = false;
  static bool menuUsedToShareHapiWithOthers = false;
  static bool menuViewedSettingsGlobal = false;
  static bool menuViewedSettingsTab = false;
  static bool rotatedScreen = false;

  @override
  Widget build(BuildContext context) {
    List<Widget?> settingsWidgets = [];
    List<Widget> aliveMainWidgets = [];
    for (BottomBarItem bottomBarItem in _bottomBarItems) {
      // We can call the onboarding tutorial when signed out or signed in, when
      // Signed in/out some minor logic changes are needed throughout the app.
      if (MainC.to.isSignedIn) {
        if (bottomBarItem is WelcomePage) continue;
        if (bottomBarItem is SignInUI) continue;
      }

      settingsWidgets.add(bottomBarItem.settingsWidget);
      aliveMainWidgets.add(bottomBarItem.aliveMainWidget);
    }

    return MenuRightUI(
      navPage: _navPage,
      settingsWidgets: settingsWidgets,
      foregroundPage: GetBuilder<LangC>(
        builder: (c) => BottomBarMenu(
          _navPage,
          _bottomBarItems,
          aliveMainWidgets,
        ),
      ),
    );
  }
}

const _navPage = NavPage.Mithal;

const List<BottomBarItem> _bottomBarItems = [
  BottomBarItem(
    WelcomePage(),
    null,
    'Welcome',
    'Welcome to hapi!',
    Icons.brightness_3_outlined,
  ),
  BottomBarItem(
    DemoPage1TabSwipe(),
    null,
    'Swipe',
    'How to change tabs',
    Icons.swap_horiz_outlined,
  ),
  BottomBarItem(
    DemoPage2TabScroll(),
    null,
    'Scroll',
    'How to hide and show tabs',
    Icons.swap_vert_outlined,
  ),
  BottomBarItem(
    DemoPage3MenuIntro(),
    null,
    'Menu',
    "What's on the menu?",
    Icons.menu,
  ),
  BottomBarItem(
    DemoPage4MenuSettings(),
    SizedBox(height: 150, child: T('Tab Settings Area', tsWi)), // Settings UI
    'Settings',
    'How to change settings',
    Icons.settings_applications_outlined,
  ),
  BottomBarItem(
    DemoPage5LandscapeZoom(),
    null,
    'Rotate',
    'Rotating your device',
    Icons.rotate_90_degrees_ccw_outlined,
  ),
  BottomBarItem(
    SignInUI(),
    null,
    'Sign In',
    'Sign in to the app',
    Icons.perm_identity_outlined,
  ),
];

/// Variables used by all onboard pages
const double hText = 18;
const double hTextGR = hText * GR;
const double iconSize = hText / 2.5;
const double wIconGap = 10;
const double wBullet1 = 10;
const double wBullet2 = wBullet1 * 2;

class WelcomePage extends StatelessWidget {
  const WelcomePage();

  // must use static so we can keep const for init
  static double _hPageGap = 0;
  static final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);
    final double logoWidthAndHeight =
        (MainC.to.isPortrait ? width : h(context)) / GR;

    final double hPage = h(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          // Don't pad top or bottom for easier _hPageGap calculations
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: GetBuilder<LangC>(
            builder: (c) => Column(
              key: _key, // use key to later get the height of this Widget
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GetBuilder<NavPageC>(builder: (nc) {
                  if (_hPageGap == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      double hKey = 0;
                      if (_key.currentContext != null &&
                          _key.currentContext!.size != null) {
                        hKey += _key.currentContext!.size!.height;
                      }
                      // Calc vertical white space on page (no UI on it):
                      _hPageGap = hPage - hKey - 72; // 72= height of bottom bar
                      if (_hPageGap < 10) _hPageGap = 10; // have min gap
                      c.updateOnThread1Ms(); // now update this UI with gap
                    });
                  }

                  // on init 0, then after calculates gap above, sets real size
                  return SizedBox(height: _hPageGap);
                }),
                Center(
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    width: logoWidthAndHeight,
                    height: logoWidthAndHeight,
                  ),
                ),
                const SizedBox(height: hTextGR),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.headline5,
                    children: const [
                      TextSpan(text: 'Welcome to hapi!'),
                    ],
                  ),
                ),
                const SizedBox(height: hTextGR),
                SizedBox(
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: LangListUI(width - 60, false),
                  ),
                ),
                const SizedBox(height: hTextGR),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.headline6,
                    children: [
                      TextSpan(
                        text: 'hapi is a fun and useful Islamic lifestyle app.'
                                .tr +
                            ' ' +
                            "It's meant to elevate Muslims, in this life and the next."
                                .tr +
                            ' ' +
                            'Earn rewards, increase knowledge and develop good habits with hapi.'
                                .tr,
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: hTextGR),
                // RichText(
                //   text: TextSpan(
                //     style: context.textTheme.headline6,
                //     children: [
                //       TextSpan(
                //         text: 'Start the interactive tutorial'.tr,
                //         style: const TextStyle(
                //           color: AppThemes.hyperlink,
                //           fontWeight: FontWeight.bold,
                //           decoration: TextDecoration.underline,
                //         ),
                //         recognizer: TapGestureRecognizer()
                //           ..onTap = () => BottomBarMenu.animateToPage(_navPage, 1),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: hTextGR),
                // RichText(
                //   text: TextSpan(
                //     style: context.textTheme.headline6,
                //     children: [
                //       TextSpan(
                //         text: 'Skip the tutorial',
                //         recognizer: TapGestureRecognizer()
                //           ..onTap = () => BottomBarMenu.animateToPage(_navPage, 6),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: hTextGR),
                Row(
                  children: [
                    if (c.isRTL) const SizedBox(width: 60),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        T('Start the tutorial', w: width / 3, h: hText, ts),
                        const SizedBox(height: hText / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: width / 3 / 3 / 2),
                            T('Tap', w: width / 3 / 3, h: hText, ts),
                            const Icon(Icons.swap_horiz_outlined, size: 30),
                            SizedBox(width: width / 3 / 3 / 2),
                          ],
                        ),
                        const SizedBox(height: hText / 2),
                        const Icon(Icons.arrow_downward_outlined, size: 22),
                      ],
                    ),
                    SizedBox(width: width / 3 - (40 + (c.isRTL ? 60 : 5))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        T(
                          'Skip the tutorial',
                          w: width / 3,
                          h: hText,
                          ts,
                        ),
                        const SizedBox(height: hText / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(width: width / 3 / 3 / 2),
                            T('Tap', w: width / 3 / 3, h: hText, ts),
                            const Icon(Icons.perm_identity_outlined, size: 30),
                            SizedBox(width: width / 3 / 3 / 2),
                          ],
                        ),
                        const SizedBox(height: hText / 2),
                        const Icon(Icons.arrow_downward_outlined, size: 22),
                      ],
                    ),
                    if (c.isLTR) const SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage1TabSwipe extends StatelessWidget {
  const DemoPage1TabSwipe();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);

    return Center(
      child: SingleChildScrollView(
        child: GetBuilder<LangC>(
          builder: (c) => GetBuilder<NavPageC>(
            builder: (c) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (OnboardUI.tabChangedByTabTap || OnboardUI.tabChangedBySwipe)
                  T('Nice, you changed tabs and completed a tutorial task!', ts,
                      h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hTextGR),
                // if (MainC.to.isSignedIn)
                //   const T('Please note, Tutorial tasks start as red text.', tsRe,
                //       h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hText),
                // if (MainC.to.isSignedIn)
                //   const T('Tutorial tasks start as red text.', tsRe, h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hText),
                // if (MainC.to.isSignedIn)
                //   const T('When completed, they turn green.', tsGr, h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hTextGR),
                // if (MainC.to.isSignedIn)
                //   T('If stuck, hold down buttons for tips or skip ahead.', ts,
                //       h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hText),
                // if (MainC.to.isSignedIn)
                //   T('On mobile devices, try using only your right hand.', ts,
                //       h: hText),
                // if (MainC.to.isSignedIn) const SizedBox(height: hText),
                if (MainC.to.isSignedIn) T("Let's begin!", ts, h: hText),
                const SizedBox(height: hTextGR),
                T('Use tabs to jump between related features.', ts, h: hText),
                const SizedBox(height: hTextGR),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'To change tabs:',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Tap a tab',
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.tabChangedByTabTap ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Swipe left or right',
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.tabChangedBySwipe ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hTextGR * 2),
                T('Optional', tsB, h: hText),
                const SizedBox(height: hText),
                T('On mobile devices, use only your right hand.', ts, h: hText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage2TabScroll extends StatelessWidget {
  const DemoPage2TabScroll();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);
    final double height = h(context);

    const double hAllText = (hText * 6) + hTextGR + 72; // 72= tab wrap height
    final double hAllTextBorder = (height / 2) - (hAllText / 2);

    return SingleChildScrollView(
      child: GetBuilder<LangC>(
        builder: (c) => GetBuilder<NavPageC>(
          builder: (c) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: hAllTextBorder),
              T('Tabs are not always needed and take up space.', h: hText, ts),
              const SizedBox(height: hTextGR),
              T(
                'hapi has a solution, try this now:',
                h: hText,
                ts,
                alignment: LangC.to.centerLeft,
              ),
              const SizedBox(height: hText),
              Row(
                mainAxisAlignment: LangC.to.axisStart,
                children: [
                  const SizedBox(width: wBullet1),
                  const Icon(Icons.circle, size: iconSize),
                  const SizedBox(width: wIconGap), // gap between icon and text
                  T(
                    'To hide tabs:',
                    w: (width - wBullet1 - iconSize - wIconGap) / 2,
                    h: hText,
                    ts,
                    alignment: LangC.to.centerLeft,
                  ),
                  T(
                    'Scroll up',
                    w: (width - wBullet1 - iconSize - wIconGap) / 2,
                    h: hText,
                    OnboardUI.tabBarWasHidden ? tsGr : tsRe,
                    alignment: LangC.to.centerLeft,
                  ),
                ],
              ),
              const SizedBox(height: hText),
              Row(
                mainAxisAlignment: LangC.to.axisStart,
                children: [
                  const SizedBox(width: wBullet1),
                  const Icon(Icons.circle, size: iconSize),
                  const SizedBox(width: wIconGap), // gap between icon and text
                  T(
                    'To show tabs again:', // TODO POSSIBLE HAPI QUEST
                    w: (width - wBullet1 - iconSize - wIconGap) / 2,
                    h: hText,
                    ts,
                    alignment: LangC.to.centerLeft,
                  ),
                  T(
                    'Scroll down',
                    w: (width - wBullet1 - iconSize - wIconGap) / 2,
                    h: hText,
                    OnboardUI.tabBarWasShown ? tsGr : tsRe,
                    alignment: LangC.to.centerLeft,
                  ),
                ],
              ),
              // Add scrollable space now:
              SizedBox(height: hAllTextBorder),
              T('You did it!', h: hText, ts),
              SizedBox(height: hAllTextBorder),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoPage3MenuIntro extends StatelessWidget {
  const DemoPage3MenuIntro();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);

    return Center(
      child: SingleChildScrollView(
        child: GetBuilder<LangC>(
          builder: (c) => GetBuilder<NavPageC>(
            builder: (c) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                T('The menu is in the bottom right corner.', ts, h: hText),
                const SizedBox(height: hTextGR),
                T(
                  'Use the menu to:',
                  ts,
                  h: hText,
                  alignment: LangC.to.centerLeft,
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Switch to a different hapi feature',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.menuUsedToSwitchFeatures ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      "Don't worry, the tutorial won't let you leave",
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Hold down a button to see what it does',
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'View the about page',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.menuUsedToViewAboutPage ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Share hapi with others',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.menuUsedToShareHapiWithOthers ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Change settings',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      "We'll do this next",
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage4MenuSettings extends StatelessWidget {
  const DemoPage4MenuSettings();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);

//  final double h2 = (h(context) / 2) - (((hText * 11) + ((hTextGR) * 2)) / 2);

    return Center(
      child: SingleChildScrollView(
        child: GetBuilder<LangC>(
          builder: (c) => GetBuilder<NavPageC>(
            builder: (c) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                T(
                  'Two type of settings are found in the menu:',
                  ts,
                  h: hText,
                  alignment: LangC.to.centerLeft,
                ),
                const SizedBox(height: hTextGR),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap / 2), // gap between icon and text
                    const Icon(Icons.settings_rounded, size: 28),
                    const SizedBox(
                        width: wIconGap / 2), // gap between icon and text
                    T(
                      'Global settings',
                      w: (width - wBullet1 - iconSize - wIconGap) - 28,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'View the global settings page',
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.menuViewedSettingsGlobal ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(
                        width: wIconGap / 2), // gap between icon and text
                    const Icon(Icons.settings_applications_outlined, size: 28),
                    const SizedBox(
                        width: wIconGap / 2), // gap between icon and text
                    T(
                      'Tab specific settings',
                      w: (width - wBullet1 - iconSize - wIconGap) - 28,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      "View this tab's settings area",
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.menuViewedSettingsTab ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hText),
                Row(
                  mainAxisAlignment: LangC.to.axisStart,
                  children: [
                    const SizedBox(width: wBullet2),
                    const Icon(Icons.remove, size: iconSize),
                    const SizedBox(
                        width: wIconGap), // gap between icon and text
                    T(
                      'Only active tabs with settings show this icon',
                      w: width - wBullet2 - iconSize - wIconGap,
                      h: hText,
                      ts,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage5LandscapeZoom extends StatelessWidget {
  const DemoPage5LandscapeZoom();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);

    return Center(
      child: SingleChildScrollView(
        child: GetBuilder<LangC>(
          builder: (c) => GetBuilder<NavPageC>(
            builder: (c) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                T(
                  'hapi has lots of pages to explore.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hText),
                T(
                  'They all work in portrait and landscape mode.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hText),
                T(
                  'Try both orientations to see what you like more.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hText),
                T(
                  'If your device supports screen rotation, rotate it.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  OnboardUI.rotatedScreen ? tsGr : tsRe,
                ),
                const SizedBox(height: hText),
                T(
                  'Depending on your screen size, and some other factors, you may prefer to view some hapi features in landscape mode.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hTextGR * 3),
                T("That's it!", ts, h: hText),
                const SizedBox(height: hTextGR),
                T('Go to the next tab to start hapi.', h: hText, ts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
