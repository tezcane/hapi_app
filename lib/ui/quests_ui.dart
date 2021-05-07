import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/controllers/quest_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/components/quest_card.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/ui/settings_ui.dart';

class QuestsUI extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: NavPage.QUESTS,
      columnWidget: Column(),
      bottomWidget: HapiShare(),
      foregroundPage: GetBuilder<AuthController>(
        init: AuthController(), // TODO why init AuthController here?
        builder: (controller) => Scaffold(
          appBar: AppBar(
            title: Text(
              'hapi',
              style: TextStyle(
                fontFamily: 'Lobster',
                color: AppThemes.logoText,
                fontSize: 28,
              ),
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Get.to(() => SettingsUI());
                  }),
            ],
          ),
          body: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              AddQuest(
                  authController: controller,
                  textEditingController: _textEditingController),
              GetX<QuestController>(
                init: Get.put<QuestController>(QuestController()),
                builder: (QuestController questController) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: questController.quests.length,
                      itemBuilder: (_, index) {
                        return QuestCard(quest: questController.quests[index]);
                      },
                    ),
                  );
                },
              )
            ],
          ),
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
  })   : _authController = authController,
        _textEditingController = textEditingController,
        super(key: key);

  final AuthController _authController;
  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
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
              icon: Icon(Icons.add),
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
