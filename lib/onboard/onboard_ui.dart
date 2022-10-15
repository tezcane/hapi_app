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
import 'package:hapi/onboard/auth/sign_in_up_ui.dart';

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
    'Welcome tab',
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
    SizedBox(height: 150, child: T('Tab Settings Area', tsWiB)), // Settings UI
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
    SignInUpUI(),
    null,
    'Sign In',
    'Start hapi',
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
                  T('Nice, you just completed a tutorial task!', ts, h: hText),
                if (MainC.to.isSignedIn) T("Let's begin!", ts, h: hText),
                const SizedBox(height: hTextGR),
                T(
                  'You can switch tabs in two ways:',
                  w: width - wBullet1 - iconSize - wIconGap,
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
                    const SizedBox(width: wIconGap), // icon and text gap
                    T(
                      'Tap a tab',
                      w: width - wBullet1 - iconSize - wIconGap,
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
                    const SizedBox(width: wBullet1),
                    const Icon(Icons.circle, size: iconSize),
                    const SizedBox(width: wIconGap), // icon and text gap
                    T(
                      'Swipe left or right',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.tabChangedBySwipe ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hTextGR * 2),
                T('OPTIONAL: Complete the tutorial one handed.', ts, h: hText),
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
              T(
                'Tabs are not always needed and take up space, try this:',
                h: hText,
                ts,
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
                T(
                  'The menu is on the bottom right, use it to:',
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
                      'Switch hapi features',
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
                      'Change setting (explained next)',
                      w: width - wBullet1 - iconSize - wIconGap,
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
                  'The menu has two type of settings, find them:',
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
                    const SizedBox(width: wIconGap / 2), // icon and text gap
                    const Icon(Icons.settings_rounded, size: 28),
                    const SizedBox(width: wIconGap / 2), // icon and text gap
                    T(
                      'Global settings',
                      w: (width - wBullet1 - iconSize - wIconGap) - 28,
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
                    const SizedBox(width: wIconGap / 2), // icon and text gap
                    const Icon(Icons.settings_applications_outlined, size: 28),
                    const SizedBox(width: wIconGap / 2), // icon and text gap
                    T(
                      'Tab specific settings',
                      w: (width - wBullet1 - iconSize - wIconGap) - 28,
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
                      'Appears if the selected tab has settings',
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
                  'hapi has many features to explore.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hText),
                T(
                  'If your device supports it, rotate it now.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  OnboardUI.rotatedScreen ? tsGr : tsRe,
                ),
                const SizedBox(height: hText),
                T(
                  'On many devices, this sentence will look small in portrait orientation and normal in landscape orientation.',
                  w: width - wBullet1 - iconSize - wIconGap,
                  h: hText,
                  ts,
                ),
                const SizedBox(height: hTextGR * 2),
                T("That's it! You are ready to start hapi.", ts, h: hText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
