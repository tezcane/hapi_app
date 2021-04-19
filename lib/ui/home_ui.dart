import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/controllers/task_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/components/task_card.dart';
import 'package:hapi/ui/settings_ui.dart';

class HomeUI extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) => controller.firestoreUser.value!.uid == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
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
              /*
              body: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 120),
                    Avatar(controller.firestoreUser.value!),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FormVerticalSpace(),
                        Text(
                            'home.uidLabel'.tr +
                                ': ' +
                                controller.firestoreUser.value!.uid,
                            style: TextStyle(fontSize: 16)),
                        FormVerticalSpace(),
                        Text(
                            'home.nameLabel'.tr +
                                ': ' +
                                controller.firestoreUser.value!.name,
                            style: TextStyle(fontSize: 16)),
                        FormVerticalSpace(),
                        Text(
                            'home.emailLabel'.tr +
                                ': ' +
                                controller.firestoreUser.value!.email,
                            style: TextStyle(fontSize: 16)),
                        FormVerticalSpace(),
                        Text(
                            'home.adminUserLabel'.tr +
                                ': ' +
                                controller.admin.value.toString(),
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ), */
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
                      taskController: _taskController),
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
                      if (taskController != null &&
                          taskController.tasks != null) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: taskController.tasks.length,
                            itemBuilder: (_, index) {
                              return TaskCard(
                                  task: taskController.tasks[index]);
                            },
                          ),
                        );
                      } else {
                        return Text("Loading...");
                      }
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
    required TextEditingController taskController,
  })   : _authController = authController,
        _taskController = taskController,
        super(key: key);

  final AuthController _authController;
  final TextEditingController _taskController;

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
                controller: _taskController,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_taskController.text != "") {
                  Database().addTask(_taskController.text,
                      _authController.firestoreUser.value!.uid);
                  _taskController.clear();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
