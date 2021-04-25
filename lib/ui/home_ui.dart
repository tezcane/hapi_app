import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/menu_controller.dart';
import 'package:hapi/ui/components/menu.dart';
import 'package:hapi/ui/components/menu_animation.dart';
import 'package:hapi/ui/tasks_ui.dart';

class HomeUI extends StatelessWidget {
  final MenuController c = Get.find();

  Widget foregroundPage = TasksUI();
  final _index = ValueNotifier<int>(myMenuValue.length - 2); // defaults to home

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuAnimation.builder(
        builder: (showMenu) {
          return Scaffold(
            body: Menu(
              onPressed: showMenu,
              foregroundPage: foregroundPage, // Main page
              columnWidget: Column(), // preferably Column
              bottomWidget: Row(), // preferably Row
            ),
          );
        },
        enableEdgeDragGesture: true,
        items: myMenuValue
            .map((value) => Icon(value.icon, color: Colors.white, size: 75))
            .toList(),
        onItemSelected: (value) {
          if (value == _index.value) {
            // no longer needed as we hide close button: value == myMenuValue.length - 1 ||
            print('selected index did not change, is $value');
          } else {
            _index.value = value;
            print('selected index changed to $value');
            // TODO NAVIGATE
          }
        },
      ),
    );
  }
}

class MenuValues {
  const MenuValues({required this.icon, this.page});
  final IconData icon;
  final String? page;
}

const myMenuValue = const [
  MenuValues(icon: Icons.settings, page: '/settings'),
  MenuValues(icon: Icons.mood),
  MenuValues(icon: Icons.cloud),
  MenuValues(icon: Icons.wifi),
  MenuValues(icon: Icons.library_add),
  MenuValues(icon: Icons.book),
  MenuValues(icon: Icons.home, page: '/home'),
  MenuValues(icon: Icons.close), // dummy close button hidden on ui
];
