import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/daily/daily_quests_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_card.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class DoListUI extends StatelessWidget {
  const DoListUI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) => Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          AddDoList(
            authController: controller,
            textEditingController: TextEditingController(),
          ),
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
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  fillColor: context.theme.scaffoldBackgroundColor,
                  filled: true,
                  hintText: 'Enter new TODO quest',
                  hintStyle: const TextStyle(fontSize: 20),
                  prefixIcon: Transform.scale(
                    scale: 1.2,
                    child: const Icon(Icons.check_outlined),
                  ),
                ),
                controller: _textEditingController,
              ),
            ),
            Transform.scale(
              scale: 1.6,
              child: IconButton(
                color: AppThemes.addIcon,
                // color: _textEditingController.text != "" TODO
                //     ? AppThemes.selected
                //     : AppThemes.unselected,
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_textEditingController.text != '') {
                    Database().addDoList(_textEditingController.text,
                        _authController.firestoreUser.value!.uid);
                    _textEditingController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
