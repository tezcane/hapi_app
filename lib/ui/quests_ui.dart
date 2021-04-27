import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/controllers/task_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/components/task_card.dart';
import 'package:hapi/ui/settings_ui.dart';

class QuestsUI extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
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
            Text(
              "Add Task Here:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AddTask(
                authController: controller,
                textEditingController: _textEditingController),
            Text(
              "Your Tasks",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GetX<TaskController>(
              init: Get.put<TaskController>(TaskController()),
              builder: (TaskController taskController) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: taskController.tasks.length,
                    itemBuilder: (_, index) {
                      return TaskCard(task: taskController.tasks[index]);
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

class AddTask extends StatelessWidget {
  const AddTask({
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
                  Database().addTask(_textEditingController.text,
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
