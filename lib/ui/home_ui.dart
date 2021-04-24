import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/ui/components/menu.dart';
import 'package:hapi/ui/tasks_ui.dart';

class HomeUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) => Scaffold(
        body: Menu(
          foregroundWidget: TasksUI(), // Main page
          columnWidget: Column(),
          bottomWidget: Row(), // Right widget, preferably Row
        ),
      ),
    );
  }
}
