import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';

/// Init active/daily/timed/hapi quests with slick bottom bar navigation
class QuestsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: NavPage.Quests,
      settingsWidget: ActiveQuestsSettingsUI(),
      bottomWidget: HapiShareUI(),
      foregroundPage: QuestBottomBarUI(),
    );
  }
}

/// Controller to track a NavPage's last selected SubPage.
class HapiPageController extends GetxHapi {
  HapiPageController(this.subPage) {
    key = '${SubPage.Active_Quests.name}_lastIdx';
    pageController = PageController(initialPage: lastIdx);
  }

  final SubPage subPage;
  late final String key;
  late final PageController pageController;

  int get lastIdx => s.read(key) ?? 3; // 3 = Active Quests
  set lastIdx(int idx) {
    pageController.jumpToPage(idx);
    update(); // needed for UI to update
    s.write(key, idx); // done async, do last
  }
}

// TODO turn off menu settings on other quest pages
class QuestBottomBarUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HapiPageController>(
      init: HapiPageController(SubPage.Active_Quests),
      builder: (c) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: PageView(
            controller: c.pageController,
            children: [
              Container(),
              Container(),
              const DoListUI(),
              ActiveQuestsUI(),
            ],
            onPageChanged: (idx) {
              c.lastIdx = idx;
            },
          ),
          bottomNavigationBar: Row(
            children: [
              BottomBar(
                // Disable to turn off bottom bar view, so menu blends to page
                //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                itemPadding: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 16, right: 16),
                showActiveBackgroundColor: false, // no highlighting text
                selectedIndex: c.lastIdx,
                onTap: (int idx) => c.lastIdx = idx,
                items: [
                  BBItem(
                    context,
                    AppThemes.logoText,
                    Icons.brightness_3_outlined,
                    'hapi',
                    'Quests that are long-term',
                    iconAngle: 2.8,
                  ),
                  BBItem(
                    context,
                    Colors.greenAccent.shade700, //.orange,
                    Icons.timer_outlined,
                    'Time',
                    'Quests to manage time',
                  ),
                  BBItem(
                    context,
                    Colors.yellow,
                    Icons.brightness_high_outlined,
                    'Daily',
                    'Quests to start good habits',
                  ),
                  BBItem(
                    context,
                    Colors.blue,
                    Icons.how_to_reg_outlined,
                    'Active',
                    '            ' // Get around FAB
                        'Quests to perform prayers'
                        '            ', // Get around FAB
                  ),
                ],
              ),
              //const SizedBox(), not needed Row is using MainAxis.start
            ],
          ),
        );
      },
    );
  }
}

class BBItem extends BottomBarItem {
  BBItem(context, Color color, IconData iconData, String title, String tooltip,
      {double iconAngle = 0.0})
      : super(
          activeColor: color,
          icon: Tooltip(
            message: tooltip,
            child: iconAngle == 0
                ? Icon(iconData, size: 30.0)
                : Transform.rotate(
                    // For crescent angle
                    angle: 2.8,
                    child: Icon(iconData, size: 30.0)),
          ),
          title: Tooltip(
            message: tooltip,
            child: Container(
              // magic fixed the BBItems on the page finally... TODO will cut i18n text
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width / 6.0, // Tune this
                maxWidth: MediaQuery.of(context).size.width / 6.0,
              ),
              child: Center(
                child: Text(
                  title,
                  style: iconAngle == 0
                      ? const TextStyle(fontSize: 17)
                      : const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lobster', // for hapi text
                          fontSize: 17),
                ),
              ),
            ),
          ),
        );
}
