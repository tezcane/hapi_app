import 'package:flutter/material.dart';
import 'package:hapi/menu/menu_controller.dart';

class FabSubPage extends StatelessWidget {
  const FabSubPage({Key? key, required this.subPage, required this.child})
      : super(key: key);

  final SubPage subPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MenuController cMenu = MenuController.to;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          tooltip: 'Go back to the previous page',
          onPressed: () => cMenu.handleBackButtonHit(),
          heroTag: subPage,
          child: const Icon(Icons.arrow_forward_outlined, size: 30),
        ),
      ),
      body: child, // <- SubPages go here
    );
  }
}
