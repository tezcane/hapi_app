import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/daily/daily_quests_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_card.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/settings/settings_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class DoListQuestUI extends StatelessWidget {
  const DoListQuestUI({
    Key? key,
  }) : super(key: key);

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
            AddDoList(
                authController: controller,
                textEditingController: TextEditingController()),
            GetBuilder<DailyQuestsController>(
              builder: (c) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: c.doList.length,
                    itemBuilder: (_, index) {
                      return DoListCard(doList: c.doList[index]);
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

class AddDoList extends StatelessWidget {
  const AddDoList({
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
                  Database().addDoList(_textEditingController.text,
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
