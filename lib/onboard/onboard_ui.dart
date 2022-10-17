import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
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
    TutorialAndSignInUpUI(),
    null,
    'a.hapi',
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
    Icons.menu_open,
  ),
  BottomBarItem(
    DemoPage4MenuSettings(),
    DemoTabSettingsArea(), // Menu Right Panel Settings
    'Settings',
    'How to change settings',
    Icons.tune_outlined,
  ),
  BottomBarItem(
    DemoPage5LandscapeZoom(),
    null,
    'Rotate',
    'Rotating your device',
    Icons.rotate_90_degrees_ccw_outlined,
  ),
];

/// Variables used by all onboard pages
const double hText = 18;
const double hTextGR = hText * GR;
const double iconSize = hText / 2.5;
const double wIconGap = 10;
const double wBullet1 = 10;
const double wBullet2 = wBullet1 * 2;

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
                  T('Nice, green means you completed the task!', ts, h: hText),
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
                    const SizedBox(width: wIconGap),
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
                    const SizedBox(width: wIconGap),
                    T(
                      'Swipe left or right',
                      w: width - wBullet1 - iconSize - wIconGap,
                      h: hText,
                      OnboardUI.tabChangedBySwipe ? tsGr : tsRe,
                      alignment: LangC.to.centerLeft,
                    ),
                  ],
                ),
                const SizedBox(height: hTextGR),
                T('OPTIONAL: Use your right hand only.', ts, h: hText),
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

    const double hAllText = (hText * 5) + 72; // 72= tab wrap height
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
                    w: (width - wBullet1 - iconSize - wIconGap) * .65,
                    h: hText,
                    ts,
                    alignment: LangC.to.centerLeft,
                  ),
                  T(
                    'Scroll up',
                    w: (width - wBullet1 - iconSize - wIconGap) * .35,
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
                    w: (width - wBullet1 - iconSize - wIconGap) * .65,
                    h: hText,
                    ts,
                    alignment: LangC.to.centerLeft,
                  ),
                  T(
                    'Scroll down',
                    w: (width - wBullet1 - iconSize - wIconGap) * .35,
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
                  'The menu is on the bottom right, open it to:',
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
                    const SizedBox(width: wIconGap / 2),
                    const Icon(Icons.how_to_reg_outlined, size: 28),
                    const SizedBox(width: wIconGap / 2),
                    T(
                      'Switch hapi features',
                      w: width - wBullet1 - iconSize - wIconGap - 28,
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
                    const SizedBox(width: wIconGap), // icon gap text
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
                    const SizedBox(width: wIconGap / 2),
                    const Icon(Icons.info_outline_rounded, size: 28),
                    const SizedBox(width: wIconGap / 2),
                    T(
                      'View the about page',
                      w: width - wBullet1 - iconSize - wIconGap - 28,
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
                    const SizedBox(width: wIconGap / 2),
                    const Icon(Icons.share_outlined, size: 28),
                    const SizedBox(width: wIconGap / 2),
                    T(
                      'Share hapi with others',
                      w: width - wBullet1 - iconSize - wIconGap - 28,
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
                    const SizedBox(width: wIconGap), // icon gap text
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

class DemoTabSettingsArea extends StatelessWidget {
  const DemoTabSettingsArea();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: TextDecoration.none, // makes yellow underlines go away
          ),
          children: [TextSpan(text: 'Tab Settings Area'.tr)],
        ),
      ),
      const SizedBox(height: 25)
    ]);
  }
}

class DemoPage4MenuSettings extends StatelessWidget {
  const DemoPage4MenuSettings();

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
                    const SizedBox(width: wIconGap / 2),
                    const Icon(Icons.settings_rounded, size: 28),
                    const SizedBox(width: wIconGap / 2),
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
                    const SizedBox(width: wIconGap / 2),
                    const Icon(Icons.settings_applications_outlined, size: 28),
                    const SizedBox(width: wIconGap / 2),
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
                    const SizedBox(width: wIconGap), // icon gap text
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
                const SizedBox(height: hTextGR),
                T("That's it! We hope you enjoy hapi.", ts, h: hText),
                const SizedBox(height: hTextGR),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: PrimaryButton(
                    tk: 'Start hapi',
                    onPressed: () =>
                        BottomBarMenu.animateToPage(NavPage.Mithal, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
