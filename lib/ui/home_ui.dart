import 'package:flutter/material.dart';
import 'package:hapi/ui/components/menu.dart';
import 'package:hapi/ui/components/menu_animation.dart';
import 'package:hapi/ui/tasks_ui.dart';

class HomeUI extends StatelessWidget {
  Widget foregroundPage = TasksUI();
  final _index = ValueNotifier<int>(1);

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
            .map((value) => Icon(value.icon, color: Colors.white, size: 50))
            .toList(),
        selectedColor: Color(0xFFFF595E),
        unselectedColor: Color(0xFF1F2041),
        onItemSelected: (value) {
          if (value != myMenuValue.length - 1 && value != _index.value) {
            _index.value = value;
            // Get.offNamed(myMenuValue[value].page!);
            // //AppRoutes.routes[] as Widget;
            // foregroundWidget =
            //     //
            //     print('going to ' + myMenuValue[value].page!);
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
  MenuValues(icon: Icons.close),
];
