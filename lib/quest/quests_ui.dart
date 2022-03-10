import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/daily/do_list/do_list_quest_ui.dart';

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

class QuestBottomBarUI extends StatefulWidget {
  @override
  _QuestBottomBarUIState createState() => _QuestBottomBarUIState();
}

class _QuestBottomBarUIState extends State<QuestBottomBarUI> {
  int _currentPage = 0; // TODO turn off settings on other quest pages
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          ActiveQuestsUI(),
          const DoListUI(),
          Container(color: Get.theme.backgroundColor),
          Container(color: Get.theme.backgroundColor),
        ],
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: Container(
        color: Get.theme.backgroundColor,
        child: Row(
          children: [
            BottomBar(
              selectedIndex: _currentPage,
              onTap: (int index) {
                _pageController.jumpToPage(index);
                setState(() => _currentPage = index);
              },
              items: [
                BottomBarItem(
                  icon: const Icon(Icons.how_to_reg_outlined),
                  title: Text('Active Quests'),
                  activeColor: Colors.blue,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.brightness_high_outlined),
                  title: Text('Daily Quests'),
                  activeColor: Colors.greenAccent.shade700,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.timer_outlined),
                  title: Text('Time Quests'),
                  activeColor: Colors.orange,
                ),
                BottomBarItem(
                  icon: Transform.rotate(
                    angle: 2.8,
                    child: const Icon(Icons.brightness_3_outlined),
                  ),
                  title: Text('hapi Quests'),
                  activeColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(width: 10), // filler to offset menu
          ],
        ),
      ),
    );
  }
}
