import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/menu_controller.dart';
import 'package:hapi/ui/components/menu.dart';
import 'package:hapi/ui/components/menu_nav.dart';
import 'package:hapi/ui/tasks_ui.dart';

class HomeUI extends StatelessWidget {
  final MenuController c = Get.find();

  final Widget foregroundPage = TasksUI();

  final int selectedIndexAtInit = _kMenuValues.length - 2; // defaults to home
  final _index = ValueNotifier<int>(_kMenuValues.length - 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuNav(
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
        selectedIndexAtInit: selectedIndexAtInit,
        items: _kMenuValues
            .map((value) =>
                Icon(value.icon, color: Colors.white, size: 75)) // TODO THEME
            .toList(),
        onItemSelected: (value) {
          if (value == _index.value) {
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

class MenuValue {
  const MenuValue({required this.icon, this.page});
  final IconData icon;
  final String? page;
}

const _kMenuValues = const [
  MenuValue(icon: Icons.settings, page: '/settings'),
  MenuValue(icon: Icons.mood),
  MenuValue(icon: Icons.cloud),
  MenuValue(icon: Icons.wifi),
  MenuValue(icon: Icons.library_add),
  MenuValue(icon: Icons.book),
  MenuValue(icon: Icons.home, page: '/home'),
  MenuValue(icon: Icons.close), // dummy close button hidden on ui
];
