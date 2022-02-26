import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/painting.dart'; TODO needed?
import 'package:get/get.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/active_quests_ui.dart';
import 'package:hapi/quest/quest_card.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/settings/settings_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class QuestsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: NavPage.QUESTS,
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
  final TextEditingController _textEditingController = TextEditingController();
  int _currentPage = 0; // TODO turn off settings on other quest pages
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          ActiveQuestsUI(),
          UserQuest(textEditingController: _textEditingController),
          Container(color: AppThemes.logoBackground),
          Container(color: AppThemes.logoBackground),
          //Container(color: AppThemes.logoBackground),
        ],
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: Container(
        color: AppThemes.logoBackground,
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
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.brightness_high_outlined),
                  title: Text('Daily Quests'),
                  activeColor: Colors.greenAccent.shade700,
                  //darkActiveColor: Colors.greenAccent.shade400,
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.timer_outlined),
                  title: Text('Time Quests'),
                  activeColor: Colors.orange,
                  //darkActiveColor: Colors.greenAccent.shade400,
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: Transform.rotate(
                    angle: 2.8,
                    child: const Icon(Icons.brightness_3_outlined),
                  ),
                  title: Text('hapi Quests'),
                  activeColor: Colors.red,
                  //darkActiveColor: Colors.red.shade400,
                  inactiveColor: Colors.white,
                ),
                // BottomBarItem(
                //   icon: Icon(Icons.add_circle_outline),
                //   title: Text('Add'),
                //   activeColor: Colors.orange,
                // ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class UserQuest extends StatelessWidget {
  const UserQuest({
    Key? key,
    required TextEditingController textEditingController,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'hapi',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: AppThemes.logoText,
              fontSize: 28,
            ),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Get.to(() => SettingsUI());
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            AddQuest(
                authController: controller,
                textEditingController: _textEditingController),
            GetX<ActiveQuestsController>(
              // TODO should be GetBuilder? not GetX
              builder: (c) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: c.quests.length,
                    itemBuilder: (_, index) {
                      return QuestCard(quest: c.quests[index]);
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class AddQuest extends StatelessWidget {
  const AddQuest({
    Key? key,
    required AuthController authController,
    required TextEditingController textEditingController,
  })  : _authController = authController,
        _textEditingController = textEditingController,
        super(key: key);

  final AuthController _authController;
  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textEditingController,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_textEditingController.text != "") {
                  Database().addQuest(_textEditingController.text,
                      _authController.firestoreUser.value!.uid);
                  _textEditingController.clear();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
